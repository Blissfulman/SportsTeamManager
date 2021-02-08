//
//  MainViewModel.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 06.02.2021.
//

import Foundation
import CoreData.NSFetchedResultsController

// MARK: - Protocols

protocol MainViewModelDelegate: AnyObject {
    func dataDidChange(type: NSFetchedResultsChangeType?)
    func willChangeContent()
    func didChangeSection(type: NSFetchedResultsChangeType, sectionIndex: Int)
    func didChangeObject(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)
    func didChangeContent()
}

protocol MainViewModelProtocol: AnyObject {
    var delegate: MainViewModelDelegate? { get set }
    var stateSelectedSegmentIndex: Int { get set }
    var isHiddenTableView: Bool { get }
    var numberOfSections: Int { get }
    
    init()
    
    func getPlayerCellViewModel(at indexPath: IndexPath) -> PlayerCellViewModel?
    func getSearchViewModel() -> SearchViewModel
    func getPlayerViewModel(at indexPath: IndexPath?) -> PlayerViewModel
    func getTitle(atSection section: Int) -> String?
    func getNumberOfPlayers(atSection section: Int) -> Int
    func removePlayer(at indexPath: IndexPath)
    func replacePlayer(at indexPath: IndexPath)
    func getPlayerStatus(at indexPath: IndexPath) -> Bool
}

final class MainViewModel: MainViewModelProtocol {
    
    // MARK: - Properties
    
    weak var delegate: MainViewModelDelegate?
    
    var stateSelectedSegmentIndex: Int {
        get {
            switch filterState {
            case .all:
                return 0
            case .inPlay:
                return 1
            case .bench:
                return 2
            }
        } set {
            switch newValue {
            case 0:
                filterState = .all
            case 1:
                filterState = .inPlay
            default:
                filterState = .bench
            }
        }
    }
    
    var isHiddenTableView: Bool {
        playersDataModel.isEmptyData
    }
    
    var numberOfSections: Int {
        playersDataModel.numberOfSections
    }
    
    private var filterState: FilterState = .all {
        didSet {
            playersDataModel.filterStateDidChange(to: filterState)
        }
    }
    private var playersDataModel: PlayersDataModelProtocol = PlayersDataModel.shared
    
    // MARK: - Initializers
    
    init() {
        playersDataModel.delegate = self
    }
    
    // MARK: - Public methods
    
    func getPlayerCellViewModel(at indexPath: IndexPath) -> PlayerCellViewModel? {
        guard let player = playersDataModel.getPlayer(at: indexPath) else { return nil }
        return PlayerCellViewModel(player: player)
    }
    
    func getSearchViewModel() -> SearchViewModel {
        guard let searchData = playersDataModel.getSearchData() else {
            return SearchViewModel()
        }
        return SearchViewModel(searchData: searchData)
    }
    
    func getPlayerViewModel(at indexPath: IndexPath?) -> PlayerViewModel {
        guard let indexPath = indexPath,
              let player = playersDataModel.getPlayer(at: indexPath) else {
            return PlayerViewModel()
        }
        return PlayerViewModel(player: player)
    }
    
    func getTitle(atSection section: Int) -> String? {
        playersDataModel.getTitle(atSection: section)
    }
    
    func getNumberOfPlayers(atSection section: Int) -> Int {
        playersDataModel.getNumberOfPlayers(atSection: section)
    }
    
    func removePlayer(at indexPath: IndexPath) {
        playersDataModel.removePlayer(at: indexPath)
    }
    
    func replacePlayer(at indexPath: IndexPath) {
        playersDataModel.replacePlayer(at: indexPath)
    }
    
    func getPlayerStatus(at indexPath: IndexPath) -> Bool {
        guard let player = playersDataModel.getPlayer(at: indexPath) else { return true }
        return player.inPlay
    }
}

extension MainViewModel: PlayersDataModelDelegate {
    
    func dataDidChange(type: NSFetchedResultsChangeType?) {
        delegate?.dataDidChange(type: type)
    }
    
    func willChangeContent() {
        delegate?.willChangeContent()
    }
    
    func didChangeSection(type: NSFetchedResultsChangeType, sectionIndex: Int) {
        delegate?.didChangeSection(type: type, sectionIndex: sectionIndex)
    }
    
    func didChangeObject(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?) {
        delegate?.didChangeObject(type: type, indexPath: indexPath, newIndexPath: newIndexPath)
    }
    
    func didChangeContent() {
        delegate?.didChangeContent()
    }
}
