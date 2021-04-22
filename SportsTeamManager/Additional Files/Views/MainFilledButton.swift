//
//  MainFilledButton.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 21.04.2021.
//

import UIKit

final class MainFilledButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = UIConstants.buttonCornerRadius
        clipsToBounds = true
        titleLabel?.textColor = Color.white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = isEnabled ? Color.main : Color.disabled
    }
}
