//
//  PlayersDataModel.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 24.01.2021.
//

import Foundation
import CoreData.NSFetchedResultsController

typealias PlayerData = (name: String, number: Int16, nationality: String, age: Int16,
                        team: String, position: String, isInPlay: Bool, photo: Data?)
typealias SearchData = (name: String?, age: Int16?, ageOperator: AgeOperatorState,
                        team: String?, position: String?)

// MARK: - Protocols

protocol PlayersDataModelDelegate: AnyObject {
    func dataDidChange(type: NSFetchedResultsChangeType?)
    func willChangeContent()
    func didChangeSection(type: NSFetchedResultsChangeType, sectionIndex: Int)
    func didChangeObject(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)
    func didChangeContent()
}

protocol PlayersDataModelProtocol {
    var delegate: PlayersDataModelDelegate? { get set }
    var isEmptyData: Bool { get }
    var numberOfSections: Int { get }
    
    func getPlayer(at indexPath: IndexPath) -> Player?
    func getTitle(atSection section: Int) -> String?
    func getNumberOfPlayers(atSection section: Int) -> Int
    func removePlayer(at indexPath: IndexPath)
    func createPlayer(_ playerData: PlayerData)
    func updatePlayer(_ player: Player, withPlayerData playerData: PlayerData)
    func replacePlayer(at indexPath: IndexPath)
    func filterStateDidChange(to filterState: FilterState)
    func searchDidUpdate(to searchData: SearchData)
    func resetSearchData()
    func getSearchData() -> SearchData?
    func saveData()
}

final class PlayersDataModel: NSObject, PlayersDataModelProtocol {
    
    // MARK: - Properties
    
    static let shared = PlayersDataModel()
    
    weak var delegate: PlayersDataModelDelegate?
    
    var isEmptyData: Bool {
        guard let objectsCount = fetchedResultsController.fetchedObjects?.count else { return true }
        return objectsCount == 0
    }
    
    var numberOfSections: Int {
        sections.count
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Player>
    
    private var sections: [String] {
        guard let fetchedSections = fetchedResultsController.sections else { return [] }
        return fetchedSections.map { $0.name }
    }
    
    private var filterState: FilterState = .all
    private var searchData: SearchData?
    
    private let context: NSManagedObjectContext
    private let dataManager = CoreDataManager(modelName: "SportsTeam")
    
    // MARK: - Initializers
    
    private override init() {
        context = dataManager.getContext()
        fetchedResultsController = dataManager.fetchDataWithController(
            for: Player.self, sectionNameKeyPath: #keyPath(Player.position)
        )
        super.init()
        fetchedResultsController.delegate = self
        updateData()
    }
    
    // MARK: - Public methods
    
    func getPlayer(at indexPath: IndexPath) -> Player? {
        fetchedResultsController.object(at: indexPath)
    }
    
    func getTitle(atSection section: Int) -> String? {
        sections[safeIndex: section]
    }
    
    func getNumberOfPlayers(atSection section: Int) -> Int {
        guard let fetchedSections = fetchedResultsController.sections else { return 0 }
        return fetchedSections[section].numberOfObjects
    }
    
    func removePlayer(at indexPath: IndexPath) {
        if let player = getPlayer(at: indexPath) {
            dataManager.delete(object: player)
        }
    }
    
    func createPlayer(_ playerData: PlayerData) {
        let player = dataManager.createObject(from: Player.self)
        updatePlayer(player, withPlayerData: playerData)
    }
    
    func updatePlayer(_ player: Player, withPlayerData playerData: PlayerData) {
        let teamOfPlayer = dataManager.createObject(from: Team.self)
        
        teamOfPlayer.name = playerData.team
        
        player.fullName = playerData.name
        player.number = playerData.number
        player.nationality = playerData.nationality
        player.age = playerData.age
        player.team = teamOfPlayer
        player.position = playerData.position
        player.inPlay = playerData.isInPlay
        player.photo = playerData.photo
        
        dataManager.save(context: context)
        updateData(type: .update)
    }
    
    func replacePlayer(at indexPath: IndexPath) {
        if let player = getPlayer(at: indexPath) {
            player.inPlay = !player.inPlay
            dataManager.save(context: context)
            updateData(type: .update)
        }
    }
    
    func filterStateDidChange(to filterState: FilterState) {
        self.filterState = filterState
        updateData()
    }
    
    func searchDidUpdate(to searchData: SearchData) {
        self.searchData = searchData
        updateData()
    }
    
    func resetSearchData() {
        searchData = nil
        updateData()
    }
    
    func getSearchData() -> SearchData? {
        searchData
    }
    
    func saveData() {
        dataManager.save(context: context)
    }
    
    // MARK: - Private methods
    
    private func updateData(type: NSFetchedResultsChangeType? = nil) {
        fetchedResultsController.fetchRequest.predicate = makeCompoundPredicate()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        delegate?.dataDidChange(type: type)
    }
    
    private func makeCompoundPredicate() -> NSCompoundPredicate {
        
        var predicates = [NSPredicate]()
        
        if let name = searchData?.name, !name.isEmpty {
            let namePredicate = NSPredicate(format: "fullName CONTAINS[cd] '\(name)'")
            predicates.append(namePredicate)
        }
        
        if let int16Age = searchData?.age, let ageOperator = searchData?.ageOperator {
            let agePredicate = NSPredicate(format: "age \(ageOperator.rawValue) '\(String(int16Age))'")
            predicates.append(agePredicate)
        }
        
        if let team = searchData?.team {
            let teamPredicate = NSPredicate(format: "team.name == '\(team)'")
            predicates.append(teamPredicate)
        }
        
        if let position = searchData?.position {
            let positionPredicate = NSPredicate(format: "position == '\(position)'")
            predicates.append(positionPredicate)
        }
        
        if filterState == .inPlay {
            predicates.append(NSPredicate(format: "inPlay == true"))
        } else if filterState == .bench {
            predicates.append(NSPredicate(format: "inPlay == false"))
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}

// MARK: - Fetched results controller delegate

extension PlayersDataModel: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.willChangeContent()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        delegate?.didChangeSection(type: type, sectionIndex: sectionIndex)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        delegate?.didChangeObject(type: type, indexPath: indexPath, newIndexPath: newIndexPath)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didChangeContent()
    }
}
