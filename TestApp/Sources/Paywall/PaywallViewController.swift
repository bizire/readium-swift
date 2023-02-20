//
//  PaywallViewController.swift
//  TestApp
//
//  Created by Andrei on 12.09.2022.
//

import StoreKit
import UIKit
import RevenueCat

/*
 An example paywall that uses the current offering.
 Configured in /Resources/UI/Paywall.storyboard
 */

class PaywallViewController: UITableViewController {

    /// - Store the offering being displayed
    var offering: Offering?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionHeaderHeight = 175
        tableView.estimatedSectionHeaderHeight = 175

        /// - Load offerings when the paywall is displayed
        Purchases.shared.getOfferings { (offerings, error) in
            
            /// - If we have an error fetching offerings here, we'll print it out. You'll want to handle this case by either retrying, or letting your users know offerings weren't able to be fetched.
            if let error = error {
                print(error.localizedDescription)
            }
            
            self.offering = offerings?.current
            self.tableView.reloadData()
        }
    }
    
    @IBAction func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }

    /* Some UITableView methods for customization */

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String)
//    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("paywall_tos", comment: "InApp Terms Label")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offering?.availablePackages.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        
        //headerView.backgroundColor = .lightGray
        
        let termsLabel = UILabel()
        termsLabel.numberOfLines = 0
        termsLabel.lineBreakMode = .byWordWrapping
        termsLabel.text = NSLocalizedString("paywall_header", comment: "InApp Terms Label")
        termsLabel.textColor = .label
        termsLabel.textAlignment = .left
        termsLabel.font = UIFont.systemFont(ofSize: 20)
        headerView.addSubview(termsLabel)
        
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15).isActive = true
        termsLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        termsLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30).isActive = true
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
    
        let privacyButton = UILabel()
        privacyButton.numberOfLines = 0
        privacyButton.lineBreakMode = NSLineBreakMode.byWordWrapping;
        privacyButton.textAlignment = .center;
        privacyButton.text = NSLocalizedString("paywall_privacy", comment: "InApp Terms Label")
        privacyButton.textColor = .systemBlue
        privacyButton.font = UIFont.systemFont(ofSize: 10)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(pressedPrivacy))
        privacyButton.isUserInteractionEnabled = true
        privacyButton.addGestureRecognizer(tap1)
        footerView.addSubview(privacyButton)
     
        let termsButton = UILabel()
        termsButton.numberOfLines = 0
        termsButton.lineBreakMode = NSLineBreakMode.byWordWrapping;
        termsButton.textAlignment = .center;
        termsButton.text = NSLocalizedString("paywall_terms", comment: "InApp Terms Label")
        termsButton.textColor = .systemBlue
        termsButton.font = UIFont.systemFont(ofSize: 10)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(pressedTerms))
        termsButton.isUserInteractionEnabled = true
        termsButton.addGestureRecognizer(tap2)
        footerView.addSubview(termsButton)
        
        let termsLabel = UILabel()
        termsLabel.numberOfLines = 0
        termsLabel.lineBreakMode = .byWordWrapping
        termsLabel.text = NSLocalizedString("paywall_tos", comment: "InApp Terms Label")
        termsLabel.textColor = .lightGray
        termsLabel.font = UIFont.systemFont(ofSize: 10)
        footerView.addSubview(termsLabel)
        
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        privacyButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 60).isActive = true
        
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        termsButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 60).isActive = true
        
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        termsLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        termsLabel.topAnchor.constraint(equalTo: privacyButton.bottomAnchor, constant: 30).isActive = true
        
        termsLabel.isHidden = !(Bundle.main.object(forInfoDictionaryKey: "hasSubscriptions") as? Bool ?? true)

        return footerView
    }
    
    @objc func pressedPrivacy() {
        print("pressedPrivacy")
        
        guard let url = URL(string: Bundle.main.object(forInfoDictionaryKey: "privacyPolicyURL") as! String) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func pressedTerms() {
        print("pressedTerms")
        guard let url = URL(string: Bundle.main.object(forInfoDictionaryKey: "termsOfUseURL") as! String) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackageCellView", for: indexPath) as! PackageCellView
        
        /// - Configure the PackageCellView to display the appropriate name, pricing, and terms
        if let package = self.offering?.availablePackages[indexPath.row] {
            var timePeriod = package.storeProduct.subscriptionPeriod?.durationTitle ?? "lifetime"
            
            var timePeriodLocalized = NSLocalizedString("paywall_lifetime", comment: "InApp Period")
            if (timePeriod.caseInsensitivelyEqual(to: "month")) {
                timePeriodLocalized = NSLocalizedString("paywall_month", comment: "InApp Period")
            } else if (timePeriod.caseInsensitivelyEqual(to: "year")) {
                timePeriodLocalized = NSLocalizedString("paywall_year", comment: "InApp Period")
            }
            
            cell.packageTitleLabelA.text = package.localizedPriceString + " / " + timePeriodLocalized
            
            if let intro = package.storeProduct.introductoryDiscount {
                let packageTermsLabelText = intro.price == 0
                ? NSLocalizedString("paywall_free_trial", comment: "InApp Terms Label")
                : NSLocalizedString("paywall_unlocks_premium", comment: "InApp Terms Label")

                cell.packageTermsLabelA.text = packageTermsLabelText
                cell.packageTermsLabelA.layer.cornerRadius = 8
                cell.packageTermsLabelA.layer.borderColor = UIColor.systemYellow.cgColor
                cell.packageTermsLabelA.layer.borderWidth = 1.5
                cell.packageTermsLabelA.layer.masksToBounds = true
            } else {
                cell.packageTermsLabelA.text = NSLocalizedString("paywall_unlocks_premium", comment: "InApp Terms Label")
                cell.packageTermsLabelA.isHidden = true
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        /// - Find the package being selected, and purchase it
        if let package = self.offering?.availablePackages[indexPath.row] {
            Purchases.shared.purchase(package: package) { (transaction, purchaserInfo, error, userCancelled) in
                if let error = error {
                    self.present(UIAlertController.errorAlert(message: error.localizedDescription), animated: true, completion: nil)
                } else {
                    /// - If the entitlement is active after the purchase completed, dismiss the paywall
                    if purchaserInfo?.entitlements[Constants.entitlementID]?.isActive == true {
                        self.dismissModal()
                    }
                }
            }
        }
    }
}

/* Some methods to make displaying subscription terms easier */

extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        default: return "Unknown"
        }
    }
    
    func periodTitle() -> String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralized = self.value > 1 ?  periodString + "s" : periodString
        return pluralized
    }
}

class CustomButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -10, dy: -10).contains(point)
    }
}
