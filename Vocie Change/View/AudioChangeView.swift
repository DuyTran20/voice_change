import SwiftUI
import RealmSwift
import SwiftUINavigation
import CoreMedia

struct AudioChangeView: View {
    var recording : () -> ()
    
    @ObservedObject var playAudio = AudioPlayer.shared
    @EnvironmentObject var recordAudio : AudioRecording
    @EnvironmentObject var playEffect : AudioPlayEffect
    
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    @ObservedResults(AudioChange.self) var audioChange
    @ObservedRealmObject var audioRcording = AudioChange()
    //    @ObservedObject var audioVM : AudioFXProcessor
    @ObservedObject var viewModel = Data()
    //    var model: Recording
    @State var url : String = ""
    @State var title : String = ""
    
    @State var voiceChange: [EffectFactory.ChangeVoice]
    @State var success :Bool = false
    @State var failed : Bool = true
    @State var showWarning: Bool = false
    @State var onSave: Bool = false
    
    
    
    @State private var saveFile : Bool = false
    @State private var importFile: Bool = false
    @State private var rename : String = ""
    @State private var failedFile : Bool = false
    @State private var imageChange: String = ""
    @State private var fourColumn = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State var messageError : MessengerError?
    @AppStorage("voicecurrent") var voiceCurrent : String = EffectFactory.ChangeVoice.normal.rawValue
    
    @State var typeVoiceChange: String = EffectFactory.ChangeVoice.normal.rawValue
    var enumCase: AudioChangeScreen = .none
    @Environment(\.presentationMode) var back
    
    @Environment(\.dismiss) var dismiss
    @State var selectEffect : EffectFactory.ChangeVoice?
    @State private var buttonPlay: Bool = false
    
