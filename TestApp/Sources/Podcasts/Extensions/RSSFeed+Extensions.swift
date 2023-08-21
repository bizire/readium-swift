//
//  RSSFeed+Extensions.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import FeedKit

extension RSSFeed {

    func toEpisodes() -> [Episode] {
        let imageUrl = iTunes?.iTunesImage?.attributes?.href

        var episodes = [Episode]()
        items?.forEach({ feedItem in
            var episode = Episode(feedItem: feedItem)

            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }

            episodes.append(episode)
        })

        return episodes
    }

}

