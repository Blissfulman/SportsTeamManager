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
    func configure() {
        playerFullNameLabel.text = "Carles Puyol"
        playerTeamLabel.text = "Barcelona"
        playerNationalityLabel.text = "Spain"
        playerPositionLabel.text = "Defender"
        playerAgeLabel.text = "33"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
