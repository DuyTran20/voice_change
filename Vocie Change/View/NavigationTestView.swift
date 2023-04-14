import MessageUI
import SwiftUI
import PopupView

struct NavigationTestView: View {
    
    let sendMail = SendMail()
    @State var item: [MenuItemTest] = MenuItemTest.allCases
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    @State private var premium: Bool  = false
    @State private var info: Bool = false
    var body: some View {
        VStack(alignment: .leading){
            
            HStack{
                Image("ic_voicechange")
                
                Text("VOICE CHANGE")
                    .foregroundColor(Color("background"))
            }
            .padding(.leading, 20)
            VStack(alignment: .leading){
                Button {
                    premium.toggle()
                } label: {
                    HStack( spacing: 10){
                        Image("Get Premium")
                            .frame(width: 44 ,height: 44)
                        Text("Get Premium")
                            .font(.system(size: 16,weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
                .fullScreenCover(isPresented: $premium) {
                    SubScriptionView()
                }
                
                Link(destination: URL(string: "https://www.apple.com/app-store/")!) {
                    HStack( spacing: 10){
                        Image("Privacy Policy")
                            .frame(width: 44 ,height: 44)
                        Text("Privacy Policy")
                            .font(.system(size: 16,weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button {
                    onItemShareDidClick()
                } label: {
                    HStack( spacing: 10){
                        Image("Share Qr Code")
                            .frame(width: 44 ,height: 44)
                        Text("Share Qr Code")
                            .font(.system(size: 16,weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button {
                    sendMail.sendMail()
                } label: {
                    HStack( spacing: 10){
                        Image("Feedback")
                            .frame(width: 44 ,height: 44)
                        Text("Feedback")
                            .font(.system(size: 16,weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }

                
                Link(destination: URL(string: "https://apps.apple.com/vn/app/apple-store/id375380948?l=vi")!) {
                    HStack( spacing: 10){
                        Image("Other App")
                            .frame(width: 44 ,height: 44)
                        Text("Other App")
                            .font(.system(size: 16,weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
                
                Button {
                    info.toggle()
                } label: {
                    HStack( spacing: 10){
                        Image("App Version")
                            .frame(width: 44 ,height: 44)
                        Text("App Version" + " \(appVersion)")
                            .font(.system(size: 16,weight: .medium))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
                .popup(isPresented: $info) {
                    PopupVersion()
                } customize: {
                    $0
                        .closeOnTap(true)
                        .closeOnTapOutside(true)
                        .backgroundColor(.black.opacity(0.5))
                }
            }
            .padding(.trailing, 100)
            Spacer()
        }
        
        .frame(width: UIScreen.width - 30, alignment: .center)
        .padding()
        
        
    }
    func actionSheet(){
        let urlShared = URL(string: "https://www.youtube.com/")
        let av =  UIActivityViewController(activityItems: [urlShared as Any], applicationActivities: nil)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        
        windowScene?.keyWindow?.rootViewController?.present(av, animated: true, completion: nil)
    }
    
    func onItemShareDidClick() {
            let title = "#1 Voice Changer app. Try now! "
            let text = "https://itunes.apple.com/app/id" + "123456789"
            let textShare = [title, text]
            let activityViewController = UIActivityViewController(activityItems: textShare, applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true)
        }
}

struct NavigationTestView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationTestView()
    }
}

enum MenuItemTest: String, CaseIterable{
    case premium = "Get Premium"
    case policy = "Privacy Policy"
    case share  = "Share Qr Code"
    case feedback = "Feedback"
    case other = "Other App"
    case version = "App Version "
}

extension MenuItemTest{
    
    var title : String {
        switch self {
        case .premium:
             return "Get Premium"
        case .policy:
            return "Privacy Policy"
        case .share:
            return "Share Qr Code"
        case .feedback:
            return "Feedback"
        case .other:
            return "Other App"
        case .version:
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            return "App Version" + " \(appVersion)"
        }
    }
    var imageName : String {
        switch self {
        case .premium:
             return "Get Premium"
        case .policy:
            return "Privacy Policy"
        case .share:
            return "Share Qr Code"
        case .feedback:
            return "Feedback"
        case .other:
            return "Other App"
        case .version:
            return "App Version"
        }
    }
}


struct PopupVersion: View{
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
   
    var body: some View{
        VStack(spacing: 10){
           Text("Voice Change")
                .foregroundColor(Color("background"))
                .font(.largeTitle)
                .fontWeight(.medium)
                
                
            Image("ic_voicechange")
                .resizable()
                .cornerRadius(20)
                .frame(width: 100, height: 100)
                .scaledToFit()
                
                
            Text("Version \(appVersion)")
                .fontWeight(.medium)
                .font(.headline)
                .foregroundColor(.black)
            Divider()
            HStack(alignment: .center, spacing:20) {
                Spacer(minLength: 55)
                Text("Close")
                Spacer()
                Divider()
                    .background(Color.white)
                Spacer(minLength: 1)
                Link(destination: URL(string: "https://apps.apple.com/vn/app/any-do-to-do-list-planner/id944960179?mt=12")!) {
                    Text("Check Update")
                        .foregroundColor(.red)
                        .lineLimit(1)
                }
                .foregroundColor(.black)
                Spacer(minLength: 10)

            }
                
        }
        .frame(width: 350, height: 260)
        .background {
            Color.white
        }
        .cornerRadius(20)
        
    }
}




struct PopupVersio_Previews: PreviewProvider{
    static var  previews: some View{
        PopupVersion()
    }
}
