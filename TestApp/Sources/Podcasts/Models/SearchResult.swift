//
//  SearchResult.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import Foundation

struct SearchResult: Decodable {
    var resultCount: Int
    var results: [Podcast]
}
