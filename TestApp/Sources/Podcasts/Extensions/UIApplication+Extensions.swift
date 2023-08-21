//
//  UIApplication+Extensions.swift
//  IRPodcast
//
//  Created by Phil on 2021/4/27.
//

import UIKit

extension UIApplication {

    static var mainTabBarController: AppTabBarViewController? {
        return shared.keyWindow?.rootViewController as? AppTabBarViewController
    }

}
