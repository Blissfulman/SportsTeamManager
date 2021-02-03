//
//  PlayersDataModel.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 24.01.2021.
//

import Foundation

typealias PlayerData = (name: String, number: Int16, nationality: String, age: Int16,
                        team: String, position: String, inPlay: Bool, photo: Data?)
typealias SearchData = (name: String?, age: Int16?, ageOperator: AgeOperatorState,
                        team: String?, position: String?)

// MARK: - Protocols

protocol PlayersDataModelDelegate: AnyObject {
    func dataDidChanged()
}

protocol PlayersDataModelProtocol {
    var delegate: PlayersDataModelDelegate? { get set }
    var numberOfPlayers: Int { get }
    
    func getPlayers() -> [Player]
    func getPlayer(at index: Int) -> Player?
    func removePlayer(at index: Int, completion: () -> Void)
    func createPlayer(_ playerData: PlayerData)
    func filterStateDidChanged(to filterState: FilterState)
    func searchDidUpdated(to searchData: SearchData)
    func resetSearchData()
    func getSearchData() -> SearchData?
    func saveData()
}

final class PlayersDataModel: PlayersDataModelProtocol {
    
    // MARK: - Properties
    
    static let shared = PlayersDataModel()
    
    weak var delegate: PlayersDataModelDelegate?
    
    var numberOfPlayers: Int {
        players.count
    }
    
    private var players = [Player]()
    private var filterState: FilterState = .all
    private var searchData: SearchData?
    
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
    
    func searchDidUpdated(to searchData: SearchData) {
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
        let context = dataManager.getContext()
        dataManager.save(context: context)
    }
    
    // MARK: - Private methods
    
    private func updateData() {
        let predicate = makeCompoundPredicate()
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
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
