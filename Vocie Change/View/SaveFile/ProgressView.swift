
import SwiftUI
import RealmSwift
import Realm

struct ProgressView: View {
    
    @State var selectEffect : EffectFactory.ChangeVoice?
    @EnvironmentObject var recordAudio: AudioRecording
    @EnvironmentObject var audioPlayEffect: AudioPlayEffect
    @ObservedObject var play = AudioPlayer.shared
    
    @Environment(\.dismiss) var dismiss
    @State var typeVoiceChange : String
    @State var isLocked : Bool = false
    
    @State var bindingType: AudioChangeScreen = .record
    @State var changeSave: Bool = false
    @State var urlString : String = ""
    var enumCase: AudioChangeScreen
    
    var nameFile : String
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("\(nameFile).m4a")
                    .fontWeight(.semibold)
                    .font(.title2)
                    .padding(.top, 60 )
                

                
                //MARK: Progress Value
                
                switch enumCase {
                case .open:
                    CircularProgress(percentage: $audioPlayEffect.progress)
                        .padding()
                case .record:
                    CircularProgress(percentage: $recordAudio.progress)
                        .padding()
                case .none:
                    Text("")
                        .padding()
                }
                    
                Button {
                   
                    self.isLocked = false
                    if audioPlayEffect.progress == 1.0 || recordAudio.progress == 1.0{
                        changeSave.toggle()
                        print("Done tapped")
                    }
                } label: {
                    Text((audioPlayEffect.progress == 1.0 || recordAudio.progress == 1.0 ? "Done":"Cancel"))
                        .foregroundColor(.white)
                        
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color("background"))
                        .frame(width: 250, height: 50, alignment: .center)
                }
                .padding(.top, 20 )
                
                
                Spacer()
                
            }
            
            .navigationDestination(isPresented: $changeSave) {
                SuccessSaveFile(nameText: nameFile, url: urlString, enumCase: enumCase)
            }
            .onAppear{
                
                DispatchQueue.global(qos: .background).async {
                    switch enumCase {
                    case .open:
                        DispatchQueue.main.async {
                            saveChangeOpenFile()
                            print("save file success on the open file ")
                        }
                    case .record:
                        DispatchQueue.main.async {
                            saveChangeRecordFile()
                            print("save file success on the open file ")
                        }
                        
                    case .none:
                        print("No data input")
                    }
                }
            }
            .onDisappear{
                switch enumCase {
                case .open:
                    audioPlayEffect.progress = 0.0
                    play.playValue = 0.0
                case .record:
                    recordAudio.progress = 0.0
                    play.playValue = 0.0
                case .none:
                    print("Error data")
                }
            }
        }
        .navigationTitle("Save Five")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("Back")
                }

            }
        }
        
    }
    
    func saveChangeRecordFile(){
        if selectEffect == nil{
            selectEffect = .normal
        }
        let url = recordAudio.createAudioChange(effect: EffectFactory.shared.effect(forName: selectEffect!))!
        urlString = url.absoluteString
        do{
            let audioChange = AudioChange()
            audioChange.file = url.lastPathComponent
            audioChange.nameFile = nameFile
            audioChange.changeVoice = typeVoiceChange
            
            let realm = try Realm()
            
            
            
            try realm.write({
                realm.add(audioChange)
                print("Save file success in realm.")
            })
            
            print("File URL : \(audioChange.file)")
        } catch {
            print("Error Save File in Realm")
        }
    }
    func saveChangeOpenFile(){
        
        if selectEffect == nil{
            selectEffect = .normal
        }
        
        let url = audioPlayEffect.createAudioChange(effect: EffectFactory.shared.effect(forName: selectEffect!))!
        urlString = url.absoluteString
        DispatchQueue.main.async {
            do{
                let audioChange = AudioChange()
                audioChange.file = url.lastPathComponent
                audioChange.nameFile = nameFile
                audioChange.changeVoice = typeVoiceChange
                
                let realm = try Realm()
                try realm.write({
                    realm.add(audioChange)
                   print("Save file in realm is success")
                })
                print("-------------\(url.lastPathComponent)")
                print("Open URL : \(audioChange.file)")
                
            }catch{
                
                print("Save file in realm is failed")
            }
        }
       
    }
}

public struct CircularProgress: View {
    @Binding var percentage: Double
    var fontSize: CGFloat = 18.0
    var backgroundColor: Color = .gray.opacity(0.3)
    var fontColor: Color = .black
    var borderColor: Color = Color("background")
    var borderWidth: CGFloat = 10.0
    //var timeProgress = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: borderWidth)
                .opacity(0.3)
                .foregroundColor(backgroundColor)
                
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.percentage, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: borderWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270.0))
                .foregroundColor(borderColor)
                .animation(.linear, value: percentage)
            Text("\(Int(percentage*100))" + "%")
                .foregroundColor(fontColor)
                .font(.system(size: fontSize))
                .fontWeight(.bold)
//                .scaleEffect((percentage/2)+0.9)

        }
        .frame(width: 100, height: 100)
//
    }
}

