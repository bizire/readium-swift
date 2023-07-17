//
//  FolderContentViewController.swift
//  TestApp
//
//  Created by Andrei Aks on 14.07.23.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import RevenueCat
import MediaPlayer

class FolderContentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  AVAudioPlayerDelegate {
    var folderName: String!
    var folderHumanTitle: String!
    var currentFileIndex = 0
    var currentFile = ""
    var folderFiles = [String]()
    
    let playPauseButton = UIButton()
    let playImage = UIImage(named: "player_play")
    let pauseImage = UIImage(named: "player_pause")
    
    let previousButton = UIButton()
    let previousImage = UIImage(named: "player_previous")
    
    let nextButton = UIButton()
    let nextImage = UIImage(named: "player_next")
    
    let audioFileLabel = UILabel()
    
    let currentPositionLabel = UILabel()
    let totalDurationLabel = UILabel()
    let audioSlider = UISlider()
    let sliderThumb = UIImage(named: "slider_thumb")
    
    var sliderTimer: Timer?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("folderNames FolderContentViewController viewDidLoad")
        
        tableView.dataSource = self
        tableView.delegate = self
        print("folderNames folderName = \(folderName)")
        loadFolderFiles()
 
        audioSlider.setThumbImage(sliderThumb, for: .normal)
        audioSlider.setThumbImage(sliderThumb, for: .highlighted)
        audioSlider.minimumTrackTintColor = .white.withAlphaComponent(0.6)
        
