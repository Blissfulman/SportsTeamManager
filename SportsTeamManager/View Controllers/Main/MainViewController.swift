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
    
    private var playersDataModel: PlayersDataModel!
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        playersDataModel = PlayersDataModelImpl.shared
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        updateTableViewVisibility()
    }
    
    // MARK: - Actions
    
    @objc private func addPlayerAction() {
        
        let storyboard = UIStoryboard(name: PlayerViewController.identifier, bundle: nil)
      
        guard let playerVC = storyboard.instantiateViewController(
                withIdentifier: PlayerViewController.identifier
        ) as? PlayerViewController else { return }
        
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
    
    private func updateTableViewVisibility() {
        tableView.isHidden = playersDataModel.numberOfPlayers == 0 ? true : false
    }
}

// MARK: - Table view data source

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playersDataModel.numberOfPlayers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
        if let item = playersDataModel.getPlayer(at: indexPath.row) {
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

            self.playersDataModel.removePlayer(at: indexPath.row) {
                tableView.performBatchUpdates {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                self.updateTableViewVisibility()
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
