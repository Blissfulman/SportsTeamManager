//
//  ContentDataModel.swift
//  SportsTeamManager
//
//  Created by User on 24.01.2021.
//

import Foundation
import CoreData

protocol ContentDataModelDelegate: AnyObject {
//    func numberOfItemsChanged()
//    func insertItem(at index: Int)
//    func errorOccurred(error: String)
    func contentDidChanged()
}

protocol ContentDataModel {
    associatedtype Item: NSManagedObject
    
    var delegate: ContentDataModelDelegate? { get set }
    
    func numberOfItems() -> Int
    func getContent() -> [Item]
    func getItem(at index: Int) -> Item?
    func removeItem(at index: Int, completion: () -> Void)
    func createPlayer(name: String, number: Int16, nationality: String,
                      age: Int16, team: String, position: String, photo: Data?)
}

final class ContentDataModelImpl<Item: NSManagedObject>: ContentDataModel {
    
//    typealias Item = Player
    
    weak var delegate: ContentDataModelDelegate?
    
    let dataManager = CoreDataManager(modelName: "SportsTeam")
    
    private lazy var items = [Item]()
    
    init() {
        updateDataOfContent()
    }
    
    // MARK: - Public methods
    
    func numberOfItems() -> Int {
        items.count
    }
    
    func getContent() -> [Item] {
        items
    }
    
    func getItem(at index: Int) -> Item? {
        items[index]
    }

    func removeItem(at index: Int, completion: () -> Void) {
        if let _ = getItem(at: index) {
            dataManager.delete(object: items[index])
            items.remove(at: index)
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
        items = dataManager.fetchData(for: Item.self)
    }
}
