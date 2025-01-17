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
import RevenueCat
import AppTrackingTransparency
import AdSupport
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADFullScreenContentDelegate, PurchasesDelegate {
    
    var window: UIWindow?
    
    private var app: AppModule!
    private var subscriptions = Set<AnyCancellable>()
    
    private var appBecomeActiveCounter = 0
    private var launchedAppDelegateCounter = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        app = try! AppModule()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["820e4703cd201ffed879f66fe499bc05"]
        
        launchedAppDelegateCounter = UserDefaults.standard.integer(forKey: "launchedAppDelegateCounter")
        launchedAppDelegateCounter = launchedAppDelegateCounter + 1
        print("Launch AppDelagate, launchedAppDelegateCounter = \(launchedAppDelegateCounter). appBecomeActiveCounter")
        UserDefaults.standard.set(launchedAppDelegateCounter, forKey: "launchedAppDelegateCounter")
        
        func makeItem(title: String, image: String) -> UITabBarItem {
            return UITabBarItem(
                title: NSLocalizedString(title, comment: "Library tab title"),
                image: UIImage(named: image),
                tag: 0
            )
        }
        
        // Library
        let libraryViewController = app.library.rootViewController
        var tabNameBookshelf = NSLocalizedString("bookshelf_tab", comment: "Title")
        if (ConstantsTarget.tabTitleBookshelf != "") {
            tabNameBookshelf = ConstantsTarget.tabTitleBookshelf
        }
        libraryViewController.tabBarItem = makeItem(title: tabNameBookshelf, image: "bookshelf")
        
        // Audio Player
        let audioPlayerViewController = app.audioplayerViewController
        var tabNameAudio = NSLocalizedString("audio_tab", comment: "Title")
        if (ConstantsTarget.tabTitleAudio != "") {
            tabNameAudio = ConstantsTarget.tabTitleAudio
        }
        audioPlayerViewController.tabBarItem = makeItem(title: tabNameAudio, image: "audio")
        
        // OPDS Feeds
        let opdsViewController = app.opds.rootViewController
        opdsViewController.tabBarItem = makeItem(title: "catalogs_tab", image: "catalogs")
        
        // Media Feed
        let mediaViewController = app.mediaViewController
        var tabNameMedia = NSLocalizedString("media_tab", comment: "Title")
        if (ConstantsTarget.tabTitleMedia != "") {
            tabNameMedia = ConstantsTarget.tabTitleMedia
        }
        mediaViewController.tabBarItem = makeItem(title: tabNameMedia, image: "catalogs")
        
        // News Feed
        let newsViewController = app.newsViewController
        var tabNameNews = NSLocalizedString("news_tab", comment: "Title")
        if (ConstantsTarget.tabTitleNews != "") {
            tabNameNews = ConstantsTarget.tabTitleNews
        }
        newsViewController.tabBarItem = makeItem(title: tabNameNews, image: "news")
        
        // About
        let aboutViewController = app.aboutViewController
        aboutViewController.tabBarItem = makeItem(title: "about_tab", image: "about")
        
        let tabBarController = AppTabBarViewController()
        tabBarController.viewControllers = [
            libraryViewController,
//            opdsViewController,
        ]
        if (ConstantsTarget.hasAudioPlayer) {
            tabBarController.viewControllers?.append(audioPlayerViewController)
        }
        if (ConstantsTarget.hasMediaView) {
            tabBarController.viewControllers?.append(mediaViewController)
        }
        if (ConstantsTarget.hasNewsView) {
            tabBarController.viewControllers?.append(newsViewController)
        }
        tabBarController.viewControllers?.append(aboutViewController)
        tabBarController.tabBar.tintColor = .label

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: ConstantsTarget.revenueCatPublicKey)
        
        Purchases.shared.delegate = self
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[StringConstants.entitlementID]?.isActive != true {
                AppOpenAdManager.shared.loadAd()
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session for background playback: \(error.localizedDescription)")
        }
        
        return true
    }
    
    func purchases(_ purchases: Purchases, readyForPromotedProduct product: StoreProduct, purchase startPurchase: @escaping StartPurchaseBlock) {
        startPurchase { (transaction, purchaserInfo, error, userCancelled) in
            if let error = error {
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                // show the alert
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
//            else {
//                /// - If the entitlement is active after the purchase completed, dismiss the paywall
//                if purchaserInfo?.entitlements[Constants.entitlementID]?.isActive == true {
//                    self.dismissModal()
//                }
//            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        app.library.importPublication(from: url, sender: window!.rootViewController!)
            .assertNoFailure()
            .sink { _ in }
            .store(in: &subscriptions)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        let rootViewController = application.windows.first(where: { $0.isKeyWindow })?.rootViewController
        
        if let rootViewController = rootViewController {
            if (appBecomeActiveCounter > 1 || launchedAppDelegateCounter > 1) {
                
                Purchases.shared.getCustomerInfo { (customerInfo, error) in
                    if customerInfo?.entitlements[StringConstants.entitlementID]?.isActive != true {
                        print("appBecomeActiveCounter = \(self.appBecomeActiveCounter) & launchedAppDelegateCounter = \(self.launchedAppDelegateCounter)")
                        AppOpenAdManager.shared.showAdIfAvailable(viewController: rootViewController)
                    }
                }
            }
        }
        
        appBecomeActiveCounter = appBecomeActiveCounter + 1
        
//        if #available(iOS 14.0, *) {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                print("Status \(status)")
//            })
//        }
    }
}
