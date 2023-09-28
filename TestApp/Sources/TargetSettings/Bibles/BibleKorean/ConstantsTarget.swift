//
//  ConstantsTarget.swift
//  QuranEn
//
//  Created by Andrei Aks on 22.08.23.
//

import Foundation
import UIKit

struct ConstantsTarget {
    
    static let adUnitIDBanner       = "ca-app-pub-2983224055780222/8961263559"
    static let adUnitIDInterstitial = "ca-app-pub-2983224055780222/5264888674"
    static let adUnitIDNative       = "XXXXXXXX"
    static let adUnitIDOpen         = "ca-app-pub-2983224055780222/7648181885"
    static let adUnitIDRewarded     = "ca-app-pub-2983224055780222/5022018545"
    
    static let revenueCatPublicKey = "appl_YLNpEdTxvPYvsNPuPTZYrHPguky"
    
    static let audioBookType = "book"
    static let audioBookVersion = "성경"
    static let mediaSearchTerm: [String] = [
        "예수 그리스도",        // Jesus Christ
        "성경",               // Bible
        "기독교",              // Christian
    ]
    static let podcastCountry = "kr"
    
    static let excludeFromSearch: [String] = [
        "http://pod.ssenhosting.com",
        "http://pod1.cgntv.net",
        "http://rss.jbch.org/sermon/podcast_video_academy_kor.xml",
        "https://feeds.buzzsprout.com/2066727.rss",
        "https://feeds.feedburner.com/godcast2015",
        "http://podcast.faithcomesbyhearing.com",
        "http://jyudas.synology.me",
        "http://cbspodcast.com/podcast",
        "https://goodnewstv.kr",
        "https://www.goodnewstv.kr",
        "https://feeds.feedburner.com/pearl-of-great-price",
        "https://feeds.feedburner.com/old-testament-stories-kor"
    ]
    
    static let numberPerRow = 2
    static let freeItemsAmount = 5
    static let freeAudioChapters = 5
    
    static let hasPremiumContent = true
    static let hasSubscriptions = true
    
    static let hasAudioPlayer = true
    static let hasMediaView = true
    static let hasNewsView = true
    
    static let tabTitleBookshelf = ""
    static let tabTitleAudio = ""
    static let tabTitleMedia = ""
    static let tabTitleNews = ""
    
    static let newsURL = "https://news.google.com/rss/search?q=%EC%84%B1%EA%B2%BD&hl=ko&gl=KR&ceid=KR:ko"
    
    static let privacyPolicyURL = "https://sites.google.com/view/paulvi-app-bible/"
    static let termsOfUseURL = "https://sites.google.com/view/paulvi-app-terms-conditions/"
    
}

