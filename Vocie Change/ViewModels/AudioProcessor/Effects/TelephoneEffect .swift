import AVFoundation

class TelephoneEffect: Effect{
    
    
    private(set) var name = EffectFactory.ChangeVoice.telephone
    private(set) var rate:Double = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 100
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.multiDistortedSquared)
        distortionAU.wetDryMix = 100
        
        return [timePitchAU, distortionAU]
    }()
}



class ValleyEffect: Effect{
    private(set) var name = EffectFactory.ChangeVoice.valley
    private(set) var rate: Double = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -100
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.multiEchoTight2)
        distortionAU.wetDryMix = 100
        
        return [timePitchAU, distortionAU]
    }()
}

class DevilEffect: Effect{
    private(set) var name = EffectFactory.ChangeVoice.devil
    private(set) var rate: Double = 0.6
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -200
        timePitchAU.rate =  0.6
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechWaves)
        distortionAU.wetDryMix = 100
        
        return [timePitchAU, distortionAU]
    }()
}


class CaveEffect: Effect{
    private(set) var name = EffectFactory.ChangeVoice.cave
    private(set) var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 0
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.drumsBitBrush)
        distortionAU.wetDryMix = 70
        
        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.largeHall2)
        reverbAU.wetDryMix = 80
        
        return [timePitchAU, distortionAU, reverbAU]
        
    }()
    
}



class DeathEffect:Effect{
    private(set) var name = EffectFactory.ChangeVoice.death
    private(set) var rate = 1.0
    
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.drumsBufferBeats)
        distortionAU.wetDryMix = 1.0
        
        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.smallRoom)
        reverbAU.wetDryMix = 80
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 200
        
        return [timePitchAU, distortionAU,reverbAU ]
    }()
}

class AudiotoriumEffect:Effect{
    private(set) var name = EffectFactory.ChangeVoice.auditorium
    private(set) var rate = 1.0
    
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.multiEchoTight2)
        distortionAU.wetDryMix = 1.0
        
        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.largeRoom)
        reverbAU.wetDryMix = 100
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 50
        
        return [timePitchAU, distortionAU,reverbAU ]
    }()
}

class RadioEffect:Effect{
    private(set) var name = EffectFactory.ChangeVoice.radio
    private(set) var rate = 1.0
    
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechRadioTower)
        distortionAU.wetDryMix = 60
        
        
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -100
        
        return [timePitchAU, distortionAU ]
    }()
}


class CreepMovie:Effect{
    private(set) var name = EffectFactory.ChangeVoice.creep
    private(set) var rate = 1.0
    
    private(set) lazy var audioUnits: [AVAudioUnit] = {
       
        
        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.largeHall2)
        reverbAU.wetDryMix = 60
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 200
        
        return [timePitchAU,reverbAU ]
    }()
}

