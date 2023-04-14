

import SwiftUI

struct SplashView: View {
    @AppStorage("mainview") var mainview = true
    
    var body: some View {
        VStack(){
            Image("ic_splash")
                .resizable()
                .ignoresSafeArea()
                
            Text("Voice Change")
                .font(.system(size: 40,weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom,120)
            
            Spacer()
            
            Button {
                mainview.toggle()
            } label: {
                Text("Get Started")
                    .foregroundColor(.black)
                    .frame(width: UIScreen.width - 60, height: 50, alignment: .center)
                    .font(.system(size: 16,weight: .heavy))
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.bottom,44)
            }

        }
        .frame(width: UIScreen.width, height: UIScreen.height)
        .background{
            Color("background")
        }
        .ignoresSafeArea()
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
