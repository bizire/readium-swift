//
//  AdHelper.swift
//  TestApp
//
//  Created by Andrei on 04.09.2022.
//

import Foundation
import GoogleMobileAds
import RevenueCat

class AdHelper: NSObject, GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    private var interstitial: GADInterstitialAd?
    public var bannerView = GADBannerView()
    
    override init() {
        super.init()
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdmobBannerID") as? String
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        print("admob bannerView.adUnitID \(bannerView.adUnitID)")
    }
    
    func loadAdmobBanner(uiView: UIViewController) {

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

        bannerView.rootViewController = uiView
        bannerView.delegate = self
        
        let frame = { () -> CGRect in
            if #available(iOS 11.0, *) {
                return uiView.view.frame.inset(by: uiView.view.safeAreaInsets)
            } else {
                return uiView.view.frame
            }
        }()
        
        let viewWidth = frame.size.width
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("Admob Banner bannerViewDidReceiveAd")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("Admob bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func loadAdmobInterstitial() {
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
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[Constants.entitlementID]?.isActive != true {
                self.loadAdmobInterstitial()
            }
        }
    }
}
