//
//  SearchResult.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import Foundation

struct SearchResult: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
