//
//  NewsFeedViewController.swift
//  TestApp
//
//  Created by Andrei Aks on 18.09.23.
//

import Foundation
import UIKit
import FeedKit
import RevenueCat
import GoogleMobileAds

let feedURL = URL(string: ConstantsTarget.newsURL)!
//let feedURL = URL(string: "http://images.apple.com/main/rss/hotnews/hotnews.rss")!

class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADFullScreenContentDelegate {

    let newsLogosArray = [
        UIImage(named:"news-logo-1")!,
        UIImage(named:"news-logo-2")!,
        UIImage(named:"news-logo-3")!,
        UIImage(named:"news-logo-4")!,
        UIImage(named:"news-logo-5")!
    ]
    
    @IBOutlet weak var newsFeedTableView: UITableView!
    
    let parser = FeedParser(URL: feedURL)
    var rssFeed: RSSFeed?
    var adHelper = AdHelper()
    private var interstitial: GADInterstitialAd?
    private var selectedNewsIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsFeedTableView.delegate = self
        newsFeedTableView.dataSource = self
        
        if (ConstantsTarget.tabTitleNews == "") {
            self.navigationItem.title = NSLocalizedString("news_tab", comment: "Title")
        } else {
            self.navigationItem.title = ConstantsTarget.tabTitleNews
        }
        
        let nib = UINib(nibName: "NewsCell", bundle: nil)
        newsFeedTableView.register(nib, forCellReuseIdentifier: "NewsCell")
        
        
        
        // Parse asynchronously, not to block the UI.
        parser.parseAsync { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let feed):
                // Grab the parsed feed directly as an optional rss, atom or json feed object
                self.rssFeed = feed.rssFeed
                
                // Then back to the Main thread to update the UI.
                DispatchQueue.main.async {
                    self.newsFeedTableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        self.newsFeedTableView.estimatedRowHeight = 80
        self.newsFeedTableView.rowHeight = UITableView.automaticDimension
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[StringConstants.entitlementID]?.isActive != true {
                self.loadAdmobInterstitial()
            }
        }
        
    }
    
    func loadAdmobInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: ConstantsTarget.adUnitIDInterstitial,
            request: request,
            completionHandler: { [self] ad, error in
                if let error = error {
                    print("Admob Interstitial NewsFeedViewController Failed to load ad with error: \(error.localizedDescription)")
                    return
                }
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
                print("Admob Interstitial NewsFeedViewController was load successfully")
            }
        )
    }
    
    func showInterstitial(uiView: UIViewController) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: uiView)
          } else {
            print("Admob Interstitial NewsFeedViewController wasn't ready")
            self.openNewsArticle(self.selectedNewsIndex)
          }
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Admob Interstitial NewsFeedViewController did fail to present full screen content.")
        self.openNewsArticle(self.selectedNewsIndex)
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Admob Interstitial NewsFeedViewController will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Admob Interstitial NewsFeedViewController did dismiss full screen content.")
        self.openNewsArticle(self.selectedNewsIndex)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Admob Banner NewsFeedViewController")
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rssFeed?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.news = self.rssFeed?.items?[indexPath.row]
        
        let listSize = self.rssFeed?.items?.count ?? 0
        let modulo = Int(indexPath.row) % newsLogosArray.count
        print("modulo = \(modulo), listSize = \(listSize)")
        cell.setLogo(logoImage: newsLogosArray[modulo])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedNewsIndex = indexPath.row
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[StringConstants.entitlementID]?.isActive != true {
                self.showInterstitial(uiView: self)
            } else {
                self.openNewsArticle(self.selectedNewsIndex)
            }
        }
    }
    
    func openNewsArticle(_ index: Int) {
        guard let link = self.rssFeed?.items?[index].link else { return }
        guard let newsUrl = URL(string: link) else { return }
        UIApplication.shared.open(newsUrl)
    }
    
}
