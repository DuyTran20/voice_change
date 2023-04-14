import SwiftUI

struct MainViewController: View {
    @AppStorage("mainview") var mainview = true
    var body: some View {
        
        if mainview{
            SplashView()
        } else {
            MainView()
        }
    }
}

struct MainViewController_Previews: PreviewProvider {
    static var previews: some View {
        MainViewController()
    }
}
