//
//  AppDelegate.swift
//  SportsTeamManager
//
//  Created by User on 17.01.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let dataManager = CoreDataManager(modelName: "SportsTeam")

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "PlayersViewController", bundle: nil)
      
        guard let mainVC = storyboard.instantiateViewController(withIdentifier: "PlayersViewController")
                as? PlayersViewController else {
            return false
        }
        mainVC.dataManager = dataManager
        
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: mainVC)
        window?.makeKeyAndVisible()
        
        return true
    }
}

