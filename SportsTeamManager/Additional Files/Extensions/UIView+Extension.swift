//
//  UIView+Extension.swift
//  SportsTeamManager
//
//  Created by User on 29.01.2021.
//

import UIKit

extension UIView {
    
    func appear(fromValue: CGFloat = 0, toValue: CGFloat = 1, duration: Double = 0.4) {
        isHidden = false
        self.alpha = fromValue
        UIView.animate(withDuration: duration, animations: {
            self.alpha = toValue
        }) { _ in
            self.alpha = toValue
        }
    }
    
    func disappear(fromValue: CGFloat = 1, toValue: CGFloat = 0, duration: Double = 0.4) {
        self.alpha = fromValue
        UIView.animate(withDuration: duration, animations: {
            self.alpha = toValue
        }) { _ in
            self.alpha = toValue
            self.isHidden = true
        }
    }
}