    var body: some View {
        
        NavigationStack{
            ZStack{
                VStack{
                    HStack(){
                        Button {
                            self.back.wrappedValue.dismiss()
                        } label: {
                            Image("Back")
                        }
                        Spacer()
                        
                        Text("Audio Change")
                            .font(.headline)
                            .padding(.trailing , 20)
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.width - 50, height: 50, alignment: .center)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: fourColumn) {
                            ForEach($voiceChange) { myVoice in
                                ButtonChange(valueVoice: myVoice) {value in
                                    switch enumCase {
                                    case .open:
                                        typeVoiceChange = value
                                        self.selectEffect = myVoice.wrappedValue
                                        let effect = EffectFactory.shared.effect(forName: selectEffect!)
                                        playEffect.playEffect(withEffect: effect)
                                        playEffect.isPlaying = true
                                    case .record:
                                        typeVoiceChange = value
                                        self.selectEffect = myVoice.wrappedValue
                                        let effect = EffectFactory.shared.effect(forName: selectEffect!)
                                        recordAudio.playEffect(withEffect: effect)
                                        playEffect.isPlaying = true
                                    case .none:
                                        messageError = MessengerError(title: "Error", message: "No Data Input", button: "OK")
                                    }
                                }
                            }
                        }
                    }
                    VStack{
                        Text(title)
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(alignment: .center)
                        
                        HStack(spacing: 10 ){
                            Spacer()
                            Button {
                                playEffect.isPlaying.toggle()
                                withAnimation {
                                    if playEffect.isPlaying == false && playEffect.sliderValue > 100  {
                                        
                                        switch enumCase {
                                        case .open:
                                            
                                            playEffect.stopEffect()
                                            playEffect.timer.upstream.connect().cancel()
                                        case .record:
                                            playEffect.stopEffect()
                                            playEffect.timer.upstream.connect().cancel()
                                        case .none:
                                            messageError = MessengerError(title: "Error", message: "No Data Input", button: "OK")
                                        }
                                    }else {
                                        switch enumCase {
                                        case .open:
                                            let effect = EffectFactory.shared.effect(forName: selectEffect ?? EffectFactory.ChangeVoice.normal)
                                            playEffect.playEffect(withEffect: effect)
                                        case .record:
                                            let effect = EffectFactory.shared.effect(forName: selectEffect ?? EffectFactory.ChangeVoice.normal)
                                            playEffect.playEffect(withEffect: effect)
                                        case .none:
                                            messageError = MessengerError(title: "Failed", message: "No Data Input", button: "OK")
                                        }
                                    }
                                    
                                }
                            } label: {
                                if playEffect.isPlaying == false {
                                    Image(systemName: "play.fill")
                                }else{
                                    Image(systemName: "stop.fill")
                                }
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                            .padding(.trailing, 5)
                            
                            Spacer()
                            
                            //MARK: Slider
                            
                            Slider(value: $playEffect.sliderValue, in: 1...100, onEditingChanged: { _ in
                                self.playEffect.changeSliderEffect()
                                
                            })
                            
                            .allowsHitTesting(false)
                            
                            
                            .accentColor(.white)
                            .onReceive(playEffect.timer) {_ in
                                switch enumCase {
                                case .open:
                                    sliderForOpenFile()
                                case .record:
                                    sliderForRecord()
                                case .none:
                                    print("No data input")
                                }
                            }
                            .animation(.linear(duration: 1), value: playEffect.sliderValue)
                            
                            .onChange(of: playEffect.sliderValue, perform: { newValue in
                                if newValue == 100{
                                    playEffect.timer.upstream.connect().cancel()
                                    playEffect.sliderValue = 0.0
                                }
                            })
                            //
                            //                                    }
                            //                                }
                            
                            //MARK: button Save
                            Button {
                                self.saveFile = true
                                switch enumCase {
                                case .open:
                                    playEffect.stopEffect()
                                case .record:
                                    recordAudio.stopEffect()
                                case .none:
                                    messageError = MessengerError(title: "No Data Input", message: "no data to use", button: "OK")
                                }
                            } label: {
                                Image("ic_download")
                                    .padding(.leading, 10)
                            }
                            .alert(title: { item in
                                Text(item.title)
                            }, unwrapping: $messageError) { item in
                                Button {
                                    withAnimation {
                                        if item.message == "Save File Success"{
                                            recording()
                                        }
                                    }
                                } label: {
                                    Text(item.button)
                                }
                            } message: { item in
                                Text(item.message)
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(width: UIScreen.width, height: UIScreen.height * 0.08)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    .background(Color("background"))
                    .onReceive(viewModel.$getData1 ) { output in
                        print(output)
                        switch enumCase {
                        case .open:
                            url = output.absoluteString
                            title = titleString
                        case .record:
                            return
                        case .none:
                            return
                        }
                    }
                    .onReceive(viewModel.$getData2) { output in
                        print(output)
                        switch enumCase {
                        case .open:
                            return
                        case .record:
                            url = output.absoluteString
                            title = titleString
                        case .none:
                            return
                        }
                    }
                }
                //Custom: TextBox - TextField
                ZStack{
                    Color.black.opacity(0.2)
                        .opacity(saveFile ? 1 : 0 )
                        .edgesIgnoringSafeArea(.all)
                    var string = ""
                    TextBoxName(title: "Do you want save this file?",textFiled: "New Voice Changer", isShow: $saveFile, text: $rename, oldname: Binding<String>(get: {string}, set: { string = $0}), onSave:  {
                        onSave = true
                    })
                }
            }
            
            .onAppear{
                voiceCurrent = EffectFactory.ChangeVoice.normal.rawValue
            }
            
            .onDisappear{
                switch enumCase {
                case .open:
                    playEffect.stopEffect()
                    playEffect.sliderValue = 0.0
                    recordAudio.samples = []
                case .record:
                    recordAudio.stopEffect()
                    playEffect.sliderValue = 0.0
                    recordAudio.samples = []
                    
                case .none:
                    messageError = MessengerError(title: "Error", message: "Can't data input for stop Effect", button: "OK")
                }
            }
            .navigationDestination(isPresented: $onSave) {
                ProgressView( selectEffect: selectEffect, typeVoiceChange: typeVoiceChange,  enumCase: enumCase, nameFile: rename)
            }
            .navigationBarBackButtonHidden(true)
        }
        
    }
    
    func sliderForOpenFile(){
        
        let sampleRate = (playEffect.audioProcessor?.currentTimes() ?? 0) / playEffect.getDurationFile(audioFile: viewModel.getData1)
        playEffect.sliderValue = sampleRate * 100
        
        if playEffect.sliderValue > 100 {
            playEffect.sliderValue = 0.0
            playEffect.isPlaying = false
        }
    }
    
    
    func sliderForRecord(){
        
        
        let sampleRate = ((recordAudio.audioProcessor?.currentTimes() ?? 0) / playEffect.getDurationFile(audioFile: viewModel.getData2))
        playEffect.sliderValue = sampleRate * 100
        
        if playEffect.sliderValue > 100 {
            playEffect.sliderValue = 0.0
            playEffect.isPlaying = false
        }
    }
    
    
    func setError(_ error: Error) async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}
struct ButtonChange: View{
    @Binding var valueVoice : EffectFactory.ChangeVoice
    @AppStorage("voicecurrent") var voiceCurrent : String = EffectFactory.ChangeVoice.normal.rawValue
    @ObservedObject var playSound = AudioPlayer.shared
    @State var resuiltCallBack: ((String)->())
    
    var body: some View{
        let isActive = EffectFactory.ChangeVoice(rawValue: voiceCurrent) == valueVoice
        Button {
            //action
            
            withAnimation(Animation.linear) {
                voiceCurrent = valueVoice.rawValue
                resuiltCallBack(voiceCurrent)
            }
        } label: {
            ZStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isActive ? Color("background") :  Color.white )
                        .frame(width: 90, height: 113, alignment: .center)
                    VStack{
                        Spacer()
                        Image(valueVoice.rawValue)
                            .resizable()
                            .frame(width: 40 , height: 40)
                        Spacer()
                        Text(valueVoice.rawValue)
                            .foregroundColor(isActive ? Color.white : Color.black.opacity(0.5))
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                    }
                }
            }
        }
    }
}

extension AudioChangeView{
    var urlString: String{
        switch enumCase{
        case .open:
            return viewModel.getData1.absoluteString
        case .record:
            return viewModel.getData2.absoluteString
        case .none:
            return ""
        }
    }
}

extension AudioChangeView{
    var titleString: String{
        switch enumCase {
        case .open:
            return viewModel.getData1.lastPathComponent
        case .record:
            return viewModel.getData2.lastPathComponent
        case .none:
            return ""
        }
    }
}

enum AudioChangeScreen{
    case open
    case record
    case none
}
