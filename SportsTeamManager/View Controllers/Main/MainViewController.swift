//
//  MainViewController.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 17.01.2021.
//

import UIKit
import CoreData

final class MainViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    static let identifier = String(describing: MainViewController.self)
    
    private var playersDataModel: PlayersDataModelProtocol!
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        playersDataModel = PlayersDataModel.shared
        playersDataModel.delegate = self
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Actions
    
    @objc private func searchAction() {
        
        let storyboard = UIStoryboard(name: SearchViewController.identifier, bundle: nil)
      
        guard let searchViewController = storyboard.instantiateInitialViewController()
                as? SearchViewController else { return }
        
        searchViewController.modalTransitionStyle = .crossDissolve
        searchViewController.modalPresentationStyle = .overCurrentContext
        
        present(searchViewController, animated: true, completion: nil)
    }
    
    @objc private func addPlayerAction() {
        
        let storyboard = UIStoryboard(name: PlayerViewController.identifier, bundle: nil)
      
        guard let playerVC = storyboard.instantiateInitialViewController()
                as? PlayerViewController else { return }
        playerVC.title = "New player"
        
        navigationController?.pushViewController(playerVC, animated: true)
    }
    
    @IBAction func stateSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            playersDataModel.filterStateDidChanged(to: .all)
        case 1:
            playersDataModel.filterStateDidChanged(to: .inPlay)
        default:
            playersDataModel.filterStateDidChanged(to: .bench)
        }
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Team players"
        updateTableViewVisibility()
        
        let addPlayerBarButton = UIBarButtonItem(barButtonSystemItem: .add,
                                                 target: self,
                                                 action: #selector(addPlayerAction))
        navigationItem.rightBarButtonItem = addPlayerBarButton
        
        let searchBarButton = UIBarButtonItem(barButtonSystemItem: .search,
                                              target: self,
                                              action: #selector(searchAction))
        navigationItem.leftBarButtonItem = searchBarButton
    }
    
    // MARK: - Private methods
    
    private func updateTableViewVisibility() {
        tableView.isHidden = playersDataModel.isEmptyData
    }
}

// MARK: - Table view data source

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        playersDataModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        playersDataModel.getSectionTitle(for: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playersDataModel.getNumberOfPlayers(atSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
        if let item = playersDataModel.getPlayer(at: indexPath) {
            cell.configure(item)
        }
        return cell
    }
}

// MARK: - Table view delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, _  in
            
            guard let self = self else { return }
            
            self.playersDataModel.removePlayer(at: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            [weak self] _, _, _  in
            
            guard let self = self else { return }
            
            let selectedPlayer = self.playersDataModel.getPlayer(at: indexPath)
            
            let storyboard = UIStoryboard(name: PlayerViewController.identifier, bundle: nil)
          
            guard let playerVC = storyboard.instantiateInitialViewController()
                    as? PlayerViewController else { return }
            
            playerVC.editingPlayer = selectedPlayer
            playerVC.title = "Edit player"
            
            self.navigationController?.pushViewController(playerVC, animated: true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        editAction.backgroundColor = .orange
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}

// MARK: - Players data model delegate

extension MainViewController: PlayersDataModelDelegate {
    
    func dataDidChange() {
        tableView.reloadData()
        updateTableViewVisibility()
    }
    
    func willChangeContent() {
        tableView.beginUpdates()
    }
    
    func didChangeSection(type: NSFetchedResultsChangeType, sectionIndex: Int) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default:
            return
        }
    }
    
    func didChangeObject(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
                updateTableViewVisibility()
            }

        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                updateTableViewVisibility()
            }

        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! PlayerCell
                if let player = playersDataModel.getPlayer(at: indexPath) {
                    cell.configure(player)
                }
            }

        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        @unknown default:
            fatalError(debugDescription)
        }
    }
    
    func didChangeContent() {
        tableView.endUpdates()
    }
}
