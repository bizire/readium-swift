//
//  String+Extensions.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import Foundation

extension String {

    var httpsUrlString: String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }

}
