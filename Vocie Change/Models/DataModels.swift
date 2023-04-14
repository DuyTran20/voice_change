
import Foundation


class Data: ObservableObject{
   @Published var getData1: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
   @Published var getData2 : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @Published var fileName: String = ""
    
    //let record : Recording = .
}
