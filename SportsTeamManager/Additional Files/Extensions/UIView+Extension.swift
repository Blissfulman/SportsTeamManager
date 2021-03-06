//
//  UIView+Extension.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 29.01.2021.
//

import UIKit

extension UIView {
    
    func appear(fromValue: CGFloat = 0, toValue: CGFloat = 1, duration: Double = 0.4) {
        isHidden = false
        alpha = fromValue
        UIView.animate(withDuration: duration) {
            self.alpha = toValue
        } completion: { isEnded in
            if isEnded {
                self.alpha = toValue
            }
        }
    }
    
    func disappear(fromValue: CGFloat = 1, toValue: CGFloat = 0, duration: Double = 0.4) {
        alpha = fromValue
        UIView.animate(withDuration: duration) {
            self.alpha = toValue
        } completion: { isEnded in
            if isEnded {
                self.alpha = toValue
                self.isHidden = true
            }
        }
    }
}
