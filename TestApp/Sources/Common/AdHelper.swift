//
//  AdHelper.swift
//  TestApp
//
//  Created by Andrei on 04.09.2022.
//

import Foundation
import GoogleMobileAds

class AdHelper {
    
    func admobBannerInit(uiView: UIViewController) {
        var bannerView: GADBannerView
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        uiView.view.addSubview(bannerView)
        uiView.view.addConstraints(
              [NSLayoutConstraint(item: bannerView,
                                  attribute: .bottom,
                                  relatedBy: .equal,
                                  toItem: uiView.bottomLayoutGuide,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: 0),
               NSLayoutConstraint(item: bannerView,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: uiView.view,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
              ])
        bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdmobBannerID") as? String
        bannerView.rootViewController = uiView
        bannerView.load(GADRequest())
    }
    
}
