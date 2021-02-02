//
//  PlayersDataModel.swift
//  SportsTeamManager
//
//  Created by User on 24.01.2021.
//

import Foundation

typealias PlayerData = (name: String, number: Int16, nationality: String, age: Int16,
                        team: String, position: String, inPlay: Bool, photo: Data?)
typealias PredicateData = (name: String?, age: Int16?, ageOperator: String,
                           team: String?, position: String?)

// MARK: - Protocols

protocol PlayersDataModelDelegate: AnyObject {
    func dataDidChanged()
}

protocol PlayersDataModel {
    var delegate: PlayersDataModelDelegate? { get set }
    var numberOfPlayers: Int { get }
    
    func getPlayers() -> [Player]
    func getPlayer(at index: Int) -> Player?
    func removePlayer(at index: Int, completion: () -> Void)
    func createPlayer(_ playerData: PlayerData)
    func filterStateDidChanged(to filterState: FilterState)
    func predicateDidChanged(_ predicateData: PredicateData)
    func resetPredicate()
    func saveData()
}

final class PlayersDataModelImpl: PlayersDataModel {
    
    // MARK: - Properties
    
    static let shared = PlayersDataModelImpl()
    
    weak var delegate: PlayersDataModelDelegate?
    
    var numberOfPlayers: Int {
        players.count
    }
    
    private var players = [Player]()
    private var filterState: FilterState = .all
    private var predicate: NSCompoundPredicate?
    
    private let dataManager = CoreDataManager(modelName: "SportsTeam")
    
    // MARK: - Initializators
    
    private init() {
        updateData()
    }
    
    // MARK: - Public methods
    
    func getPlayers() -> [Player] {
        players
    }
    
    func getPlayer(at index: Int) -> Player? {
        players[safeIndex: index]
    }
    
    func removePlayer(at index: Int, completion: () -> Void) {
        if let _ = getPlayer(at: index) {
            dataManager.delete(object: players[index])
            players.remove(at: index)
            completion()
        }
    }
    
    func createPlayer(_ playerData: PlayerData) {
        
        let context = dataManager.getContext()
        let player = dataManager.createObject(from: Player.self)
        let teamOfPlayer = dataManager.createObject(from: Team.self)
        
        teamOfPlayer.name = playerData.team
        
        player.fullName = playerData.name
        player.number = playerData.number
        player.nationality = playerData.nationality
        player.age = playerData.age
        player.team = teamOfPlayer
        player.position = playerData.position
        player.inPlay = playerData.inPlay
        player.photo = playerData.photo
        
        dataManager.save(context: context)
        updateData()
    }
    
    func filterStateDidChanged(to filterState: FilterState) {
        self.filterState = filterState
        updateData()
    }
    
    func predicateDidChanged(_ predicateData: PredicateData) {
        predicate = makeCompoundPredicate(predicateData)
        updateData()
    }
    
    func resetPredicate() {
        predicate = nil
        updateData()
    }
    
    func saveData() {
        let context = dataManager.getContext()
        dataManager.save(context: context)
    }
    
    // MARK: - Private methods
    
    private func updateData() {
        players = dataManager.fetchData(for: Player.self, predicate: predicate)
        
        if filterState == .inPlay,
           let inPlayPlayers = players.first?.value(forKey: "inPlayPlayers") as? [Player] {
            players = players.filter { inPlayPlayers.contains($0) }
        }
        
        if filterState == .bench,
           let benchPlayers = players.first?.value(forKey: "benchPlayers") as? [Player]  {
            players = players.filter { benchPlayers.contains($0) }
        }
        
        delegate?.dataDidChanged()
    }
    
    private func makeCompoundPredicate(_ predicateData: PredicateData) -> NSCompoundPredicate {
        
        var predicates = [NSPredicate]()
        
        if let name = predicateData.name, !name.isEmpty {
            let namePredicate = NSPredicate(format: "fullName CONTAINS[cd] '\(name)'")
            predicates.append(namePredicate)
        }
        
        if let int16Age = predicateData.age {
            let agePredicate = NSPredicate(format: "age \(predicateData.ageOperator) '\(String(int16Age))'")
            predicates.append(agePredicate)
        }
        
        if let team = predicateData.team {
            let teamPredicate = NSPredicate(format: "team.name == '\(team)'")
            predicates.append(teamPredicate)
        }
        
        if let position = predicateData.position {
            let positionPredicate = NSPredicate(format: "position == '\(position)'")
            predicates.append(positionPredicate)
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
