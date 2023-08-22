//
//  AppTabBarViewController.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit

class AppTabBarViewController: UITabBarController {

    // MARK: - Properties
    fileprivate let playerDetailsView = PlayerDetailsView.initFromNib()
    fileprivate var maximizedTopAnchorConstraint: NSLayoutConstraint!
    fileprivate var minimizedTopAnchorConstraint: NSLayoutConstraint!
    fileprivate var bottomAnchorConstraint: NSLayoutConstraint!
    
    var wasPlayerLaunch = false

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

//        UINavigationBar.appearance().prefersLargeTitles = true

        setupPlayerDetailsView()
    }

}


// MARK: - Setup
extension AppTabBarViewController {

    // MARK: - Internal
    @objc func minimizePlayerDetails() {
        print("Readium AppTabBarViewController minimizePlayerDetails")
        
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = false
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity

            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
        })
        
    }
    
    @objc func dismissPlayerDetails() {
        print("Readium AppTabBarViewController dismissPlayerDetails")
        
        playerDetailsView.pause()
        
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = false
        
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: 0)
        
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity

            self.playerDetailsView.maximizedStackView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 0
        })
    }

    func maximizePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []) {
        print("Readium AppTabBarViewController maximizePlayerDetails")
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchorConstraint.constant = 0

        if episode != nil {
            playerDetailsView.episode = episode
        }

        playerDetailsView.playlistEpisodes = playlistEpisodes

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)

            self.playerDetailsView.maximizedStackView.alpha = 1
            self.playerDetailsView.miniPlayerView.alpha = 0
        })
        
        wasPlayerLaunch = true
    }

    fileprivate func setupPlayerDetailsView() {
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        setupConstraintsForPlayerDetailsView()
    }

    // MARK: - Private
    private func generateNavigationController(for rootViewController: UIViewController,
                                                  title: String, image: UIImage) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navigationController.tabBarItem.title   = title
        navigationController.tabBarItem.image   = image
        return navigationController
    }

    func setupConstraintsForPlayerDetailsView() {
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false

        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor,
                                                                              constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true

        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                           constant: view.frame.height)
        bottomAnchorConstraint.isActive = true

        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)

        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

}
