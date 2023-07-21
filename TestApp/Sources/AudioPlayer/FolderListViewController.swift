import UIKit
import AVFoundation
import GoogleMobileAds
import RevenueCat

class FolderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADFullScreenContentDelegate {
    var folderNames = [String]() // Array containing the folder names
    var folderHumanTitles = [String]() // Array containing the folder names
    var adHelper = AdHelper()
    
    private var interstitial: GADInterstitialAd?
    
    @IBOutlet weak var tableView: UITableView!
    
    private func initAudioPlayerFolders() {
        let docsURL = Bundle.main.resourceURL?.appendingPathComponent("AudioPlayerFiles")
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: docsURL!, includingPropertiesForKeys: nil)
            
            folderNames = contents
                .filter { (url) -> Bool in
                    var isDirectory: ObjCBool = false
                    return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
                }
                .map { $0.lastPathComponent }
                
            folderNames.sort { (name1, name2) -> Bool in
                 return name1.localizedStandardCompare(name2) == .orderedAscending
            }
            print("folderNames = \(folderNames)")
            
            initAudioPlayerHumanTitles()
        } catch {
            print(error)
        }
    }
    
    func initAudioPlayerHumanTitles() {
        if let plistPath = Bundle.main.path(forResource: "AudioPlayerFiles/folders", ofType: "plist"),
           let plistXML = FileManager.default.contents(atPath: plistPath),
           let foldersDict = try? PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
           let array = foldersDict["AudioFolders"] as? [String] {
            // Use the audioFoldersArray containing the strings
            folderHumanTitles = array
            print("audioFoldersArray folderNames = \(folderHumanTitles)")
            
            if (folderNames.count != folderHumanTitles.count) {
                print("Number of folders on file system and in plist file is different. Use file system folder names")
                folderHumanTitles = folderNames
            }
        } else {
            print("Failed to load the folders.plist file. Use file system folder names")
            folderHumanTitles = folderNames
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[Constants.entitlementID]?.isActive != true {
                self.loadAdmobInterstitial()
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        initAudioPlayerFolders()
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        if (folderNames.count == 1) {
            performSegueToAudio()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Admob Banner Folder List")
        // Note loadBannerAd is called in viewDidAppear as this is the first time that
        // the safe area is known. If safe area is not a concern (e.g., your app is
        // locked in portrait mode), the banner can be loaded in viewWillAppear.
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[Constants.entitlementID]?.isActive != true {
//                self.adHelper.loadAdmobBanner(uiView: self)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderNames.count
//        return folderHumanTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        cell.textLabel?.text = folderHumanTitles[indexPath.row]
//        cell.textLabel?.text = folderNames[indexPath.row]
        
        if indexPath.row <= Bundle.main.object(forInfoDictionaryKey: Constants.freeAudioChapters) as! Int {
            let lockImage = UIImage(named: "arrow_right")
            cell.imageView?.image = lockImage
        } else {
            let lockImage = UIImage(named: "lock")
            cell.imageView?.image = lockImage
            Purchases.shared.getCustomerInfo { (customerInfo, error) in
                if customerInfo?.entitlements[Constants.entitlementID]?.isActive == true{
                    let lockImage = UIImage(named: "arrow_right")
                    cell.imageView?.image = lockImage
                }
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[Constants.entitlementID]?.isActive == true ||
                indexPath.item <= Bundle.main.object(forInfoDictionaryKey: Constants.freeAudioChapters) as! Int {
                if self.interstitial != nil {
                    self.showInterstitial(uiView: self)
                } else {
                    print("Admob Interstitial wasn't ready")
                    self.performSegueToAudio()
                }
            } else {
                    let main = UIStoryboard(name: "PaywallBoard", bundle: nil).instantiateInitialViewController()!
                    self.present(main, animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("folderNames prepare sender folderName = \(sender)")
       
        if segue.identifier == "ShowFolderContent",
           let index = sender as? Int,
           let folderHumanTitle = self.folderHumanTitles[index] as? String,
           let folderName = self.folderNames[index] as? String,
           let destinationVC = segue.destination as? FolderContentViewController {
            print("folderNames prepare  inside folderName = \(folderName)")
            destinationVC.folderName = folderName
            destinationVC.folderHumanTitle = folderHumanTitle
        }
    }
    
    func loadAdmobInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: Bundle.main.object(forInfoDictionaryKey: "AdmobInterID") as! String,
            request: request,
            completionHandler: { [self] ad, error in
                if let error = error {
                    print("Admob Interstitial Failed to load ad with error: \(error.localizedDescription)")
                    return
                }
                interstitial = ad
                interstitial?.fullScreenContentDelegate = self
                print("Admob Interstitial was load successfully")
            }
        )
    }
    
    func showInterstitial(uiView: UIViewController) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: uiView)
          } else {
            print("Admob Interstitial wasn't ready")
          }
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Admob Interstitial did fail to present full screen content.")
        performSegueToAudio()
    }

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Admob Interstitial will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Admob Interstitial did dismiss full screen content.")
        performSegueToAudio()
    }
    
    func performSegueToAudio() {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        print("folderNames sender folderName index = \(selectedIndexPath.row)")
        self.performSegue(withIdentifier: "ShowFolderContent", sender: selectedIndexPath.row)
    }
}

