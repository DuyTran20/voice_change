//
//  AudioRecording.swift
//  Vocie Change
//
//  Created by Tran Duc Duy on 26/10/2022.
//

import Foundation
import AVFoundation
import RealmSwift


class AudioRecording : NSObject, ObservableObject, AVAudioRecorderDelegate{
     private var audioRecorder: AVAudioRecorder
    
//    @Published var isRecording : Bool = false
    
    @Published var recordingList = [Recording]()
    
    @Published var isCaptureMode : Bool = false
    
    @Published var minutes: Int = 0
    
    @Published var seconds: Int = 0
    
    @Published var isActive: Bool = false
    
    @Published var recordingTimer : TimeInterval = 0
    
    @Published var samples: [Float] = []
    
    
    //MARK: CO-VOICE
    
    @Published var timerCount: Timer?
    
    @Published var timeText: String = "00:00"
    
    @Published var countSec = 0
    
    @Published var progress: Double = 0.0
    
    //MARK: WAVEFORM
    private var decibelLevelTimer : Timer?
    
    private var timer: Timer?
    
    private var currentSample: Int
    
    private var time :Double = 0
    
     var audioProcessor : AudioFXProcessor?
    
    var audioFile : Recording?
    
    
    
    @Published var isRecording: Bool = false{
        didSet{
            guard oldValue != isRecording else{return}
            if isRecording {
                startRecording()
            }else {
                stopRecording()
            }
        }
    }
    override init(){
        
        self.currentSample = 0
        self.audioRecorder = AVAudioRecorder()
        self.timer = Timer()
    }
    func startRecording(){
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(.playAndRecord, mode: .default,options: [.defaultToSpeaker,.allowBluetoothA2DP,.allowBluetooth,.allowAirPlay])
        }catch{
            print("Error record - \(error)")
        }
        //create new file
        var audioFile : Recording
        do {
            try audioFile = PersistenceManager.shared.createNewAudioFile(nameFile: "\(Date().toString(dateFormat: "YYYYMMdd'-'HHmmss"))")
            self.audioFile = audioFile
            
        }catch {
            return
        }
        
        //setting recording detail
        let recordingSetting: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless ,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        //setup to the recording
        do{
            audioRecorder = try AVAudioRecorder(url: audioFile.fileURL, settings: recordingSetting)
            self.isRecording = true
            audioRecorder.prepareToRecord() 
            audioRecorder.record()
            audioRecorder.isMeteringEnabled = true
            timerCount?.invalidate()
            timerCount = nil
            timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.countSec += 1
                self.timeText = self.convertSecToMin(second: self.countSec)
            })
            
            decibelLevelTimer?.invalidate()
            decibelLevelTimer = nil
            decibelLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                self.audioRecorder.updateMeters()
                let decibel = self.audioRecorder.averagePower(forChannel: 0)
                let linear = 1 - pow(10, decibel / 20)
                self.recordingTimer = self.audioRecorder.currentTime
                self.samples += [linear, linear,linear]
                if self.isRecording == true {
                    self.time += 1
                    
                    self.seconds = Int(self.time * 0.01) % 60
                    self.minutes = (Int(self.time * 0.01)/60)%60
                }
            })

//            startMonitoring()
        }catch {
            print("Failed setup to the recording: \(error.localizedDescription)")
        }
    }
    

    func stopRecording(){
        
        isRecording = false
        timer?.invalidate()
        recordingTimer = .zero
        decibelLevelTimer?.invalidate()
        timerCount?.invalidate()
        seconds = 0
        minutes = 0
        time = 0
        countSec = 0
        audioRecorder.stop()
        self.currentSample = 0
    }
    
    
    deinit{
        if isRecording{
            stopRecording()
        }
    }
    
}

extension AudioRecording{
    func configureAudioProcessor(){
        if let audioFile = self.audioFile{
            do{
                try self.audioProcessor = AudioFXProcessor(audioFile: audioFile)
                audioProcessor?.completion = { [weak self] in
                    self?.progress = $0
                }
            }catch {
                return
            }
        }
    }
    func playEffect(withEffect : Effect){
        isActive = true
        configureAudioProcessor()
        audioProcessor?.play(withEffect: withEffect)
    }
    
    func stopEffect(){
        
        audioProcessor?.stopAudioPlayer()
    }
    
    @discardableResult
    func createAudioChange(effect: Effect) -> URL? {
        configureAudioProcessor()
        guard let fileURL = try? PersistenceManager.shared.urlForEffect(named: effect.name)else{
            return nil
        }
        if !FileManager.default.fileExists(atPath: fileURL.path){
            do{
                return try audioProcessor?.manualAudioRender(effect: effect)
            }catch {
                print(error)
                return nil
            }
        }
        return nil
    }
}


extension Date{
    
    func toString(dateFormat format: String) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
        
    }
    
}
extension AudioRecording{
    func convertSecToMin(second: Int) -> String {
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10  ? "0\(s)" : "\(s)"
        let min : String = m < 10  ? "0\(m)" : "\(m)"
        return "\(min):\(sec)"
    }
}
