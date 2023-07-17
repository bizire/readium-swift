//
//  AudioPlayerManager.swift
//  TestApp
//
//  Created by Andrei Aks on 7.07.23.
//

import AVFoundation
import Foundation

class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private override init() {}
    
    private var folderName = ""
    private var fileName = ""
    
    private var sliderUpdateTimer: Timer?
    private let sliderUpdateInterval: TimeInterval = 0.1 // Adjust the interval as desired

    func startSliderUpdateTimer() {
        stopSliderUpdateTimer() // Stop the timer if already running

        sliderUpdateTimer = Timer.scheduledTimer(timeInterval: sliderUpdateInterval, target: self, selector: #selector(updateSliderTimer(_:)), userInfo: nil, repeats: true)
    }

    func stopSliderUpdateTimer() {
        sliderUpdateTimer?.invalidate()
        sliderUpdateTimer = nil
    }

    @objc private func updateSliderTimer(_ timer: Timer) {
        updateSlider()
    }
    
    func playAudio(folderName: String, file: String) {
        guard let filePath = Bundle.main.path(forResource: "AudioPlayerFiles/\(folderName)/\(file)", ofType: nil) else {
            return
        }
        
        if (audioPlayer?.url?.lastPathComponent == file) {
            audioPlayer?.play()
            return
        }
        
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            self.folderName = folderName
            self.fileName = file
            NotificationCenter.default.post(name: Notification.Name("AudioInfoUpdateNotification"), object: nil, userInfo: nil)
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
    }
    
    func resumeAudio() {
        audioPlayer?.play()
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    func destroyPlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func lastPathComponent() -> String? {
        return audioPlayer?.url?.lastPathComponent
    }
    
    func getFolderName() -> String {
        return self.folderName
    }
    
    func getFileName() -> String {
        return self.fileName
    }
    
    func currentTime() -> TimeInterval {
        return audioPlayer?.currentTime ?? 0.0
    }
    
    func setCurrentTime(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func duration() -> TimeInterval {
        return audioPlayer?.duration ?? 0.0
    }
    
    func rate() -> Float {
        return audioPlayer?.rate ?? 0.0
    }
    
    func updateSlider() {
           let currentTime = currentTime()
           let duration = duration()
           
           let progress = Float(currentTime / duration)
           NotificationCenter.default.post(name: Notification.Name("SliderUpdateNotification"), object: nil, userInfo: ["Progress": progress])
       }
}

extension AudioPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying audioplayer playback finished unsuccessfully.")
        guard flag else {
            print("Audio playback finished unsuccessfully.")
            return
        }

        
        NotificationCenter.default.post(name: Notification.Name("AudioPlayerDidFinishPlaying"), object: nil, userInfo: nil)
        
    }
}
