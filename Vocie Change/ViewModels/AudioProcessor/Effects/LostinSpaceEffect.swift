import AVFoundation

class LostinSpaceEffect : Effect{
    private(set) var name = EffectFactory.ChangeVoice.lost
    private(set) var rate: Double = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 100
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechCosmicInterference) //biến dạng giao thoa vũ trụ.
        distortionAU.wetDryMix = 100
        
        return [timePitchAU, distortionAU]
    }()
}
class RobotEffect: Effect{
    private(set) var name: EffectFactory.ChangeVoice = EffectFactory.ChangeVoice.robot
    private(set) var rate: Double = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timPitchAU = AVAudioUnitTimePitch()
        timPitchAU.pitch = -300
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.multiEchoTight1)
        distortionAU.wetDryMix = 100
        
        return[timPitchAU,distortionAU]
    }()
}
