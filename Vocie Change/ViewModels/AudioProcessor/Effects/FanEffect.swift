import AVFoundation

class DroidEffect: Effect {
    private(set) var name = EffectFactory.ChangeVoice.droid
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechRadioTower)
        distortionAU.wetDryMix = 50
        
        let timePitchAU = AVAudioUnitTimePitch()
         timePitchAU.rate = 1.0
        return [distortionAU]
    }()
}


class FanEffect: Effect{
    private(set) var name = EffectFactory.ChangeVoice.fan
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechWaves)
        distortionAU.wetDryMix = 100
        
       let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.rate = 1.0
        timePitchAU.pitch = 100
         

        return [distortionAU, timePitchAU]
    }()
}
