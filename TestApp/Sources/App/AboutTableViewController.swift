//
//  AboutTableViewController.swift
//  r2-testapp-swift
//
//  Created by Geoffrey Bugniot on 27/04/2018.
//
//  Copyright 2018 European Digital Reading Lab. All rights reserved.
//  Licensed to the Readium Foundation under one or more contributor license agreements.
//  Use of this source code is governed by a BSD-style license which is detailed in the
//  LICENSE file present in the project repository where this source code is maintained.
//

import UIKit
import GoogleMobileAds
import RevenueCat
import StoreKit


class AboutTableViewController: UITableViewController {

    @IBOutlet weak var versionNumberCell: UITableViewCell!
    @IBOutlet weak var buildNumberCell: UITableViewCell!
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var upgradeCell: UITableViewCell!
    @IBOutlet weak var restoreCell: UITableViewCell!
    
    var adHelper = AdHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionNumberCell.textLabel?.text = NSLocalizedString("app_version_caption", comment: "Caption for the app version in About screen")
        versionNumberCell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        buildNumberCell.textLabel?.text = NSLocalizedString("build_version_caption", comment: "Caption for the build version in About screen")
        buildNumberCell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        nameCell.textLabel?.text = NSLocalizedString("name_app_caption", comment: "Caption for the app title in About screen")
        nameCell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        
        upgradeCell.isHidden = !(ConstantsTarget.hasPremiumContent)
        restoreCell.isHidden = !(ConstantsTarget.hasPremiumContent)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Admob Banner AboutTableViewController")
        // Note loadBannerAd is called in viewDidAppear as this is the first time that
        // the safe area is known. If safe area is not a concern (e.g., your app is
        // locked in portrait mode), the banner can be loaded in viewWillAppear.
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[StringConstants.entitlementID]?.isActive != true {
                self.adHelper.loadAdmobBanner(uiView: self)
            }
        }
        UIApplication.mainTabBarController?.dismissPlayerDetails()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func showSimpleAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var url: URL?
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                
                Purchases.shared.restorePurchases { purchaserInfo, error in
                    if let error = error {
                        self.present(UIAlertController.errorAlert(message: error.localizedDescription), animated: true, completion: nil)
                    }
                    if purchaserInfo?.entitlements[StringConstants.entitlementID]?.isActive == true {
                        self.showSimpleAlert(message: NSLocalizedString("success_restore", comment: ""))
                    } else {
                        self.showSimpleAlert(message: NSLocalizedString("nothing_to_restore", comment: ""))
                    }
                    //self.refreshUserDetails()
                }
            } else if indexPath.row == 1 {
                
                guard let scene = UIApplication.shared.foregroundActiveScene else { return }
                SKStoreReviewController.requestReview(in: scene)
            } else {
                
                let main = UIStoryboard(name: "PaywallBoard", bundle: nil).instantiateInitialViewController()!
                self.present(main, animated: true, completion: nil)
            }
        }
        
        if let url = url {
            UIApplication.shared.open(url)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension UIApplication {
    var foregroundActiveScene: UIWindowScene? {
        connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    }
}
