//
//  Constants.swift
//  SportsTeamManager
//
//  Created by User on 29.01.2021.
//

import UIKit

enum Color {
    static let main = UIColor(named: "main")
    static let mainLight = UIColor(named: "mainLight")
    static let disabled = UIColor(named: "disabled")
    static let inPlay = UIColor(named: "inPlay")
    static let bench = UIColor(named: "bench")
    static let shadow = UIColor.black
}

enum DataConstants {
    
    static let teams = ["Real", "Barcelona", "Chelsea", "Roma", "CSKA", "Monaco",
                        "Manchester Unated", "Liverpool", "Bavaria", "Juventus"]
    static let positions = ["Forward", "Halfback", "Defender", "Keeper"]
}

enum UIConstants {
    static let buttonCornerRadius: CGFloat = 8
    static let viewCornerRadius: CGFloat = 15
    static let shadowRadius: CGFloat = 20
    static let shadowOpacity: Float = 0.4
}
