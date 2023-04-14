import AVFoundation
import SwiftUI

class AudioFXProcessor:ObservableObject {
    private let maxNumberOfFrames: AVAudioFrameCount = 8192
    let avAudioFile: AVAudioFile!

    private var audioPlayerNode = AVAudioPlayerNode()
    private var audioEngine = AVAudioEngine()
    private var isPlaying : Bool = false
    @Published var playing: Bool = false
    @Published var playValue:Float = 0.0
    @Published var currentTime = 0.0
    @Published var progress: Double = 0.0
    @Published var isSuccess:Bool = false
    var completion : ((Double) -> Void)?
    var success:((Bool) -> Void)?
    
    private var currentFrame: AVAudioFramePosition{
        guard let lastRenderTime = audioPlayerNode.lastRenderTime,
              let playerTime = audioPlayerNode.playerTime(forNodeTime: lastRenderTime)
        else {
            return 0
        }
        return playerTime.sampleTime
    }
    
    init(audioFile: Recording) throws {
        self.avAudioFile = try AVAudioFile(forReading: audioFile.fileURL)
    }
}
// MARK: - Private methods
extension AudioFXProcessor {
    private func prepareAudioEngine(forEffect effect: Effect) {
        // It's needed to stop and reset the audio engine before creating a new one to avoid crashing
        stop()
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        var previousNode: AVAudioNode = audioPlayerNode
        for audioUnit in effect.audioUnits {
            audioEngine.attach(audioUnit)
            audioEngine.connect(previousNode, to: audioUnit, format: nil)
            previousNode = audioUnit
        }
        audioEngine.connect(previousNode, to: audioEngine.mainMixerNode, format: nil)
    }
}

// MARK: Internal methods
extension AudioFXProcessor {
    
    @discardableResult
    func  manualAudioRender(effect: Effect) throws -> URL {
        prepareAudioEngine(forEffect: effect)
        
        audioPlayerNode.scheduleFile(avAudioFile, at: nil)
        try audioEngine.enableManualRenderingMode(.offline, format: avAudioFile.processingFormat, maximumFrameCount: maxNumberOfFrames)
        
        try audioEngine.start()
        audioPlayerNode.play()
        
        let outputFile: AVAudioFile
        
        let url = try PersistenceManager.shared.urlForEffect(named: effect.name)
        print("\(url)")
        
        let recordSettings = avAudioFile.fileFormat.settings
        let processingFormatSettings = avAudioFile.processingFormat.settings
        
        print("RECORDSETTING:   \(recordSettings)")
        print("PROCESSTING:     \(processingFormatSettings)")
        
        outputFile = try AVAudioFile(forWriting: url, settings:  processingFormatSettings)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat, frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!
        
        // Adjust the file size based on the effect rate
        let outputFileLength = Int64(Double(avAudioFile.length) / effect.rate)
        
        while audioEngine.manualRenderingSampleTime < outputFileLength {
            let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(outputFileLength - audioEngine.manualRenderingSampleTime))
            let status = try audioEngine.renderOffline(framesToRender, to: buffer)
            switch status {
            case .success:
                try outputFile.write(from: buffer)
                print("Write success in file\(buffer)")
                isSuccess = true
                let precentComplete = Float(audioEngine.manualRenderingSampleTime) / Float(outputFileLength)
                progress = Double(min(max(precentComplete, 0.0), 1.0))
                completion?(progress)
                print("Progreess : \(progress)")
                
            case .error:
                isSuccess = false
                print("Error rendering offline audio")
                return url
            default:
                return url
            }
        }
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.disableManualRenderingMode()
        return url
    }
    
    func progressValue()-> Double {
        return progress
    }
    
    func stopAudioPlayer(){
        audioPlayerNode.stop()
        playing = false
    }
    
    func pauseAudioPlayeR(){
        if playing == true{
            audioPlayerNode.pause()
            playing = false
        }
    }
    func currentTimes() -> Double {
        audioPlayerNode.currentTime
    }

    
    func getAudioPlayerNode()->AVAudioPlayerNode{
        audioPlayerNode
    }
    
    //play with effect when change audio
    func play(withEffect effect: Effect) {
        audioPlayerNode = AVAudioPlayerNode()
        prepareAudioEngine(forEffect: effect)
        audioPlayerNode.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
       playing = true
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error starting audio engine.\n\(error.localizedDescription)")
        }
        audioPlayerNode.play()
        
    }
    func playEffect(){
        audioPlayerNode.play()
    }
    
    func stop() {
        playing = false
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
}

class PersistenceManager {
    
    private(set) var currentAudioFile: Recording?
    private let fileExtension = ".m4a"
    private let dateFormatter = DateFormatter()
    
    // Singleton pattern
    private init() {}
    static let shared = PersistenceManager()
    //create url for file with effect
    func urlForEffect(named effectName: EffectFactory.ChangeVoice) throws -> URL {
        let id = UUID().uuidString
        let fileName = "\(effectName)"
        return try urlForFile(named: id + "_" + fileName)
    }
    //create url for file
    func urlForFile(named fileName: String) throws -> URL {
        let fileName = "\(fileName)\(fileExtension)"
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let url = documentDirectory.appendingPathComponent(fileName)
        return url
    }
    
    //create name file
    func createNewAudioFile(nameFile : String) throws -> Recording {
        let fileURL = try urlForFile(named: nameFile)
        self.currentAudioFile = Recording(fileURL: fileURL, createdAT: dateFormatter.string(from: getFileDate(for: fileURL)))
        return self.currentAudioFile!
    }
}

extension PersistenceManager{
    func getFileDate(for file: URL) -> Date {
        
            if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
                let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                return creationDate
            } else {
                return Date()
            }
        }
}

extension AVAudioPlayerNode{
    var currentTime : Double {
        get {
            if let nodeTime: AVAudioTime = self.lastRenderTime, let playerTime: AVAudioTime = self.playerTime(forNodeTime: nodeTime){
                return Double(playerTime.sampleTime) / playerTime.sampleRate
            }
            return 0
        }
    }
}

extension AudioFXProcessor{
    func sliderAudioEffect(time: Double){
        currentTime = time
        self.audioPlayerNode.stop()
        self.audioPlayerNode.scheduleSegment(avAudioFile, startingFrame: AVAudioFramePosition(self.currentTime * avAudioFile.processingFormat.sampleRate), frameCount: AVAudioFrameCount(Double(avAudioFile.length) - self.currentTime), at: nil, completionHandler: nil)
        self.audioPlayerNode.play()
    }
}

extension AudioFXProcessor {
    //play with effect when change audio
    func plays(withEffect effect: Effect) {
        audioPlayerNode = AVAudioPlayerNode()
        prepareAudioEngine(forEffect: effect)
        audioPlayerNode.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
       
        do {
            try audioEngine.start()
        } catch let error as NSError {
            print("Error starting audio engine.\n\(error.localizedDescription)")
        }
        audioPlayerNode.play()
    }
    
    func stops() {
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
}


