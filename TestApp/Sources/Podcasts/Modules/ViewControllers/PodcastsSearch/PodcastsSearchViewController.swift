//
//  PodcastsSearchViewController.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit
import Alamofire
import GoogleMobileAds
import RevenueCat

// TODO: Replase strings with type-safety values

final class PodcastsSearchViewController: UITableViewController {

    // MARK: - Properties
    fileprivate var podcasts = [Podcast]()
    fileprivate var timer: Timer?
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    
    var adHelper = AdHelper()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { timer in
            NetworkService.shared.fetchPodcasts(searchTexts: ConstantsTarget.mediaSearchTerm, completionHandler: { podcasts in
//                self.podcasts = podcasts
                self.podcasts.append(contentsOf: podcasts)
                self.tableView.reloadData()
            })
        })
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[StringConstants.entitlementID]?.isActive != true {
                self.adHelper.loadAdmobInterstitial()
            }
        }
        
        if (ConstantsTarget.tabTitleMedia == "") {
            self.navigationItem.title = NSLocalizedString("media_tab", comment: "Title")
        } else {
            self.navigationItem.title = ConstantsTarget.tabTitleMedia
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear PodcastsSearchViewController")
        
        if let wasPlayerLaunch = UIApplication.mainTabBarController?.wasPlayerLaunch {
            // Use the unwrapped value of wasPlayerLaunch here
            if wasPlayerLaunch {
                UIApplication.mainTabBarController?.minimizePlayerDetails()
            } else {
                // The value of wasPlayerLaunch is false
            }
        } else {
            // UIApplication.mainTabBarController is nil or wasPlayerLaunch is not available
        }
    }

}


// MARK: - UITableView
extension PodcastsSearchViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodcastCell", for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    
    // MARK: Header Setup
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 200, width: 0, height: 0))
        let image = UIImage(named: "appicon")
        let button = UIButton()
        button.setImage(image, for: .normal)
        headerView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == true ? (tableView.bounds.height / 2) : 0
    }

    // MARK: Footer Setup
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let podcastsSearchingView = Bundle.main.loadNibNamed("PodcastsSearchingView", owner: self)?.first as? UIView
        return podcastsSearchingView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return podcasts.isEmpty && searchController.searchBar.text?.isEmpty == false ? 200 : 0
    }

    // MARK: Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[StringConstants.entitlementID]?.isActive != true {
                self.adHelper.showInterstitial(uiView: self)
            }
        }
        let episodesController = EpisodesViewController()
        let podcast = self.podcasts[indexPath.row]
        episodesController.podcast = podcast
        self.navigationController?.pushViewController(episodesController, animated: true)
    }
}


// MARK: - UISearchBarDelegate
extension PodcastsSearchViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        podcasts = []
        tableView.reloadData()

        timer?.invalidate()
        var searchTexts: [String] = [searchText]
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { timer in
            NetworkService.shared.fetchPodcasts(searchTexts: searchTexts, completionHandler: { podcasts in
                self.podcasts = podcasts
                self.tableView.reloadData()
            })
        })
    }

}


// MARK: - Setup
extension PodcastsSearchViewController {

    fileprivate func initialSetup() {
        setupSearchBar()
        setupTableView()
    }

    private func setupSearchBar() {
        self.definesPresentationContext                   = true
        navigationItem.searchController                   = searchController
        navigationItem.hidesSearchBarWhenScrolling        = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate               = self
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PodcastCell")
    }
}
