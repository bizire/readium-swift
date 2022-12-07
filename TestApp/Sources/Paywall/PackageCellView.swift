//
//  PackageCellView.swift
//  TestApp
//
//  Created by Andrei on 12.09.2022.
//

import UIKit

/*
 The custom paywall package cell.
 Configured in /Resources/UI/Paywall.storyboard
 */

class PackageCellView: UITableViewCell {
    
    @IBOutlet var packageTitleTop: UILabel!
    @IBOutlet var packageTitleBottom: UILabel!
    @IBOutlet var packageTitleLabelA: UILabel!
    @IBOutlet var packageTermsLabelA: UILabel!
}
