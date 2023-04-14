//
//  MainView 2.swift
//  Vocie Change
//
//  Created by Tran Duc Duy on 28/11/2022.
//

import SwiftUI
import RealmSwift
import AVFoundation

struct MainView: View {
    @State private var animation1 = false
    
    @State private var animation2 = false
    
    @State private var animation3 = false
    
    @State var menu = false
    
    @State var rename : String = ""
    
    @State var renameFile : Bool = false
    
    @State private var recording = false
    
    @State private var open = false
    
    @State var permissionCheck: Bool = false
    
    @State private var hiddenAction = false
    
    @State var isPlaying :Bool = false
    
    @State var isPlay: Bool = false
    
    @State var selected = AudioChange()
    
    @ObservedObject var play = AudioPlayer.shared
    
    @State var messageErro: MessengerError?
        
    @ObservedResults(AudioChange.self,  sortDescriptor: SortDescriptor(keyPath: "id", ascending: false) )var items
    var body: some View {
        NavigationStack{
            ZStack{
                VStack{
                    HStack(spacing: 20){
                        Button {
                            withAnimation {
                                menu.toggle()
                                play.audioStop()
                            }
                                
                        } label: {
                            Image("ic_main")
                        }
                        Spacer()
                        Text("Voice Change")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                        Button {
                            withAnimation {
                                open.toggle()
                                play.audioStop()
                                if open == true {
                                    menu = false
                                }
                                
                                
                            }
                                
                        } label: {
                            Image("ic_king")
                        }
                        .fullScreenCover(isPresented: $open) {
                            SubScriptionView()
                        }
                    }
                    .frame(width: UIScreen.width - 40, alignment: .center)
                    
                    Spacer()
                    
                    if items.isEmpty{
                        VStack {
                            Image("ic_nofile")
                            Text("Click the button below to start a new Record")
                                .font(.system(size: 15))
                                .frame(width: UIScreen.width - 127)
                                .multilineTextAlignment(.center)
                        }
                    }else {
                        
                        //MARK: List View Change Voice Save
                        RecordingListView(success: { }, play: play, isAction: $isPlaying, renameFile: $renameFile, selectItem: selected)
                            .padding(.bottom, -120)
                    }
                    Spacer()
                    
                    ZStack{
                        Image("ic_button_main ")
                            .resizable()
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.bottom)
                            .shadow(color: Color(#colorLiteral(red: 0.8596749902, green: 0.854565084, blue: 0.8636032343, alpha: 1)), radius: 10)
                        Button {
                            //todo
                            play.isPlaying = false
                            switch AVAudioSession.sharedInstance().recordPermission{
                            case .denied:
                                permissionCheck = true
                            case.granted:
                                recording.toggle()
                            case.undetermined:
                                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                                    if granted{
                                        recording.toggle()
                                    }else{
                                        permissionCheck = true
                                    }
                                }
                            @unknown default:
                                print("Error: No access in microphone")
                            }
                            
                        } label: {
                            VStack{
                                ZStack{
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .frame(width: 114, height: 114)
                                        .foregroundColor(.white)
                                        .opacity(0.1)
                                        .scaleEffect(animation1 ? 1 : 1.15)
//                                    
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .frame(width: 102, height: 102)
                                        .foregroundColor(.white)
                                        .opacity(0.2)
                                        .scaleEffect(animation2 ? 1 : 1.1)
//
                                    
                                    Circle()
                                        .stroke(lineWidth: 2)
                                        .frame(width: 92, height: 92)
                                        .foregroundColor(.white)
                                        .opacity(0.3)
                                        .scaleEffect(animation3 ? 1 : 1.05)
//
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 82, height: 82)
                                    
                                    Image( "bt_record")
                                    
                                }
                                .shadow(color: Color(#colorLiteral(red: 0.8596749902, green: 0.854565084, blue: 0.8636032343, alpha: 1)), radius: 10)
                                
                                Text("Tap to record")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                
                            }
                        }
                        
                        //MARK: NavigationLink
                        .padding(.bottom, 120)
                        
                    }.padding(.bottom, -95)
                }
                ShowMenuView(width: UIScreen.width - 130, isOpen: menu) {
                    menu.toggle()
                }
                
                
//                ZStack{
//                    Color.black.opacity(0.2)
//                        .opacity(renameFile ? 1 : 0 )
//                        .edgesIgnoringSafeArea(.all)
//
//                    TextBoxName(title: "Do you want rename this file?",textFiled: "\(selected.nameFile)"  ,isShow: $renameFile, text: $rename, oldname: $selected.nameFile, onSave:  {
//                        updateRealm()
//                        print(self.items)
//                        print(rename)
//                    })
//                }
            }
            .onDisappear{
                play.audioStop()
            }
            .navigationDestination(isPresented: $recording) {
                RecordView( recording: {self.recording = false})
            }
        }
    }
    
    func updateRealm(){
        let realm = try! Realm()
        let items = realm.objects(AudioChange.self).where {
            $0.id == selected.id
        }
        print(selected.id)
        print(realm.objects(AudioChange.self).map({$0.id}))
        
        
        do{
            try realm.write({
                for item in items{
                    item.nameFile = rename
                }
            })
        }catch {
           
            print("Error")
        }
    }
    
    
    func hidenBar() -> Bool{
        if menu == true {
            //hiddenAction = true
            return true
        }else {
            //hiddenAction = false
            return false
        }
    }
        
}
    struct ShowMenuView: View{
        let width:CGFloat
        let isOpen: Bool
        let menuClose: () -> Void
        
        @State var showMenu = false
        
        var body: some View{
            ZStack{
                GeometryReader{ _ in
                    EmptyView()
                }
                .background(.gray.opacity(0.7))
                .opacity(self.isOpen ? 1 : 0 )
                .onTapGesture {
                    withAnimation {
                        self.menuClose()
                    }
                }
                HStack{
                    NavigationTestView()
                        .frame(width: self.width)
                        .background(.white)
                        .offset(x: self.isOpen ? 0 : -self.width)
                    Spacer()
                }
            }
        }
    }

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
