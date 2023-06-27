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
    let playImage = UIImage(named: "player_play")
    let pauseImage = UIImage(named: "player_pause")
    
    let previousButton = UIButton(type: .system)
    let nextButton = UIButton(type: .system)
    
    let currentPositionLabel = UILabel()
    let totalDurationLabel = UILabel()
    let audioSlider = UISlider()
    
    var sliderTimer: Timer?
    
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
    
    let FOOTER_HEIGHT: CGFloat = 100
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: FOOTER_HEIGHT))
        
        footerView.backgroundColor = UIColor.darkGray
        
        let yCenter = (footerView.frame.height - 50) * 0.8
        let xCenter = (footerView.frame.width - 50) / 2
        
        let sliderWidth = footerView.frame.width - 120
        let sliderHeight: CGFloat = 20
        let sliderX = (footerView.frame.width - sliderWidth) / 2

        audioSlider.frame = CGRect(x: sliderX, y: yCenter-20, width: sliderWidth, height: sliderHeight)
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 1
        audioSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        audioSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
        footerView.addSubview(audioSlider)
        
        // Create the previous button
        previousButton.frame = CGRect(x: xCenter - 100, y: yCenter, width: 50, height: 50)
        previousButton.setImage(UIImage(named: "player_previous"), for: .normal)
        previousButton.addTarget(self, action: #selector(previousButtonTapped(_:)), for: .touchUpInside)
        footerView.addSubview(previousButton)
           
        
        playPauseButton.setImage(playImage, for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
        
        // Create the next button
        nextButton.frame = CGRect(x: xCenter + 100, y: yCenter, width: 50, height: 50)
        nextButton.setImage(UIImage(named: "player_next"), for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        footerView.addSubview(nextButton)
        
        // Set the initial play/pause button position
        playPauseButton.frame = CGRect(x: xCenter, y: yCenter, width: 50, height: 50)
        
        // Create the current position label
        
        currentPositionLabel.frame = CGRect(x: xCenter - 160, y: yCenter-35, width: 60, height: 50)
        currentPositionLabel.textColor = UIColor.white
        currentPositionLabel.textAlignment = .center
        currentPositionLabel.font = UIFont.systemFont(ofSize: 9)
        footerView.addSubview(currentPositionLabel)
        
        // Create the total duration label
        totalDurationLabel.frame = CGRect(x: xCenter + 160, y: yCenter-35, width: 60, height: 50)
        totalDurationLabel.textColor = UIColor.white
        totalDurationLabel.textAlignment = .center
        totalDurationLabel.font = UIFont.systemFont(ofSize: 9)
        footerView.addSubview(totalDurationLabel)
        
        // Set the initial values of the position and duration labels
        currentPositionLabel.text = "00:00"
        totalDurationLabel.text = "00:00"
        
        // Add the play/pause button to the footer view
        footerView.addSubview(playPauseButton)
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FOOTER_HEIGHT
    }
    
    @objc func playPauseButtonTapped(_ sender: UIButton) {
        if (audioPlayer == nil) {
            let firstFile = folderFiles[0]
            playAudio(file: firstFile)
            playPauseButton.setImage(pauseImage, for: .normal)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
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
    
    @objc func previousButtonTapped(_ sender: UIButton) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let currentIndex = selectedIndexPath.row
        let previousIndex = currentIndex - 1
        
        if previousIndex >= 0 && previousIndex < folderFiles.count {
            let previousFile = folderFiles[previousIndex]
            playAudio(file: previousFile)
            
            // Deselect the current row
            tableView.deselectRow(at: selectedIndexPath, animated: false)
            
            // Select the previous row
            let previousIndexPath = IndexPath(row: previousIndex, section: selectedIndexPath.section)
            tableView.selectRow(at: previousIndexPath, animated: true, scrollPosition: .none)
        }
    }

    @objc func nextButtonTapped(_ sender: UIButton) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let currentIndex = selectedIndexPath.row
        let nextIndex = currentIndex + 1
        
        if nextIndex >= 0 && nextIndex < folderFiles.count {
            let nextFile = folderFiles[nextIndex]
            playAudio(file: nextFile)
            
            // Deselect the current row
            tableView.deselectRow(at: selectedIndexPath, animated: false)
            
            // Select the next row
            let nextIndexPath = IndexPath(row: nextIndex, section: selectedIndexPath.section)
            tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
        }
    }
    
    var wasPlaying = false
    @objc func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        
        // Pause the audio player if it's currently playing
        if audioPlayer.isPlaying {
            wasPlaying = true
            audioPlayer.pause()
        }
        let duration = audioPlayer.duration
        let seekTime = TimeInterval(value) * duration
        audioPlayer.currentTime = seekTime
        
        
        // Resume playback if it was previously playing
        if !audioPlayer.isPlaying {
            if (wasPlaying){
                audioPlayer.play()
            }
        }
    }
    
    @objc func sliderTouchUp(_ sender: UISlider) {
        if audioPlayer.isPlaying {
            audioPlayer.play()
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
            startSliderTimer()
            // Update the position and duration labels based on the audio player state
            updateDurationLabel(totalDurationLabel)
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func startSliderTimer() {
        sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    @objc func updateSlider() {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        let currentTime = audioPlayer.currentTime
        let duration = audioPlayer.duration
        let sliderValue = Float(currentTime / duration)
        audioSlider.value = sliderValue
        updatePositionLabel(currentPositionLabel)
    }
    
    func updatePositionLabel(_ label: UILabel) {
        if let player = audioPlayer {
            let currentTime = Int(player.currentTime)
            let minutes = currentTime / 60
            let seconds = currentTime % 60
            label.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // Helper method to update the total duration label with the audio player's total duration
    func updateDurationLabel(_ label: UILabel) {
        if let player = audioPlayer {
            let duration = Int(player.duration)
            let minutes = duration / 60
            let seconds = duration % 60
            label.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying audioplayer playback finished unsuccessfully.")
        guard flag else {
            print("Audio playback finished unsuccessfully.")
            return
        }
        
        
        print("flag = \(flag).")
        // Perform any necessary actions after audio playback finishes
        sliderTimer?.invalidate()
        sliderTimer = nil
        
        // Find the index of the current playing file
        guard let currentFile = player.url?.lastPathComponent,
              let currentIndex = folderFiles.firstIndex(of: currentFile) else {
            return
        }
        
        // Check if there is a next file available
        let nextIndex = currentIndex + 1
        if nextIndex < folderFiles.count {
            let nextFile = folderFiles[nextIndex]
            playAudio(file: nextFile)
            tableView.selectRow(at: IndexPath(row: nextIndex, section: 0), animated: true, scrollPosition: .none)
        }
        
        
    }
}
