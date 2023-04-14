import AVFoundation

class NormalEffect: Effect {
    private(set) var name = EffectFactory.ChangeVoice.normal
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 0
        
        return [timePitchAU]
    }()
}
