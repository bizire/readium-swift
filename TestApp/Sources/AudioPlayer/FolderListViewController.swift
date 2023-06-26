import UIKit
import AVFoundation
import GoogleMobileAds
import RevenueCat

class FolderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var folderNames = [String]() // Array containing the folder names
    let audioPlayer = AVAudioPlayer()
    var adHelper = AdHelper()
    
    @IBOutlet weak var tableView: UITableView!
    
    private func initAudioPlayerFolders() {
        
        let docsPath = Bundle.main.path(forResource: "AudioPlayerFiles", ofType: nil)
        let fileManager = FileManager.default
        
        do {
            folderNames = try fileManager.contentsOfDirectory(atPath: docsPath!)
            folderNames = folderNames.sorted()
            print("folderNames = \(folderNames)")
        } catch {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        initAudioPlayerFolders()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear Admob Banner Folder List")
        // Note loadBannerAd is called in viewDidAppear as this is the first time that
        // the safe area is known. If safe area is not a concern (e.g., your app is
        // locked in portrait mode), the banner can be loaded in viewWillAppear.
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements[Constants.entitlementID]?.isActive != true {
                self.adHelper.loadAdmobBanner(uiView: self)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        cell.textLabel?.text = folderNames[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderName = folderNames[indexPath.row]
        print("folderNames sender folderName = \(folderName)")
        performSegue(withIdentifier: "ShowFolderContent", sender: folderName)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("folderNames prepare sender folderName = \(sender)")
        if segue.identifier == "ShowFolderContent",
           let folderName = sender as? String,
           let destinationVC = segue.destination as? FolderContentViewController {
            print("folderNames prepare  inside folderName = \(folderName)")
            destinationVC.folderName = folderName
        }
    }
}

class FolderContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  AVAudioPlayerDelegate {
    var folderName: String!
    var folderFiles = [String]()
    var audioPlayer: AVAudioPlayer!
    var adHelper = AdHelper()
    
    let playPauseButton = UIButton(type: .system)
    let playImage = UIImage(named: "player_upnext_play")
    let pauseImage = UIImage(named: "player_upnext_pause")
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("folderNames FolderContentViewController viewDidLoad")
        
        tableView.dataSource = self
        tableView.delegate = self
        print("folderNames folderName = \(folderName)")
        loadFolderFiles()
    }
    
    func loadFolderFiles() {
           // Assuming the folder structure is in the app's main bundle
           if let folderPath = Bundle.main.path(forResource: "AudioPlayerFiles/\(folderName!)", ofType: nil),
              let folderContents = try? FileManager.default.contentsOfDirectory(atPath: folderPath) {
               folderFiles = folderContents.filter { $0.hasSuffix(".mp3") }
               folderFiles.sort { (name1, name2) -> Bool in
                    return name1.localizedStandardCompare(name2) == .orderedAscending
               }
           }
       }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        cell.textLabel?.text = folderFiles[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = folderFiles[indexPath.row]
        
        if let currentPlayingFile = audioPlayer?.url?.lastPathComponent,
           currentPlayingFile == selectedFile {
            // Pause the audio if the selected cell is already playing
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                playPauseButton.setImage(playImage, for: .normal)
            } else {
                audioPlayer.play()
                playPauseButton.setImage(pauseImage, for: .normal)
            }
        } else {
            playAudio(file: selectedFile)
            playPauseButton.setImage(pauseImage, for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80))
        
        footerView.backgroundColor = UIColor.darkGray
        
        playPauseButton.setImage(playImage, for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
        
        // Set the initial play/pause button position
        playPauseButton.frame = CGRect(x: (footerView.frame.width - 100) / 2, y: (footerView.frame.height - 50) / 2, width: 100, height: 50)
        
        // Add the play/pause button to the footer view
        footerView.addSubview(playPauseButton)
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 80
    }
    
    @objc func playPauseButtonTapped(_ sender: UIButton) {
        if (audioPlayer == nil) {
            let firstFile = folderFiles[0]
            playAudio(file: firstFile)
            playPauseButton.setImage(pauseImage, for: .normal)
        } else {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                sender.setImage(playImage, for: .normal)
            } else {
                audioPlayer.play()
                sender.setImage(pauseImage, for: .normal)
            }
        }
    }
    
    // MARK: - Audio Playback
    
    func playAudio(file: String) {
        guard let filePath = Bundle.main.path(forResource: "AudioPlayerFiles/\(folderName!)/\(file)", ofType: nil) else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Perform any necessary actions after audio playback finishes
    }
}
