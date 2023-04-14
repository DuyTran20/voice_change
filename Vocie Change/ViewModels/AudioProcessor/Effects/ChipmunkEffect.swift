import AVFoundation

class ChipmunkEffect: Effect {
    private(set) var name = EffectFactory.ChangeVoice.chipmunk
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 850
        
        return [timePitchAU]
    }()
}


