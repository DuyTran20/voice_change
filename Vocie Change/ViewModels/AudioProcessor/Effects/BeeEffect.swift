
import AVFoundation

class BeeEffect: Effect {
    private(set) var name = EffectFactory.ChangeVoice.bee
    private(set) var rate = 1.5
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 1500
        timePitchAU.rate = Float(rate)
        
        return [timePitchAU]
    }()
}

