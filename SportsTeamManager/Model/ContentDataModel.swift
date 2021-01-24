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
}

final class ContentDataModelImpl<Item: NSManagedObject>: ContentDataModel {
    
    typealias Item = Player
    
    weak var delegate: ContentDataModelDelegate?
    
    let dataManager = CoreDataManager(modelName: "SportsTeam")
    
    private lazy var items: [Player] = {
        dataManager.fetchData(for: Player.self)
    }()
    
    func numberOfItems() -> Int {
        items.count
    }
    
    func getContent() -> [Player] {
        items
    }
    
    func getItem(at index: Int) -> Player? {
        items[index]
    }

    func removeItem(at index: Int, completion: () -> Void) {
        if let deletingItem = getItem(at: index) {
            dataManager.delete(object: deletingItem)
            completion()
        }
    }
}
