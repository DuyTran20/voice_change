import AVFoundation
import RealmSwift

class EffectFactory {
    
    enum ChangeVoice: String ,CaseIterable,Identifiable, PersistableEnum{
        
        case normal = "Normal"
        case cave = "Cave"
        case vader1 = "Darth Vader1"
        case bee = "Bee"
        case chipmunk = "Chipmunk"
        case telephone = "Telephone"
        case drunk = "Drunk"
        case devil = "Devil"
        case valley = "Valley"
        case alien = "Alien"
        case death = "Death"
        case droid = "Protocol droid"
        case robot = "Robot"
        case fan = "Fan"
        case funny = "Funny"
        case frank = "Frankenstein"
        case lost = "Lost in space"
        case auditorium = "Auditorium"
        case radio = "CB Radio"
        case creep = "Creep Movie"
        
        
        var id: String {
            return self.rawValue
        }
    }
    
    // Singleton pattern
    private init() {}
    static let shared = EffectFactory()
    
    func effect(forName effectName: EffectFactory.ChangeVoice) -> Effect {
        switch effectName {
        
        case .normal:
            return NormalEffect()
        case .cave:
           return CaveEffect()
        case .vader1:
           return DarthVaderEffect()
        case .bee:
            return BeeEffect()
        case .chipmunk:
            return ChipmunkEffect()
        case .telephone:
            return TelephoneEffect()
        case .drunk:
            return DrunkEffect()
        case .devil:
            return DevilEffect()
        case .valley:
            return ValleyEffect()
        case .fan:
            return FanEffect()
        case .alien:
            return AlienEffect()
        case .death:
            return DeathEffect()
        case .droid:
            return DroidEffect()
        case .robot:
            return RobotEffect()
        case .funny:
            return FunnyEffect()
        case .frank:
            return FrankEffect()
        case .lost:
            return LostinSpaceEffect()
        case .auditorium:
            return AudiotoriumEffect()
        case .radio:
            return RadioEffect()
        case .creep:
            return CreepMovie()
        }
    }
}