        nextButton.tintColor = .white
        previousButton.tintColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSliderUpdateNotification(_:)), name: Notification.Name("SliderUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioInfoNotification(_:)), name: Notification.Name("AudioInfoUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioPlayerDidFinish(_:)), name: Notification.Name("AudioPlayerDidFinishPlaying"), object: nil)
        
        setupRemoteControl()
    }
    
    func setupRemoteControl(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "YoPlayer"]
        
        setupRemoteTransportControls()
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            currentFile = folderFiles[currentFileIndex]
            print("\(currentFileIndex): commandCenter.playCommand.addTarget \(folderName) - \(currentFile)")
            if !AudioPlayerManager.shared.isPlaying() {
                AudioPlayerManager.shared.playAudio(folderName: folderName, file: currentFile)
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            print("commandCenter.pauseCommand.addTarget")
            if AudioPlayerManager.shared.isPlaying() {
                AudioPlayerManager.shared.pauseAudio()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget{ [unowned self] event in
            print("commandCenter.nextTrackCommand.addTarget")
            nextButtonTapped(UIButton())
            return .success
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget{ [unowned self] event in
            print("commandCenter.nextTrackCommand.addTarget")
            previousButtonTapped(UIButton())
            return .success
        }
    }
    
    func updateNowPlayingInfo() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        currentFile = (folderFiles[currentFileIndex] as NSString).deletingPathExtension
        nowPlayingInfo[MPMediaItemPropertyTitle] = "\(folderName!) - \(currentFile)"
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = AudioPlayerManager.shared.currentTime()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = AudioPlayerManager.shared.duration()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = AudioPlayerManager.shared.rate()
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        if (AudioPlayerManager.shared.isPlaying()) {
            MPNowPlayingInfoCenter.default().playbackState = .playing
        } else {
            MPNowPlayingInfoCenter.default().playbackState = .paused
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        AudioPlayerManager.shared.setupAudioSessionForBackgroundPlayback()
//        AudioPlayerManager.shared.setupRemoteTransportControls()
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            AudioPlayerManager.shared.destroyPlayer()
        }
    }
    
    @objc func handleSliderUpdateNotification(_ notification: Notification) {
        if let progress = notification.userInfo?["Progress"] as? Float {
            audioSlider.value = progress
            updatePositionLabel(currentPositionLabel)
        }
    }
    
    @objc func handleAudioInfoNotification(_ notification: Notification) {
        updateDurationLabel(totalDurationLabel)
        updateFileInfoLabel(audioFileLabel, folderHumanTitle)
    }
    
    @objc func handleAudioPlayerDidFinish(_ notification: Notification) {
        print("audioPlayerDidFinishPlaying audioplayer playback finished unsuccessfully.")

        // Find the index of the current playing file
        guard let currentFile = AudioPlayerManager.shared.lastPathComponent(),
              let currentIndex = folderFiles.firstIndex(of: currentFile) else {
            return
        }
        
        // Check if there is a next file available
        let nextIndex = currentIndex + 1
        if nextIndex < folderFiles.count {
            let nextFile = folderFiles[nextIndex]
//            playAudio(file: nextFile)
            AudioPlayerManager.shared.playAudio(folderName: folderName, file: nextFile)
            tableView.selectRow(at: IndexPath(row: nextIndex, section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SliderUpdateNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AudioInfoUpdateNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AudioPlayerDidFinishPlaying"), object: nil)
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
        let fileName = folderFiles[indexPath.row]
        let fileNameWithoutExtension = (fileName as NSString).deletingPathExtension
        cell.textLabel?.text = "\(folderHumanTitle!) - Chapter: \(fileNameWithoutExtension)"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = folderFiles[indexPath.row]
        
        if let currentPlayingFile = AudioPlayerManager.shared.lastPathComponent(),
           currentPlayingFile == selectedFile {
            // Pause the audio if the selected cell is already playing
            if AudioPlayerManager.shared.isPlaying() {
                AudioPlayerManager.shared.pauseAudio()
                playPauseButton.setImage(playImage, for: .normal)
            } else {
                AudioPlayerManager.shared.playAudio(folderName: folderName, file: selectedFile)
                playPauseButton.setImage(pauseImage, for: .normal)
            }
        } else {
            AudioPlayerManager.shared.playAudio(folderName: folderName, file: selectedFile)
            AudioPlayerManager.shared.startSliderUpdateTimer()
            playPauseButton.setImage(pauseImage, for: .normal)
        }
        
        currentFileIndex = indexPath.row
        updateNowPlayingInfo()
    }
    
    let FOOTER_HEIGHT: CGFloat = 80
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView.numberOfRows(inSection: section) == 0 {
               return nil  // Return nil to hide the footer view
           }
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: FOOTER_HEIGHT))
        
        footerView.backgroundColor = UIColor.darkGray
        
        let yCenter = (footerView.frame.height - 40) * 0.8
        let xCenter = (footerView.frame.width - 50) / 2
        
        let timeLabelWidth: CGFloat = 60
        let sliderWidth = footerView.frame.width * 0.6
        let sliderHeight: CGFloat = 20
        let sliderX = (footerView.frame.width - sliderWidth) / 2
        
        audioFileLabel.frame = CGRect(x: sliderX, y: yCenter-30, width: sliderWidth, height: sliderHeight)
        audioFileLabel.textColor = UIColor.white
        audioFileLabel.textAlignment = .center
        audioFileLabel.font = UIFont.systemFont(ofSize: 9)
        footerView.addSubview(audioFileLabel)
        audioFileLabel.text = "Audio Bible"

        audioSlider.frame = CGRect(x: sliderX, y: yCenter-15, width: sliderWidth, height: sliderHeight)
        audioSlider.minimumValue = 0
        audioSlider.maximumValue = 1
        audioSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        audioSlider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)
        footerView.addSubview(audioSlider)
        
        // Create the previous button
        previousButton.frame = CGRect(x: xCenter - 100, y: yCenter, width: 50, height: 50)
        previousButton.setImage(previousImage, for: .normal)
        previousButton.addTarget(self, action: #selector(previousButtonTapped(_:)), for: .touchUpInside)
        footerView.addSubview(previousButton)
           
        // Set the initial play/pause button position
        playPauseButton.setImage(playImage, for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped(_:)), for: .touchUpInside)
        playPauseButton.frame = CGRect(x: xCenter, y: yCenter, width: 50, height: 50)
        footerView.addSubview(playPauseButton)
        
        // Create the next button
        nextButton.setImage(nextImage, for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        nextButton.frame = CGRect(x: xCenter + 100, y: yCenter, width: 50, height: 50)
        footerView.addSubview(nextButton)
        
        // Create the current position label
        currentPositionLabel.frame = CGRect(x: sliderX/2 - timeLabelWidth/2, y: yCenter-30, width: timeLabelWidth, height: 50)
        currentPositionLabel.textColor = UIColor.white
        currentPositionLabel.textAlignment = .center
        currentPositionLabel.font = UIFont.systemFont(ofSize: 9)
        footerView.addSubview(currentPositionLabel)
        
        // Create the total duration label
        totalDurationLabel.frame = CGRect(x: footerView.frame.width - sliderX/2 - timeLabelWidth/2, y: yCenter-30, width: timeLabelWidth, height: 50)
        totalDurationLabel.textColor = UIColor.white
        totalDurationLabel.textAlignment = .center
        totalDurationLabel.font = UIFont.systemFont(ofSize: 9)
        footerView.addSubview(totalDurationLabel)
        
        // Set the initial values of the position and duration labels
        currentPositionLabel.text = "00:00"
        totalDurationLabel.text = "00:00"
        
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return FOOTER_HEIGHT
    }
    
    @objc func playPauseButtonTapped(_ sender: UIButton) {
   
            if AudioPlayerManager.shared.isPlaying() {
                AudioPlayerManager.shared.pauseAudio()
                AudioPlayerManager.shared.stopSliderUpdateTimer()
                sender.setImage(playImage, for: .normal)
            } else {
                AudioPlayerManager.shared.playAudio(folderName: folderName, file: folderFiles[currentFileIndex])
                AudioPlayerManager.shared.startSliderUpdateTimer()
                sender.setImage(pauseImage, for: .normal)
            }
        updateNowPlayingInfo()
    }
    
    @objc func previousButtonTapped(_ sender: UIButton) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let currentIndex = selectedIndexPath.row
        let previousIndex = currentIndex - 1
        
        if previousIndex >= 0 && previousIndex < folderFiles.count {
            let previousFile = folderFiles[previousIndex]
//            playAudio(file: previousFile)
            AudioPlayerManager.shared.playAudio(folderName: folderName, file: previousFile)
            
            // Deselect the current row
            tableView.deselectRow(at: selectedIndexPath, animated: false)
            
            // Select the previous row
            let previousIndexPath = IndexPath(row: previousIndex, section: selectedIndexPath.section)
            tableView.selectRow(at: previousIndexPath, animated: true, scrollPosition: .none)
            currentFileIndex = previousIndex
        }
        updateNowPlayingInfo()
    }

    @objc func nextButtonTapped(_ sender: UIButton) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let currentIndex = selectedIndexPath.row
        let nextIndex = currentIndex + 1
        
        if nextIndex >= 0 && nextIndex < folderFiles.count {
            let nextFile = folderFiles[nextIndex]
//            playAudio(file: nextFile)
            AudioPlayerManager.shared.playAudio(folderName: folderName, file: nextFile)
            
            // Deselect the current row
            tableView.deselectRow(at: selectedIndexPath, animated: false)
            
            // Select the next row
            let nextIndexPath = IndexPath(row: nextIndex, section: selectedIndexPath.section)
            tableView.selectRow(at: nextIndexPath, animated: true, scrollPosition: .none)
            currentFileIndex = nextIndex
        }
        updateNowPlayingInfo()
    }
    
    var wasPlaying = false
    @objc func sliderValueChanged(_ sender: UISlider) {
        let value = sender.value
        
        // Pause the audio player if it's currently playing
        if AudioPlayerManager.shared.isPlaying() {
            wasPlaying = true
            AudioPlayerManager.shared.pauseAudio()
        }
        let duration = AudioPlayerManager.shared.duration()
        let seekTime = TimeInterval(value) * duration
        AudioPlayerManager.shared.setCurrentTime(time: seekTime)
        
        
        // Resume playback if it was previously playing
        if !AudioPlayerManager.shared.isPlaying() {
            if (wasPlaying){
                AudioPlayerManager.shared.resumeAudio()
            }
        }
    }
    
    @objc func sliderTouchUp(_ sender: UISlider) {
        if AudioPlayerManager.shared.isPlaying() {
            AudioPlayerManager.shared.resumeAudio()
        }
    }
    
    // MARK: - Audio Playback
    
    func updatePositionLabel(_ label: UILabel) {
 
            let currentTime = Int(AudioPlayerManager.shared.currentTime())
            let minutes = currentTime / 60
            let seconds = currentTime % 60
            label.text = String(format: "%02d:%02d", minutes, seconds)
    
    }

    // Helper method to update the total duration label with the audio player's total duration
    func updateDurationLabel(_ label: UILabel) {
   
            let duration = Int(AudioPlayerManager.shared.duration())
            let minutes = duration / 60
            let seconds = duration % 60
            label.text = String(format: "%02d:%02d", minutes, seconds)
    
    }
    
    func updateFileInfoLabel(_ label: UILabel, _ title: String) {
        label.text = title + " - Chapter: " + (AudioPlayerManager.shared.getFileName() as NSString).deletingPathExtension
    }
}
