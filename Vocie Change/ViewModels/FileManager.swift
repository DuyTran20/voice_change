

import Foundation
import SwiftUI
import RealmSwift


class AudioStorageManagement: ObservableObject{
    var selectEffect: EffectFactory.ChangeVoice?
    var recordingAudio = AudioRecording()
    var audioPlayEffect = AudioPlayEffect()
    var viewData = Data()
    @ObservedRealmObject var audioRcording = AudioChange()
    @ObservedResults(AudioChange.self) var audioChange
    func saveChangeRecordFile(fileName:String, typeVoiceChange: String){
        if selectEffect == nil {
            selectEffect = .normal
        }
        let url = recordingAudio.createAudioChange(effect: EffectFactory.shared.effect(forName: selectEffect!))!
        do{
            let audioChange = AudioChange()
            audioChange.file = url.lastPathComponent
            audioChange.nameFile = fileName
            audioChange.changeVoice = typeVoiceChange
            
            let realm = try Realm()
            
            try realm.write({
                realm.add(audioChange)
                print("Save file success")
            })
        }catch{
            print("Failed save file record in realm")
        }
    }
    
    func saveChangeOpenFile(fileName: String, typeVoiceChange: String){
        if selectEffect == nil{
            selectEffect = .normal
        }
        let url = audioPlayEffect.createAudioChange(effect: EffectFactory.shared.effect(forName: selectEffect!))!
        do{
            let audioChange = AudioChange()
            audioChange.file = url.lastPathComponent
            audioChange.nameFile = fileName
            audioChange.changeVoice = typeVoiceChange
            
            let realm = try Realm()
            
            try realm.write({
                realm.add(audioChange)
                print("Save file open success !")
            })
        }catch{
            print("Save file open failed !")
        }
    }
    func sliderForRecord(){
        let effect = EffectFactory.shared.effect(forName: selectEffect ?? EffectFactory.ChangeVoice.normal)
        let sampleRate = ((audioPlayEffect.audioProcessor?.currentTimes() ?? 0) / audioPlayEffect.getDurationFile(audioFile: viewData.getData2) * effect.rate)
        
        audioPlayEffect.sliderValue = sampleRate * 100
        
        if audioPlayEffect.sliderValue > 100 {
            audioPlayEffect.sliderValue = 0.0
            audioPlayEffect.isPlaying = false
        }
            
    }
    func silderForOpenFile(){
        let effect = EffectFactory.shared.effect(forName: selectEffect ?? EffectFactory.ChangeVoice.normal)
        let sampleRate = ((audioPlayEffect.audioProcessor?.currentTimes() ?? 0) / audioPlayEffect.getDurationFile(audioFile: viewData.getData1) * effect.rate)
        
        audioPlayEffect.sliderValue = sampleRate * 100
        if audioPlayEffect.sliderValue > 100 {
            audioPlayEffect.sliderValue = 0.0
            audioPlayEffect.isPlaying = false
        }
    }
}
