//
//  PlayersDataModel.swift
//  SportsTeamManager
//
//  Created by User on 24.01.2021.
//

import Foundation

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
    func createPlayer(name: String, number: Int16, nationality: String, age: Int16,
                      team: String, position: String, inPlay: Bool, photo: Data?)
    func filterStateDidChanged(to filterState: FilterState)
}

final class PlayersDataModelImpl: PlayersDataModel {
    
    // MARK: - Properties
    
    static let shared = PlayersDataModelImpl()
    
    weak var delegate: PlayersDataModelDelegate?
    
    var numberOfPlayers: Int {
        players.count
    }
    
    private let dataManager = CoreDataManager(modelName: "SportsTeam")
    private var filterState: FilterState = .all
    private var players = [Player]()
    
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
    
    func createPlayer(name: String, number: Int16, nationality: String, age: Int16,
                      team: String, position: String, inPlay: Bool, photo: Data?) {
        
        let context = dataManager.getContext()
        let player = dataManager.createObject(from: Player.self)
        let teamOfPlayer = dataManager.createObject(from: Team.self)
        
        teamOfPlayer.name = team
        
        player.fullName = name
        player.number = number
        player.nationality = nationality
        player.age = age
        player.team = teamOfPlayer
        player.position = position
        player.inPlay = inPlay
        player.photo = photo
        
        dataManager.save(context: context)
        updateData()
    }
    
    func filterStateDidChanged(to filterState: FilterState) {
        self.filterState = filterState
        updateData()
    }
    
//    func makeCompoundPredicate(state: FilterState) -> NSCompoundPredicate {
//        var predicates = [NSPredicate]()
//
//        switch state {
//        case .inPlay:
//            predicates.append(NSPredicate(format: "inPlay == true"))
//        case .bench:
//            predicates.append(NSPredicate(format: "inPlay == false"))
//        default:
//            break
//        }
//
//        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//    }
    
    // MARK: - Private methods
    
    private func updateData() {
        players = dataManager.fetchData(for: Player.self)
        
        if filterState == .inPlay,
           let inPlayPlayers = players.first?.value(forKey: "inPlayPlayers") as? [Player] {
            players = inPlayPlayers
        }
        
        if filterState == .bench,
           let benchPlayers = players.first?.value(forKey: "benchPlayers") as? [Player]  {
            players = benchPlayers
        }
        
        delegate?.dataDidChanged()
    }
}
