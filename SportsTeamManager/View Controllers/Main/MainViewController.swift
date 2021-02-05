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
        
        updateTableViewVisibility()
    }
    
    // MARK: - Actions
    
    @IBAction func searchBarButtonTapped(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: SearchViewController.identifier, bundle: nil)
      
        guard let searchViewController = storyboard.instantiateInitialViewController()
                as? SearchViewController else { return }
        
        searchViewController.modalTransitionStyle = .crossDissolve
        searchViewController.modalPresentationStyle = .overCurrentContext
        
        present(searchViewController, animated: true, completion: nil)
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
        
        if let player = playersDataModel.getPlayer(at: indexPath) {
            cell.viewModel = PlayerCellViewModel(player: player)
        }
        return cell
    }
}

// MARK: - Table view delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedPlayer = playersDataModel.getPlayer(at: indexPath)
        let isInPlay = selectedPlayer?.inPlay ?? true
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, _  in
            
            guard let self = self else { return }
            
            self.playersDataModel.removePlayer(at: indexPath)
        }
        
        let replacementAction = UIContextualAction(style: .destructive,
                                                   title: isInPlay ? "To bench" : "To play") {
            [weak self] _, _, _  in
            
            guard let self = self, let player = selectedPlayer else { return }
            
            self.playersDataModel.replacePlayer(player, isInPlay: isInPlay)
        }
        replacementAction.backgroundColor = isInPlay ? Color.bench : Color.inPlay
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            [weak self] _, _, _  in
            
            guard let self = self else { return }
                        
            self.performSegue(withIdentifier: "toEditPlayer", sender: selectedPlayer)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [editAction, replacementAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
}

// MARK: - Navigation

extension MainViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let playerVC = segue.destination as? PlayerViewController else { return }
        
        if segue.identifier == "toNewPlayer" {
            playerVC.title = "New player"
        } else if segue.identifier == "toEditPlayer" {
            playerVC.title = "Edit player"
            if let editingPlayer = sender as? Player {
                playerVC.editingPlayer = editingPlayer
            }
        }
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
                    cell.viewModel = PlayerCellViewModel(player: player)
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
