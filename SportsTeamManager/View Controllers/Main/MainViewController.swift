//
//  MainViewController.swift
//  SportsTeamManager
//
//  Created by User on 17.01.2021.
//

import UIKit

final class MainViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    static let identifier = String(describing: MainViewController.self)
    
    var dataManager: CoreDataManager!
    
//    private var players = [Player]()
    
    private let contentDataModel = ContentDataModelImpl()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        updateTableViewVisible()
    }
    
    // MARK: - Actions
    
    @objc private func addPlayerAction() {
        
        let storyboard = UIStoryboard(name: PlayerViewController.identifier, bundle: nil)
      
        guard let playerVC = storyboard.instantiateViewController(
                withIdentifier: PlayerViewController.identifier
        ) as? PlayerViewController else { return }
        
//        playerVC.dataManager = dataManager
        navigationController?.pushViewController(playerVC, animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Team players"
        tableView.separatorInset = .zero
        
        let addPlayerBarButton = UIBarButtonItem(barButtonSystemItem: .add,
                                                 target: self,
                                                 action: #selector(addPlayerAction))
        navigationItem.rightBarButtonItem = addPlayerBarButton
    }
    
    // MARK: - Private methods
    
    private func updateTableViewVisible() {
//        players = dataManager.fetchData(for: Player.self)
        tableView.isHidden = contentDataModel.getContent().isEmpty ? true : false
    }
}

// MARK: - Table view data source

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentDataModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        if let item = contentDataModel.getItem(at: indexPath.row) {
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

//            self.dataManager.delete(object: self.players[indexPath.row])
            self.contentDataModel.removeItem(at: indexPath.row) {
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.updateTableViewVisible()
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
