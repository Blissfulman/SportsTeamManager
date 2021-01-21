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
    
    private var players = [Player]()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func addPlayerAction() {

        let storyboard = UIStoryboard(name: PlayerViewController.identifier, bundle: nil)
      
        guard let playerVC = storyboard.instantiateViewController(
                withIdentifier: PlayerViewController.identifier
        ) as? PlayerViewController else { return }
        
        playerVC.dataManager = dataManager
        
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
    
    private func fetchData() {
        players = dataManager.fetchData(for: Player.self)
        tableView.isHidden = players.count > 0 ? false : true
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
        cell.configure(players[indexPath.row])
        
        return cell
    }
}
