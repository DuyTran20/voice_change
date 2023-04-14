import AVFoundation

protocol Effect {
    var name: EffectFactory.ChangeVoice { get }
    var rate: Double { get }
    var audioUnits: [AVAudioUnit] { get }
}
