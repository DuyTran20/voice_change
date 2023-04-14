//
//  AudioPlayer.swift
//  Vocie Change
//
//  Created by Tran Duc Duy on 26/10/2022.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate{
    @ObservedObject
    var vm = AudioRecording()
    
    var audioPlayer: AVAudioPlayer!
    var audioPlay: AVPlayer!
  
    var timer = Timer.publish(every: 0.1,tolerance: 0.05, on: .main, in: .common).autoconnect()
    
    @Published var playValue: TimeInterval = 0.0
    
    @Published var isPlaying = false

    @Published var endDate : Date?
    
    @Published var progress: CGFloat? 
     
    public lazy var objectWillChange = ObservableObjectPublisher()
    
    static let shared = AudioPlayer()
    
     override init(){
        
    }
    func audioPlayer(url: URL){
        let audioSession = AVAudioSession.sharedInstance()
        do{
            //try audioSession.setCategory(.playAndRecord)
            try audioSession.setCategory(.playback,mode: .default)
            try audioSession.setActive(true)
        }catch{
            print("Error - \(error) ")
        }
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            isPlaying = true
            print(url)
        }catch{
            print("Playback Failed : \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, succesfully flag: Bool ){
        self.audioPlayer.stop()
        self.isPlaying = false
    }
    
    
    
    func audioStop(){
        guard audioPlayer != nil else{return}
        self.audioPlayer.stop()
        isPlaying = false
        self.audioPlayer.currentTime = 0.0
        playValue = 0.0
    }
    func pauseSound(){
        if isPlaying == false{
            audioPlayer.pause()
            isPlaying = false
        }
    }
    
    func changeSliderValue(){
        if isPlaying == true {
            pauseSound()
            audioPlayer.currentTime = playValue
        }
        if isPlaying == false{
            audioPlayer?.play()
            isPlaying = true
        }
        
    }
    
    
    func getTimeFileAudio(url: URL?) -> Double{
        guard let url = url else{
            return 1
        }
        let audioAsset = AVURLAsset(url: url)
        let duration = audioAsset.duration
        let durationInSecond = CMTimeGetSeconds(duration)
        
        return Double(durationInSecond)
    }
    
    func covertSecToMinAndHour(seconds : Int) -> String{
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        let min : String = m < 10 ? "0\(m)" : "\(m)"
        return "\(min):\(sec)"
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag{
            isPlaying = false
        }
    }
}
