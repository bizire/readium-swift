//
//  AppDelegate.swift
//  r2-testapp-swift
//
//  Created by Alexandre Camilleri on 6/12/17.
//
//  Copyright 2018 European Digital Reading Lab. All rights reserved.
//  Licensed to the Readium Foundation under one or more contributor license agreements.
//  Use of this source code is governed by a BSD-style license which is detailed in the
//  LICENSE file present in the project repository where this source code is maintained.
//

import GoogleMobileAds
import Combine
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate {
    
    var window: UIWindow?
    
    private var app: AppModule!
    private var subscriptions = Set<AnyCancellable>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = try! AppModule()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        func makeItem(title: String, image: String) -> UITabBarItem {
            return UITabBarItem(
                title: NSLocalizedString(title, comment: "Library tab title"),
                image: UIImage(named: image),
                tag: 0
            )
        }
        
        // Library
        let libraryViewController = app.library.rootViewController
        libraryViewController.tabBarItem = makeItem(title: "bookshelf_tab", image: "bookshelf")
        
        // OPDS Feeds
        let opdsViewController = app.opds.rootViewController
        opdsViewController.tabBarItem = makeItem(title: "catalogs_tab", image: "catalogs")
        
        // About
        let aboutViewController = app.aboutViewController
        aboutViewController.tabBarItem = makeItem(title: "about_tab", image: "about")
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            libraryViewController,
//            opdsViewController,
            aboutViewController
        ]
        tabBarController.tabBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        AppOpenAdManager.shared.loadAd()

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        app.library.importPublication(from: url, sender: window!.rootViewController!)
            .assertNoFailure()
            .sink { _ in }
            .store(in: &subscriptions)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let rootViewController = application.windows.first(
          where: { $0.isKeyWindow })?.rootViewController
        if let rootViewController = rootViewController {
          AppOpenAdManager.shared.showAdIfAvailable(viewController: rootViewController)
        }
      }
}
