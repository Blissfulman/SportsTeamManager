//
//  PlayerCell.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 18.01.2021.
//

import UIKit

final class PlayerCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var playerNumberLabel: UILabel!
    @IBOutlet private weak var playerFullNameLabel: UILabel!
    @IBOutlet private weak var playerStateLabel: UILabel!
    @IBOutlet private weak var playerPhotoImageView: UIImageView!
    @IBOutlet private weak var playerTeamLabel: UILabel!
    @IBOutlet private weak var playerNationalityLabel: UILabel!
    @IBOutlet private weak var playerPositionLabel: UILabel!
    @IBOutlet private weak var playerAgeLabel: UILabel!
    
    // MARK: - Properties
    
    static let identifier = String(describing: PlayerCell.self)
    
    var viewModel: PlayerCellViewModelProtocol! {
        didSet {
            playerPhotoImageView.image = UIImage(data: viewModel.photo ?? Data())
            playerNumberLabel.text = viewModel.number
            playerFullNameLabel.text = viewModel.name
            playerStateLabel.text = viewModel.state
            playerStateLabel.textColor = viewModel.isInPlay ? Color.inPlay : Color.bench
            playerTeamLabel.text = viewModel.team
            playerNationalityLabel.text = viewModel.nationality
            playerPositionLabel.text = viewModel.position
            playerAgeLabel.text = viewModel.age
        }
    }
    
    // MARK: - Lifecycle methods
    
    override func prepareForReuse() {
        playerPhotoImageView.image = nil
        playerNumberLabel.text = nil
        playerFullNameLabel.text = nil
        playerStateLabel.text = nil
        playerTeamLabel.text = nil
        playerNationalityLabel.text = nil
        playerPositionLabel.text = nil
        playerAgeLabel.text = nil
    }
}
