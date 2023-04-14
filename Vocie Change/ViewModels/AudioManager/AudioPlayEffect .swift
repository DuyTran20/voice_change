//
//  AudioPlayEffect .swift
//  Vocie Change
//
//  Created by Tran Duc Duy on 03/12/2022.
//

import Foundation

class AudioPlayEffect: ObservableObject{
    var audioFile : Recording?
    
    var audioProcessor : AudioFXProcessor?
    
    @Published var progress:Double = 0.0
    @Published var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @Published var isPlaying:Bool = false
    @Published var sliderValue: Double = 0
    
    func configureAudioProcessor(){
        if let audioFile = self.audioFile{
                try? self.audioProcessor = AudioFXProcessor(audioFile: audioFile)
                self.audioProcessor?.completion = {[weak self] p in
                    DispatchQueue.main.async {
                        self?.progress = p
                        print(self?.progress)
                    }
                    
                }
        }
    }
    func playEffect(withEffect : Effect){
        isPlaying = true
        configureAudioProcessor()
        audioProcessor?.play(withEffect: withEffect)
    }
    
    func progressValue() -> Double {
        progress = audioProcessor!.progress
        return progress
    }
    
    func pauseEffect(){
        audioProcessor?.pauseAudioPlayeR()
        sliderValue = audioProcessor!.currentTime
    }
    
    func stopEffect(){
        audioProcessor?.stopAudioPlayer()
        audioProcessor?.stop()
        sliderValue = 0.0
        isPlaying = false
    }
    
    func changeSliderEffect(){
        if isPlaying == true{
            pauseEffect()
        }
        
        if isPlaying == false{
            audioProcessor?.getAudioPlayerNode().play()
            isPlaying = true
        }
    }
    
    @discardableResult
    func createAudioChange(effect: Effect) -> URL? {
        configureAudioProcessor()
        do{
            return try audioProcessor!.manualAudioRender(effect: effect)
        }catch {
            print("ERRR: \(error.localizedDescription)")
            return nil
        }
    }
    func getDurationFile(audioFile: URL) -> Double {
        let audioAsset = AVURLAsset.init(url: audioFile)
        let duration = audioAsset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        return durationInSeconds
    }
}
class PersistenceManagers{
    private(set) var currentAudioFile: Recording?
    private let fileExtension = ".mp3"
    private let dateFormatter = DateFormatter()
    
    private init(){}
    static let shared = PersistenceManagers()
    //Singleton pattern
    
    //create url for file with Effect
    func urlForEffect(named effectName: EffectFactory.ChangeVoice) throws -> URL{
        let id = UUID().uuidString
        let fileName = "\(effectName)"
        return try urlForFile(named: fileName + "-" + id)
    }
    
    func urlForFile(named fileName: String) throws -> URL{
        let fileName = "\(fileName)\(fileExtension)"
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    func createNewAudioFile(nameFile: String) throws -> Recording{
        let fileURL = try urlForFile(named: nameFile)
        self.currentAudioFile = Recording(fileURL: fileURL, createdAT: dateFormatter.string(from: getFileDate(for: fileURL)))
        return self.currentAudioFile!
    }
    
    func getFileDate(for file: URL) -> Date{
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],let creationDate = attributes[FileAttributeKey.creationDate] as? Date{
            return creationDate
        }else {
            return Date()
        }
    }
}
