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
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: PlayerCell.identifier, for: indexPath) as? PlayerCell else {
            return UITableViewCell()
        }
        
        cell.configure()
        
        return cell
    }
}
