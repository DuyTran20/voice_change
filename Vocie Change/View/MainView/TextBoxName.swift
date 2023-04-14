import SwiftUI

struct TextBoxName: View {
    let screenSize = UIScreen.main.bounds
    @FocusState var isTextFieldFocused : Bool
    @State var showWarning : Bool = false
    @EnvironmentObject var playEffect: AudioPlayEffect
    var title: String = ""
    @State var textFiled : String 
    @FocusState var showKeyBoard: Bool
    @Binding var isShow: Bool
    @Binding var text: String
    @Binding var oldname : String
//    @State var onSave : Bool
//    @State var isSave: Bool
    
    var onSave: () -> Void = {}
    var onCancel: () -> Void = {}
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 10){
                Spacer()
                Text(title)
                    .font(.system(size: 17))
                    .fontWeight(.bold)
                Spacer()
                TextField("\(textFiled)", text: $text)
                    .onAppear{
                        text = oldname
                    }
                    .focused($showKeyBoard)
                    .focused($isTextFieldFocused)
                    .textFieldStyle(.roundedBorder)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(showWarning ? Color.red : Color(UIColor.systemGray4), lineWidth: 1)
                    }
                    
                let renameSpacesFile = text.trimmingCharacters(in: .whitespaces)
                
                if showWarning {
                    Text("File name is blank")
                        .foregroundColor(.red)
                        .transition(.identity)
                }
                Spacer()
                HStack(spacing: 100){
                    Button("Cancel", role:.cancel) {
                        self.isShow = false
                        self.onCancel()
                        showKeyBoard = false
                        text = ""
                        showWarning = false
                    }
                    Button("Save") {
                        if text.isEmpty || renameSpacesFile.isEmpty {
                            showWarning = true
                            self.isShow = true
                            text = ""
                            showKeyBoard = false
                        }else{
                            
//                            isSave.toggle()
                            showWarning = false
                            onSave()
                            self.isShow = false
                            showKeyBoard = false
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        .frame(width: screenSize.width * 0.7, height: screenSize.height * 0.25)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .offset(y: isShow ? 0 : screenSize.height)

        
    }
}

