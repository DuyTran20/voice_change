import PopupView
import SwiftUI
import RealmSwift
import DSWaveformImage
import DSWaveformImageViews
import SwiftUINavigation
import AVFoundation
import AudioToolbox

struct RecordingListView: View {
    @ObservedResults(AudioChange.self,  sortDescriptor: SortDescriptor(keyPath: "id", ascending: false) )var items
    var success: () -> ()
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var playID: String?
    
    @ObservedObject var play :  AudioPlayer
    
    @ObservedObject var shared = FunctionAction()
    
    @Binding var isAction: Bool
    
    @State var detail: Bool = false
    
    @State var showDelete: Bool = false
    
    @Binding var renameFile : Bool
    
    @State var isAlertDismiss: Bool = false
    
    @State var alert : Bool = false
    
    @State var rename : String = ""
    
    @State var isDetail: Bool = false
    
    @State var action: Bool = false
    
    @State var isPlaying :Bool = false
    
    @State var messageErro: MessengerError?
    
    @State var selectItem : AudioChange 
    
    var body: some View {
        List{
            ForEach(items){item in
                VStack{
                    HStack{
                        Image(item.changeVoice)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.leading)
                        VStack(alignment: .leading, spacing: 5){
                            Text(item.changeVoice)
                                .font(.system(size: 18,weight: .bold))
                            Text(item.nameFile + ".m4a")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .truncationMode(.middle)
                        }.padding(.all, 1)
                        Spacer()
                        Button {
                            
                            if self.playID == item.id.stringValue {
                                self.playID = nil
                            }else {
                                self.playID = item.id.stringValue
                            }
                            if let _ = playID {
                                do{
                                    let url = try getFileRealm(appenConponent: item.file)
                                    print("play audio")
                                    play.audioPlayer(url: url)
                                }catch{
                                    print("error")
                                }
                            }else {
                                play.audioStop()
                            }
                            
                        } label: {
                            Image(playID == item.id.stringValue && play.isPlaying == true   ? "ic_pauseSave":"ic_playSave")
                        }
                        .padding(.trailing , 10)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .frame(width: UIScreen.main.bounds.width - 36, height: 50,alignment: .center)
                .cornerRadius(10)
                .contextMenu{
                    Button {
                        renameFile = true
                        selectItem = item
                    } label: {
                        Label("Rename", systemImage: "d.square")
                    }
                    Button {
                        do{
                            let url = try getFileRealm(appenConponent: item.file)
                            shared.shared(url: url)
                        }catch{
                            print("error : \(error)")
                        }
                        
                        shared.shared(url: URL(string: item.file)!)
                    } label: {
                        HStack{
                            Text("Share")
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    Button {
                        isDetail.toggle()
                        do{
                            let url = try getFileRealm(appenConponent: item.file)
                            detailFile(url:url , name: "\(item.nameFile).\(item.changeVoice)")
                        }catch {
                            print(error)
                        }
                        
                    } label: {
                        HStack{
                            Text("Detail")
                            Image(systemName: "d.circle")
                        }
                    }
                    Button {
                        showDelete = true
                        selectItem = item
                        print(selectItem.id)
                        
                        print("delete")
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        
//        .alert("Do you want to rename this file?", isPresented: $renameFile) {
//
//            TextField("\(selectItem.nameFile)", text: $rename)
//
//            Button("Cancel", role: .cancel, action:{}).foregroundColor(.blue)
//
//            let renameTrimmedFileName = rename.trimmingCharacters(in: .whitespaces)
//
//            Button("Save") {
//               print("\(items)")
//                if  rename.isEmpty || renameTrimmedFileName.isEmpty{
//                    messageErro = MessengerError(title: "Rename Failed", message: "Rename Failed File", button: "OK")
//
//                    print("\(rename)")
//                    
//
//                }else{
//                    updateRealm()
//                }
//            }
//
//        }
        
        .alert(isPresented: $showDelete) {
            Alert(title: Text("Do you want delete this file?"),
                  primaryButton: .destructive(Text("Delete")){
                deleteFile()
            },
                  secondaryButton: .cancel())
        }
        .alert(title: { item in
            Text(item.title)
        }, unwrapping: $messageErro, actions: { item in
            Button {
                withAnimation {
                    if item.message == "Rename File Success"{
                        success()
                    }
                    if item.message == "Rename File Failed"{
                        success()
                    }
                }
            } label: {
                Text(item.button)
            }
            
        }, message: { item in
            Text(item.message)
        })
        .onDisappear{
            playID = nil
            self.play.isPlaying = false
        }
        .onChange(of: scenePhase, perform: { newValue in
            switch newValue{
            case.inactive,.background:
                let audioSession = AVAudioSession.sharedInstance()
                do{
                    try audioSession.setActive(false)
                    
                }catch {
                    print("Error playing \(error.localizedDescription)")
                }
                self.play.audioStop()
              
            default:
                break
            }
        })
    }
    func getFileRealm(appenConponent: String) throws -> URL{
        let fm = FileManager.default
        let documentDirectory = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let url = documentDirectory.appendingPathComponent(appenConponent)
        return url
    }
    
    func updateRealm(){
        let realm = try! Realm()
        let items = realm.objects(AudioChange.self).where {
            $0.id == selectItem.id
        }
        print("item : \(selectItem.id)")
        print(realm.objects(AudioChange.self).map({$0.id}))
        
        do{
            try realm.write({
                for item in items{
                    item.nameFile = rename
                }
                
                messageErro = MessengerError(title: "Rename Success", message: "Rename Success File", button: "OK")
                
            })
            
           
        }catch {
            messageErro = MessengerError(title: "Rename Failed", message: "Rename Failed File", button: "OK")
            print("Error")
        }
    }
    
    
    func detailFile(url: URL, name: String) {
        do{
            let asset = try AVAudioFile(forReading: url)
            let audioFormat = asset.processingFormat
            let sampleRates = audioFormat.sampleRate
            let bitRates = audioFormat.streamDescription.pointee.mBitsPerChannel
            let audioCodes = audioFormat.streamDescription.pointee.mFormatID
            
            let alert = UIAlertController(
                title: "\(name).m4a",
                message: "Audio Code: \(audioCodes) \nSample Rate: \(sampleRates) Hz\nBit Rate: \(bitRates)0 kbs ",
                preferredStyle: .alert
            )
            
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }catch{
            print("Error:\(error.localizedDescription)")
            
        }
        
    }
    
    func deleteFile(){
        let realm = try! Realm()
        let items = realm.objects(AudioChange.self) .where {
            $0.id == selectItem.id
        }
        do{
            try realm.write {
                realm.delete(items)
            }
        }catch {
            print(error)
        }
    }
}
extension AnyTransition{
    static var moveAndFade: AnyTransition{
        .asymmetric(insertion: .move(edge: .bottom).combined(with: .scale), removal: .move(edge: .bottom).combined(with: .scale))
    }
}
