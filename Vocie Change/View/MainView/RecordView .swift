import SwiftUI
import RealmSwift
import AVFoundation
import DSWaveformImageViews
import DSWaveformImage

struct RecordView: View {
    @EnvironmentObject var audioRecord : AudioRecording
    
    @ObservedObject var data = Data()
    
    @EnvironmentObject var audioEffect : AudioPlayEffect
    
    
    
//    @ObservedObject var audioProcess: AudioFXProcessor
    
    @ObservedResults(AudioChange.self) var audioRecording
    
    @State var animation1:Bool = false
    
    @State var animation2:Bool = false
    
    @State var animation3:Bool = false
    
    @State var changeText: Bool = false
    
    @State var importFile : Bool = false
    
    @State var changeImport: Bool = false
    
    @State var audioFile : Recording?
    
    @State var changeView: Bool = false
//    @State var model : Recording
    
    @State var permissionCheck: Bool = false
    
    
    @Environment(\.presentationMode) var dismiss
    
    var recording : () -> ()
    
    private func normalizeSound(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 40) / 2
        return CGFloat(level * (250 / 20))
    }
    
    @State var liveConfiguration: Waveform.Configuration = Waveform.Configuration(style: .striped(.init(color: .blue,width: 3, spacing: 5,lineCap: .round)), verticalScalingFactor: 0.7)
    var body: some View {
        NavigationStack{
            VStack{
                Text(changeText ? "Recording": "Record")
                    .font(.system(size: 19,weight: .bold))
                    .padding(.top, 50)
                
                Spacer()
                if audioRecord.isRecording == false{
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: UIScreen.width - 20, height: 250)
                }
                else{
                    if audioRecord.isRecording == true{
                        WaveformLiveCanvas(samples: audioRecord.samples, configuration: liveConfiguration)
                            .frame(width: UIScreen.width - 100, height: 350)
                    }
                }
                
                Spacer()
                
                ZStack{
                    Image("ic_button_record")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.width)
                        .edgesIgnoringSafeArea(.bottom)
                    
                    VStack{
                        
                        HStack{
                            
                            if audioRecord.minutes < 10{
                                Text("0" + "\(audioRecord.minutes )" + " :")
                            }else{
                                Text("\(audioRecord.minutes )" + " :" )
                            }
                            if audioRecord.seconds < 10{
                                Text("0" + "\(audioRecord.seconds )")

                            }else{

                                Text("\(audioRecord.seconds )")


                            }
//                            Text(audioRecord.timeText)
                            
                        }.font(.system(size: 50, weight: .heavy))
                            .foregroundColor(.white)
                            .opacity(audioRecord.isRecording ? 1 : 0.6 )
                            .frame(width: UIScreen.width, alignment: .center)
                        
                        
                        HStack(){
                            if audioRecord.isRecording == false{
                                Button {
                                    //todo
                                    withAnimation {
                                        self.importFile = true
                                    }
                                } label: {
                                    VStack{
                                        Image("ic_record1")
                                        Text("Open File")
                                            .foregroundColor(.white)
                                    }
                                }
                                .fileImporter(isPresented: $importFile, allowedContentTypes: [.audio], allowsMultipleSelection: false) { result in
                                    if  case.success(let value) = result {
                                        changeImport = true
                                        do{
                                            guard let selectFile: URL = try result.get().first else { return }
                                            if selectFile.startAccessingSecurityScopedResource(){
                                                let model = Recording(fileURL: selectFile, createdAT: selectFile.lastPathComponent)
                                                print(value)
                                                audioEffect.audioFile = model
                                                let file: Double = audioEffect.getDurationFile(audioFile: selectFile)
                                                print("Time file: \(file)")
                                                data.getData1 = selectFile
                                                print("get Data1 : \(data.getData1)")
                                                data.fileName = selectFile.lastPathComponent
                                                print(data.getData1)
//                                                selectFile.stopAccessingSecurityScopedResource()
                                            }
                                        }catch{
                                            print("Failed Open File")
                                        }
                                    }
                                }
                                
                            }
                            
                            Spacer()
                            
                            Button {
                                changeText.toggle()
                                switch AVAudioSession.sharedInstance().recordPermission{
                                case.denied:
                                    permissionCheck = true
                                case.granted:
                                   
                                    startRecording()
                                    
                                case .undetermined:
                                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                                        if granted {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1/4 ){
                                                startRecording()
                                            }
                                        }else{
                                            //todo
                                            permissionCheck = true
                                        }
                                    }
                                default:
                                    break
                                }
                            } label: {
                                ZStack{
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .frame(width: 114, height: 114)
                                        .foregroundColor(.white)
                                        .opacity(0.1)
                                        .scaleEffect(animation1 ? 1 : 1.15)
                                        .onAppear {
                                            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                                self.animation1.toggle()
                                            }
                                        }
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .frame(width: 102, height: 102)
                                        .foregroundColor(.white)
                                        .opacity(0.2)
                                        .scaleEffect(animation2 ? 1 : 1.1)
                                        .onAppear {
                                            withAnimation (Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)){
                                                self.animation2.toggle()
                                            }
                                        }
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .frame(width: 92, height: 92)
                                        .foregroundColor(.white)
                                        .opacity(0.3)
                                        .scaleEffect(animation3 ? 1 : 1.05)
                                        .onAppear {
                                            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                                self.animation3.toggle()
                                            }
                                        }
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 82, height: 82)
                                    Image( audioRecord.isRecording ? "bt_recording" : "bt_record")
                                }
                            }
                            .alert(isPresented: $permissionCheck) {
                                 Alert (title: Text("Microphone access required to take record"),
                                        message: Text("Go to Settings?"),
                                        primaryButton: .default(Text("Settings"), action: {
                                     
                                     DispatchQueue.main.async {
                                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                     }
                                        }),
                                        secondaryButton: .default(Text("Cancel")))
                                    }
                            
                            Spacer()
                            if audioRecord.isRecording == false{
                                Button {
                                    dismiss.wrappedValue.dismiss()
                                } label: {
                                    VStack{
                                        Image("ic_record2")
                                        
                                        Text("Close")
                                            .foregroundColor(.white)
                                    }.padding()
                                }
                            }
                        }
                        .frame(width: UIScreen.width - 40 ,alignment: .center)
                    }
                    
                }
            }
            .frame(width: UIScreen.width, height: UIScreen.height)
            .navigationDestination(isPresented: $changeImport){
                AudioChangeView(recording: recording,  viewModel: data , voiceChange: EffectFactory.ChangeVoice.allCases, enumCase: .open)
            }
            .navigationDestination(isPresented: $changeView){
                AudioChangeView(recording: recording,   audioRcording: AudioChange(), viewModel: data, voiceChange: EffectFactory.ChangeVoice.allCases, enumCase: .record)
            }
            .navigationBarBackButtonHidden(true)
            
            
//            .navigate(to: AudioChangeView(recording: recording,  viewModel: data , voiceChange: EffectFactory.ChangeVoice.allCases, enumCase: .open), when: $changeImport,isHidenNavigationBar: true, navigationBarTitle: "Audio Change")
            
            
//            .navigate(to: AudioChangeView(recording: recording,   audioRcording: AudioChange(), viewModel: data, voiceChange: EffectFactory.ChangeVoice.allCases, enumCase: .record), when: $changeView, isHidenNavigationBar: true,navigationBarTitle: "Audio Change")
        }
        //MARK: navigationLink
        
    }
    func startRecording() {
       
        if audioRecord.isRecording {
            audioRecord.stopRecording()
            changeView = true
        }else {
            audioRecord.startRecording()
            let fileRecording = audioRecord.audioFile
            data.getData2 = fileRecording!.fileURL
            data.fileName = fileRecording!.fileURL.lastPathComponent
        }
    }
}

struct BarView:View{
    var value: CGFloat
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 10, height: value)
                .foregroundColor(Color.blue)
        }
    }
}
