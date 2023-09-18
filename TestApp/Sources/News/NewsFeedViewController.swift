//
//  NewsFeedViewController.swift
//  TestApp
//
//  Created by Andrei Aks on 18.09.23.
//

import Foundation
import UIKit
import FeedKit

let feedURL = URL(string: "http://images.apple.com/main/rss/hotnews/hotnews.rss")!

class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var newsFeedTableView: UITableView!
    
    let parser = FeedParser(URL: feedURL)
    
    var rssFeed: RSSFeed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsFeedTableView.delegate = self
        newsFeedTableView.dataSource = self
        
        self.title = "Feed"
        
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
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rssFeed?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reusableCell()
        cell.textLabel?.text = self.rssFeed?.items?[indexPath.row].title ?? "[no title]"
        return cell
    }
    
    func reusableCell() -> UITableViewCell {
        let reuseIdentifier = "Cell"
        if let cell = self.newsFeedTableView.dequeueReusableCell(withIdentifier: reuseIdentifier) { return cell }
        let cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}
