//
//  PackageCell.swift
//  TestApp
//
//  Created by Andrei on 12.09.2022.
//

import UIKit

/*
 The custom paywall package cell.
 Configured in /Resources/UI/Paywall.storyboard
 */

class PackageCell: UITableViewCell {

    @IBOutlet var packageTitleLabel: UILabel!
    @IBOutlet var packageTermsLabel: UILabel!
    @IBOutlet var packagePriceLabel: UILabel!

}
