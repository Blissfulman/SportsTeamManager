//
//  MainViewController.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 17.01.2021.
//

import UIKit
import CoreData

final class MainViewController: UIViewController {
    
    // MARK: - Nested types
    
    private enum SegueID {
        static let toNewPlayer = "toNewPlayer"
        static let toEditPlayer = "toEditPlayer"
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    static let identifier = String(describing: MainViewController.self)
    
    private let viewModel: MainViewModelProtocol = MainViewModel()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        updateTableViewVisibility()
    }
    
    // MARK: - Actions
    
    @IBAction func searchBarButtonTapped(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: SearchViewController.identifier, bundle: nil)
        
        guard let searchViewController = storyboard.instantiateInitialViewController()
                as? SearchViewController else { return }
        
        searchViewController.modalTransitionStyle = .crossDissolve
        searchViewController.modalPresentationStyle = .overCurrentContext
        searchViewController.viewModel = SearchViewModel(searchData: viewModel.getSearchData())
        
        present(searchViewController, animated: true, completion: nil)
    }
    
    @IBAction func stateSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.stateSelectedSegmentIndex = sender.selectedSegmentIndex
    }
    
    // MARK: - Private methods
    
    private func updateTableViewVisibility() {
        tableView.isHidden = viewModel.isHiddenTableView
    }
}

// MARK: - Table view data source

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.getTitle(atSection: section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfPlayers(atSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
        if let player = viewModel.getPlayer(at: indexPath) {
            cell.viewModel = PlayerCellViewModel(player: player)
        }
        return cell
    }
}

// MARK: - Table view delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cellPlayer = viewModel.getPlayer(at: indexPath)
        let isInPlayPlayer = cellPlayer?.inPlay ?? true
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, _  in
            
            guard let self = self else { return }
            
            self.viewModel.removePlayer(at: indexPath)
        }
        
        let replacementAction = UIContextualAction(style: .normal,
                                                   title: isInPlayPlayer ? "To bench" : "To play") {
            [weak self] _, _, completion in
            
            guard let self = self else { return }
            
            self.viewModel.replacePlayer(at: indexPath)
            completion(true)
        }
        replacementAction.backgroundColor = isInPlayPlayer ? Color.bench : Color.inPlay
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            [weak self] _, _, completion in
            
            guard let self = self else { return }
            
            self.performSegue(withIdentifier: SegueID.toEditPlayer, sender: cellPlayer)
            completion(true)
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
        
        let player = sender as? Player
        playerVC.viewModel = PlayerViewModel(player: player)
        
        if segue.identifier == SegueID.toNewPlayer {
            playerVC.title = "New player"
        } else if segue.identifier == SegueID.toEditPlayer {
            playerVC.title = "Edit player"
        } 
    }
}

// MARK: - Main view model delegate

extension MainViewController: MainViewModelDelegate {
    
    func dataDidChange(type: NSFetchedResultsChangeType?) {
        // Если изменение данных не было связано с изменениями отдельных ячеек, то требуется перегрузить всю таблицу
        if type == nil {
            tableView.reloadData()
            updateTableViewVisibility()
        }
    }
    
    func willChangeContent() {
        tableView.beginUpdates()
    }
    
    func didChangeSection(type: NSFetchedResultsChangeType, sectionIndex: Int) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
        default:
            return
        }
    }
    
    func didChangeObject(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! PlayerCell
                if let player = viewModel.getPlayer(at: indexPath) {
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
        updateTableViewVisibility()
    }
    
    func didChangeContent() {
        tableView.endUpdates()
    }
}
