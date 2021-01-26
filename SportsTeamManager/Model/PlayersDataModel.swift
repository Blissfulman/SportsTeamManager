//
//  PlayersDataModel.swift
//  SportsTeamManager
//
//  Created by User on 24.01.2021.
//

import Foundation

protocol PlayersDataModel {
    var numberOfPlayers: Int { get }
    
    func getPlayers() -> [Player]
    func getPlayer(at index: Int) -> Player?
    func removePlayer(at index: Int, completion: () -> Void)
    func createPlayer(name: String, number: Int16, nationality: String,
                      age: Int16, team: String, position: String, photo: Data?)
}

final class PlayersDataModelImpl: PlayersDataModel {
    
    // MARK: - Properties
    
    static let shared = PlayersDataModelImpl()
    
    let dataManager = CoreDataManager(modelName: "SportsTeam")
    
    var numberOfPlayers: Int {
        players.count
    }
    
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
        updateData()
    }
    
    // MARK: - Private methods
    
    private func updateData() {
        players = dataManager.fetchData(for: Player.self)
    }
}
