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


class AboutTableViewController: UITableViewController {

    @IBOutlet weak var versionNumberCell: UITableViewCell!
    @IBOutlet weak var buildNumberCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionNumberCell.textLabel?.text = NSLocalizedString("app_version_caption", comment: "Caption for the app version in About screen")
        versionNumberCell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        buildNumberCell.textLabel?.text = NSLocalizedString("build_version_caption", comment: "Caption for the build version in About screen")
        buildNumberCell.detailTextLabel?.text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        admobBannerInit()
    }

    func admobBannerInit() {
        var bannerView: GADBannerView
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
              [NSLayoutConstraint(item: bannerView,
                                  attribute: .bottom,
                                  relatedBy: .equal,
                                  toItem: bottomLayoutGuide,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: 0),
               NSLayoutConstraint(item: bannerView,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
              ])
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var url: URL?
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                url = URL(string: "https://www.edrlab.org/")
            } else {
                url = URL(string: "https://opensource.org/licenses/BSD-3-Clause")
            }
        }
        
        if let url = url {
            UIApplication.shared.open(url)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
