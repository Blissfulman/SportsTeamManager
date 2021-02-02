//
//  PlayerCell.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 18.01.2021.
//

import UIKit

final class PlayerCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerFullNameLabel: UILabel!
    @IBOutlet weak var playerStateLabel: UILabel!
    @IBOutlet weak var playerPhotoImageView: UIImageView!
    @IBOutlet weak var playerTeamLabel: UILabel!
    @IBOutlet weak var playerNationalityLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerAgeLabel: UILabel!
    
    // MARK: - Properties
    
    static let identifier = String(describing: PlayerCell.self)
    
    // MARK: - Lyfecycle metods
    
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
    
    // MARK: - Public methods
    
    func configure(_ player: Player) {
        if let photo = UIImage(data: player.photo ?? Data()) {
            playerPhotoImageView.image = photo
        }
        playerNumberLabel.text = "\(player.number)"
        playerFullNameLabel.text = player.fullName
        playerStateLabel.text = player.inPlay
            ? FilterState.inPlay.rawValue
            : FilterState.bench.rawValue
        playerStateLabel.textColor = player.inPlay ? Color.inPlay : Color.bench
        playerTeamLabel.text = player.team?.name
        playerNationalityLabel.text = player.nationality
        playerPositionLabel.text = player.position
        playerAgeLabel.text = "\(player.age)"
    }
}
