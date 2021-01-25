//
//  PlayersDataModel.swift
//  SportsTeamManager
//
//  Created by User on 24.01.2021.
//

import Foundation

protocol PlayersDataModelDelegate: AnyObject {
//    func numberOfItemsChanged()
//    func insertItem(at index: Int)
//    func errorOccurred(error: String)
    func contentDidChanged()
}

protocol PlayersDataModel {
    
    var delegate: PlayersDataModelDelegate? { get set }
    var numberOfPlayers: Int { get }
    
    func getPlayers() -> [Player]
    func getPlayer(at index: Int) -> Player?
    func removePlayer(at index: Int, completion: () -> Void)
    func createPlayer(name: String, number: Int16, nationality: String,
                      age: Int16, team: String, position: String, photo: Data?)
}

final class PlayersDataModelImpl: PlayersDataModel {
    
    // MARK: - Properties
    
    weak var delegate: PlayersDataModelDelegate?
    
    let dataManager = CoreDataManager(modelName: "SportsTeam")
    
    private var players = [Player]()
    
    var numberOfPlayers: Int {
        players.count
    }
    
    // MARK: - Initializators
    
    init() {
        updateDataOfContent()
    }
    
    // MARK: - Public methods
    
    func getPlayers() -> [Player] {
        players
    }
    
    func getPlayer(at index: Int) -> Player? {
        players[index]
    }

    func removePlayer(at index: Int, completion: () -> Void) {
        if let _ = getPlayer(at: index) {
            dataManager.delete(object: players[index])
            players.remove(at: index)
            completion()
        }
    }
    
    func createPlayer(name: String, number: Int16, nationality: String,
                      age: Int16, team: String, position: String, photo: Data?) {
        
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
        player.photo = photo
        
        dataManager.save(context: context)
        updateDataOfContent()
    }
    
    // MARK: - Private methods
    
    private func updateDataOfContent() {
        players = dataManager.fetchData(for: Player.self)
    }
}
