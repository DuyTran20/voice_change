

import SwiftUI
import RealmSwift

struct SuccessSaveFile: View {
    @ObservedObject var play = AudioPlayer.shared
    @ObservedObject var funcShared  = FunctionAction()
    @EnvironmentObject var playEffect : AudioPlayEffect
    @EnvironmentObject var recordingAudio: AudioRecording
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var back
    @Environment(\.scenePhase) var scenePhase
    @ObservedResults(AudioChange.self,  sortDescriptor: SortDescriptor(keyPath: "id", ascending: false) )var items
    @State var newAudio: Bool = false
    @State var nameText: String
    @State var isPlaying : Bool = false
    @State var speed = 1.0
    @State var url : String
    @State var enumCase : AudioChangeScreen
    
       
    var body: some View {
        NavigationStack{
            VStack{
                Text("\(nameText).m4a")
                    .font(.title2)
                    .fontWeight(.bold)
                if isPlaying == false {
                    Text("Locked")
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }else{
                    Text(" ")
                        .padding(.bottom, 10)
                }
                HStack{
                    
                    Button {
                        isPlaying.toggle()
                        let time = getDurationFile(audioFile: URL(string: url)!)
                        print(time)
                        self.play.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                        if isPlaying {
                            play.audioPlayer(url: URL(string: url)!)
                            
                            print(" ----\(URL(string: url)!)")
                        }else{
                            play.audioStop()
                        }
                    } label: {
                        Image(isPlaying ? "ic_pauseSave" : "ic_playSave")
                    }
                    .onChange(of: scenePhase) { newValue in
                        switch newValue {
                        case .inactive, .background:
                            play.audioStop()
                            isPlaying = false
                        default:
                            break
                        }
                    }
                    
                    //Slider
                    Slider(value: $play.playValue,in: TimeInterval(0.0)...getDurationFile(audioFile: URL(string: url)!)) { _ in
                        play.changeSliderValue()
                        print(play.playValue)
                    }
                    
                    
//                    Slider(value: $play.playValue, in: TimeInterval(0.0)...getDurationFile(audioFile: URL(string: url)!) , onEditingChanged: { _ in
//                        self.play.changeSliderValue()
//                        print(play.playValue)
//                    })
                    .onReceive(play.timer, perform: { _ in
                        withAnimation(.linear(duration: 0.1)) {
                            if self.play.isPlaying{
                                if let currentTime = self.play.audioPlayer?.currentTime{
                                    self.play.playValue = currentTime
                                    if currentTime == TimeInterval(0.0){
                                        self.play.isPlaying = false
                                    }
                                }
                            }else{
                                self.play.isPlaying = false
                                self.play.timer.upstream.connect().cancel()
                            }
                        }
                    })
                        .accentColor(Color("background"))
                        .padding(.all)
                    
                    
                    let second = getDurationFile(audioFile: URL(string: url)!)
                    let timeToSecond = secondsToHoursMinutesSeconds(seconds: second)
                    switch enumCase {
                    case .open:
                        Text("\(timeToSecond)")
                            .padding(.leading, 5)
                    case .record:
                        Text("\(timeToSecond)")
                            .padding(.leading, 5)
                    case .none:
                        Text("nodata")
                    }
                }
                .frame(width: UIScreen.width - 32)
                
                
                Button {
                    
                    funcShared.shared(url: URL(string: url)! )
                } label: {
                    Text("Share")
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: UIScreen.width - 60, height: 60, alignment: .center)
                        }
                }
                .padding(.top, 60)
                .padding(.bottom,43)
                Button {
                    back.wrappedValue.dismiss()
                } label: {
                    Text("New Audio Changer")
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: UIScreen.width - 60, height: 60, alignment: .center)
                        }
                }
                Spacer()
            }
            
            .onDisappear{
                play.audioStop()
                play.timer.upstream.connect().cancel()
            }
        
            .navigationTitle("Save File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        back.wrappedValue.dismiss()
                    } label: {
                        Image("Back")
                    }

                }
            }
            .navigationBarBackButtonHidden(true)
        }
        
        
    }
    func getFileRealm(appenConponent: String) throws -> URL{
        let fm = FileManager.default
        let documentDirectory = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
        let url = documentDirectory.appendingPathComponent(appenConponent)
        return url
    }
    func getDurationFile(audioFile: URL) -> Double {
        let audioAsset = AVURLAsset.init(url: audioFile)
        let duration = audioAsset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        return durationInSeconds
    }
    
    func secondsToHoursMinutesSeconds(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [ .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let formattedString = formatter.string(from: TimeInterval(seconds))!
        return formattedString
    }

}


