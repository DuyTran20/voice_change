
import Foundation
import RealmSwift

final class AudioChange: Object, Identifiable{
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var file: String = ""
    
    @Persisted var nameFile: String = ""
    
    @Persisted var changeVoice: String = EffectFactory.ChangeVoice.normal.rawValue
    
    override class func primaryKey() -> String? {
        "id"
    }
}


