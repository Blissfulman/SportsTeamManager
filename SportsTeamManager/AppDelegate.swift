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
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: MainViewController.identifier, bundle: nil)
        
        guard let mainVC = storyboard.instantiateViewController(
                withIdentifier: MainViewController.identifier
        ) as? MainViewController else { return false }
        
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: mainVC)
        window?.makeKeyAndVisible()
        
        mainVC.navigationController?.navigationBar.tintColor = Color.main
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        let playersDataModel = PlayersDataModelImpl.shared
        playersDataModel.saveData()
    }
}

