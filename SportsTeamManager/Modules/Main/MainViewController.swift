//
//  MainViewController.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 17.01.2021.
//

import UIKit
import CoreData.NSFetchedResultsController

final class MainViewController: UIViewController {
    
    // MARK: - Nested types
    
    private enum SegueID {
        static let toNewPlayer = "toNewPlayer"
        static let toEditPlayer = "toEditPlayer"
    }
    
    // MARK: - Static properties
    
    static let identifier = String(describing: MainViewController.self)
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let viewModel: MainViewModelProtocol = MainViewModel()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        updateTableViewVisibility()
    }
    
    // MARK: - Actions
    
    @IBAction private func searchBarButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: SearchViewController.identifier, bundle: nil)
        
        guard let searchViewController = storyboard.instantiateInitialViewController()
                as? SearchViewController else { return }
        
        searchViewController.modalTransitionStyle = .crossDissolve
        searchViewController.modalPresentationStyle = .overCurrentContext
        searchViewController.viewModel = viewModel.getSearchViewModel()
        present(searchViewController, animated: true, completion: nil)
    }
    
    @IBAction private func stateSegmentedControlValueChanged(_ sender: UISegmentedControl) {
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
            withIdentifier: PlayerCell.identifier, for: indexPath
        ) as? PlayerCell else {
            return UITableViewCell()
        }
        
        cell.viewModel = viewModel.getPlayerCellViewModel(at: indexPath)
        return cell
    }
}

// MARK: - Table view delegate

extension MainViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.viewModel.removePlayer(at: indexPath)
            completion(true)
        }
        
        let isInPlayPlayer = viewModel.getPlayerStatus(at: indexPath)
        
        let replacementAction = UIContextualAction(
            style: .normal,
            title: isInPlayPlayer ? "To bench" : "To play"
        ) { [weak self] _, _, completion in
            
            self?.viewModel.replacePlayer(at: indexPath)
            completion(true)
        }
        replacementAction.backgroundColor = isInPlayPlayer ? Color.bench : Color.inPlay
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            self?.performSegue(withIdentifier: SegueID.toEditPlayer, sender: indexPath)
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
        
        playerVC.viewModel = viewModel.getPlayerViewModel(at: sender as? IndexPath)
        
        if segue.identifier == SegueID.toNewPlayer {
            playerVC.title = "New player"
        } else if segue.identifier == SegueID.toEditPlayer {
            playerVC.title = "Edit player"
        } 
    }
}

// MARK: - MainViewModelDelegate

extension MainViewController: MainViewModelDelegate {
    
    func dataDidChange(type: NSFetchedResultsChangeType?) {
        // Если изменение данных не было связано с изменениями отдельных ячеек, то требуется перезагрузить всю таблицу
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
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! PlayerCell
                cell.viewModel = viewModel.getPlayerCellViewModel(at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
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
