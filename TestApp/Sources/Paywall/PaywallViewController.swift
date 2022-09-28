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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("paywall_tos", comment: "InApp Terms Label")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offering?.availablePackages.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 140.0))
    
        let privacyButton = UIButton(frame: CGRect(x: 70, y: 70, width: tableView.frame.width/3, height: 50.0))
        privacyButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        privacyButton.contentHorizontalAlignment = .left;
        privacyButton.setTitle(NSLocalizedString("paywall_privacy", comment: "InApp Terms Label"), for: .normal)
        privacyButton.setTitleColor(.systemBlue, for: .normal)
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        privacyButton.addTarget(self, action:#selector(self.pressedPrivacy), for: .touchUpInside)
        footerView.addSubview(privacyButton)
     
        let termsButton = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width/3, height: 50.0))
        termsButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        termsButton.contentHorizontalAlignment = .right;
        termsButton.setTitle(NSLocalizedString("paywall_terms", comment: "InApp Terms Label"), for: .normal)
        termsButton.setTitleColor(.systemBlue, for: .normal)
        termsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        termsButton.addTarget(self, action:#selector(self.pressedTerms), for: .touchUpInside)
        footerView.addSubview(termsButton)
    
        let termsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50.0))
        termsLabel.numberOfLines = 0
        termsLabel.lineBreakMode = .byWordWrapping
        termsLabel.text = NSLocalizedString("paywall_tos", comment: "InApp Terms Label")
        termsLabel.textColor = .lightGray
        termsLabel.font = UIFont.systemFont(ofSize: 12)
        footerView.addSubview(termsLabel)
        
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        termsLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        termsLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        termsLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 50).isActive = true
        
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor).isActive = true
        privacyButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 0).isActive = true
        
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        termsButton.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 0).isActive = true

        return footerView
    }
    
    @objc func pressedPrivacy() {
        guard let url = URL(string: Constants.privacyPolicyURL) else {
          return //be safe
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func pressedTerms() {
        guard let url = URL(string: Constants.termsOfUseURL) else {
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
            cell.packageTitleLabelA.text = package.storeProduct.localizedTitle
            cell.packagePriceLabelA.text = package.localizedPriceString
            
            if let intro = package.storeProduct.introductoryDiscount {
                let packageTermsLabelText = intro.price == 0
                ? NSLocalizedString("paywall_free_trial", comment: "InApp Terms Label")
                : NSLocalizedString("paywall_unlocks_premium", comment: "InApp Terms Label")

                cell.packageTermsLabelA.text = packageTermsLabelText
            } else {
                cell.packageTermsLabelA.text = NSLocalizedString("paywall_unlocks_premium", comment: "InApp Terms Label")
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

