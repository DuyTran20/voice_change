import AVFoundation

class FunnyEffect: Effect {
    private(set) var name = EffectFactory.ChangeVoice.funny
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 500 //thay đổi độ trầm bổng
        
        return [timePitchAU]
    }()
}
