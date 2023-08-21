//
//  UIApplication+Extensions.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit

extension UIApplication {

    static var mainTabBarController: MainTabBarViewController? {
        return shared.keyWindow?.rootViewController as? MainTabBarViewController
    }

}
