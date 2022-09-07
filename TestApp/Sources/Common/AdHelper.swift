//
//  AdHelper.swift
//  TestApp
//
//  Created by Andrei on 04.09.2022.
//

import Foundation
import GoogleMobileAds

class AdHelper: NSObject, GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    var interstitial: GADInterstitialAd?
    
    func admobBannerInit(uiView: UIViewController) {
        print("Admob Banner start init")
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
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdmobBannerID") as? String
        bannerView.rootViewController = uiView
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("Admob Banner bannerViewDidReceiveAd")
    }
    
    func admobInterstitialInit() {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: Bundle.main.object(forInfoDictionaryKey: "AdmobInterID") as! String,
            request: request,
            completionHandler: { [self] ad, error in
                if let error = error {
                    print("Admob Interstitial Failed to load ad with error: \(error.localizedDescription)")
                    return
                }
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
                print("Admob Interstitial was load successfully")
            }
        )
    }
    
    func showInterstitial(uiView: UIViewController) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: uiView)
          } else {
            print("Admob Interstitial wasn't ready")
          }
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Admob Interstitial did fail to present full screen content.")
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Admob Interstitial will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Admob Interstitial did dismiss full screen content.")
    }
}
