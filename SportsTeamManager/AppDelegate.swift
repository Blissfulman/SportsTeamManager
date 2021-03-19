//
//  AppDelegate.swift
//  SportsTeamManager
//
//  Created by Evgeny Novgorodov on 17.01.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "MainFlow", bundle: nil)
        
        guard let rootVC = storyboard.instantiateInitialViewController() else { return false }
        
        window = UIWindow()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let playersDataManager: PlayersDataManagerProtocol = PlayersDataManager.shared
        playersDataManager.saveData()
    }
}

