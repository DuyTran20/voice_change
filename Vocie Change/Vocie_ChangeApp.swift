import SwiftUI
import AVFoundation


class AppDelegate: NSObject, UIApplicationDelegate{
    let audioSession = AVAudioSession.sharedInstance()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        try? AVAudioSession.sharedInstance().setActive(true)
    }
}
@main
struct Vocie_ChangeApp: App {
    @StateObject var playEffect = AudioPlayEffect()
    @StateObject var recordingEffect = AudioRecording()
    @StateObject var playAudio = AudioPlayer()
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
//        let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
//        let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
        WindowGroup {
            ContentView()
                .onAppear{
                    let audioSession = AVAudioSession.sharedInstance()
                    
                    do{
                        try audioSession.setCategory(.playback,mode: .default,  options: [.defaultToSpeaker,.allowAirPlay,.allowBluetooth,.allowBluetoothA2DP])
                        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                    }catch{
                        print("Error setting up audio session")
                    }
                }
                .onDisappear{
                    try? AVAudioSession.sharedInstance().setActive(false)
                    
                }
               
                .environmentObject(playEffect)
                .environmentObject(recordingEffect)
                
        }
    }
}
