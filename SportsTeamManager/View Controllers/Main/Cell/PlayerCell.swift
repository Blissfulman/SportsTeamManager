//
//  PlayerCell.swift
//  SportsTeamManager
//
//  Created by User on 18.01.2021.
//

import UIKit

final class PlayerCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerFullNameLabel: UILabel!
    @IBOutlet weak var playerPhotoImageView: UIImageView!
    @IBOutlet weak var playerTeamLabel: UILabel!
    @IBOutlet weak var playerNationalityLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerAgeLabel: UILabel!
    
    // MARK: - Properties
    
    static let identifier = String(describing: PlayerCell.self)
    
    // MARK: - Public methods
    
    func configure(_ player: Player) {
        if let photo = player.photo as? UIImage {
            playerPhotoImageView.image = photo
        }
        playerNumberLabel.text = "\(player.number)"
        playerFullNameLabel.text = player.fullName
        playerTeamLabel.text = player.team?.name
        playerNationalityLabel.text = player.nationality
        playerPositionLabel.text = player.position
        playerAgeLabel.text = "\(player.age)"
    }
}
