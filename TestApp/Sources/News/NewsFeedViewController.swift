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

let feedURL = URL(string: "https://news.google.com/rss/topics/CAAqIQgKIhtDQkFTRGdvSUwyMHZNREUxYWpjU0FtVnVLQUFQAQ?hl=en-US&gl=US&ceid=US:en")!
//let feedURL = URL(string: "http://images.apple.com/main/rss/hotnews/hotnews.rss")!

class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var newsFeedTableView: UITableView!
    
    let parser = FeedParser(URL: feedURL)
    var rssFeed: RSSFeed?
    var adHelper = AdHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsFeedTableView.delegate = self
        newsFeedTableView.dataSource = self
        
        self.title = NSLocalizedString("news_tab", comment: "Title")
        
        let nib = UINib(nibName: "NewsCell", bundle: nil)
        newsFeedTableView.register(nib, forCellReuseIdentifier: "NewsCell")
        
        
        
        // Parse asynchronously, not to block the UI.
        parser.parseAsync { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let feed):
                // Grab the parsed feed directly as an optional rss, atom or json feed object
                self.rssFeed = feed.rssFeed
                
                // Or alternatively...
                //
                // switch feed {
                // case let .rss(feed): break
                // case let .atom(feed): break
                // case let .json(feed): break
                // }
                
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
//        let cell = reusableCell()
//        cell.textLabel?.text = self.rssFeed?.items?[indexPath.row].title ?? "[no title]"
//        cell.detailTextLabel?.text = "sdgfadfg"
////        cell.contentConfiguration.
//        cell.imageView?.image = UIImage(named: "arrow_right")
//        return cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        cell.news = self.rssFeed?.items?[indexPath.row]
        return cell
    }
    
//    func reusableCell() -> UITableViewCell {
//        let reuseIdentifier = "Cell"
//        if let cell = self.newsFeedTableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
//            return cell
//
//        }
//        let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
//        cell.accessoryType = .disclosureIndicator
//        return cell
//    }
    
}
