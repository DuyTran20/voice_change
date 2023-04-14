import SwiftUI

struct SubScriptionView: View {
    @Environment(\.presentationMode) var dismiss
    
    @State private var imageFonts = "ic_sub1"
    @State private var imageShapes = "ic_sub2"
    @State private var imageSickers = "ic_sub3"
    @State private var imageTemplates = "ic_sub4"
    
    @State private var priceCurrent : Price = .year
    @State private var priceWeek = "3.99$"
    @State private var priceMonth = "7.99$"
    @State private var priceYear = "29.99$"
    
    @State private var saveWeek = ""
    @State private var saveMonth = "Save 20%"
    @State private var saveYear = "Save 80%"
    
    @State private var dateWeek = "/ Week"
    @State private var dateMonth = "/ Month"
    @State private var dateYear = "/ Year"
    var body: some View {
        NavigationStack{
            ZStack{
                Image("ic_bgr")
                    .resizable()
                    .frame(width: UIScreen.width, height: UIScreen.height)
                ZStack{
                    ScrollView(showsIndicators: false){
                        VStack{
                            Text("Voice Change")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold))
                                .padding(4)
                            
                            Text("Unlock All Access")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                            
                            ZStack{
                                
                                Image("ic_rec")
                                
                                VStack{
                                    
                                    Image("iconlag")
                                        .padding(.bottom, -45)
                                    
                                    Text("Remove Ads. Scan unlimited.")
                                        .foregroundColor(.black)
                                        .fontWeight(.bold)
                                    
                                    Text("Unlock all fonts, shapes, stickers and templates.")
                                        .font(.system(size: 14,weight: .medium))
                                        .foregroundColor(.black)
                                    
                                }
                                    .padding(.bottom, 50)
                                
                            }
                            Text("Start your 3-day free trial")
                                .padding(30)
                                .font(.system(size: 16,weight: .medium))
                                .frame(width: UIScreen.width-38, height: 21, alignment: .center)
                                .foregroundColor(.black)
                            VStack{
                                ButtonPrice(priceString: $priceWeek, price: .week, currentPrice: $priceCurrent, savePrice: $saveWeek, datePrice: $dateWeek)
                                
                                ButtonPrice(priceString: $priceMonth, price: .month, currentPrice: $priceCurrent, savePrice: $saveMonth, datePrice: $dateMonth)
                                
                                ButtonPrice(priceString: $priceYear, price: .year, currentPrice: $priceCurrent, savePrice: $saveYear, datePrice: $dateYear)
                            }
                            
                            
                            Button {
                                //todo
                            } label: {
                                VStack{
                                    Text("Continue")
                                        .font(.system(size: 16,weight: .medium))
                                    
                                    Text("Auto-renew at the end of the trial")
                                        .font(.system(size: 12,weight: .medium))
                                    
                                }
                                .padding()
                                .frame(width: UIScreen.width-60, height: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(Color("pay"))
                                .cornerRadius(10)
                            }
                            VStack{
                                
                                Text("Subscription is auto-renewable. Cancel anytime")
                                    .font(.system(size: 14,weight: .regular))
                                    .frame(width: UIScreen.width-66, height: 26, alignment: .center)
                                    .foregroundColor(.gray)
                                
                                Text("After the subscription, you can get unlimited access to TextArt pro. According to the policy of the Apple Store, your subscription will be automatically renewed within 24 hours before the free trial expires. If you need to cancel, please manually turn off automatic renewal in the iTunes/ Apple ID settings at least 24 hours before the end of the currently subscription. Users who have already tried VIP and subscribe again will be charged directly.")
                                    .frame(width: UIScreen.width-40, height: 86)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 11,weight: .medium))
                                    .foregroundColor(.gray)
                                    .padding()
                                
                                HStack{
                                    
//                                    Button {
//                                        //action
//                                    } label: {
//
//                                        Text("Terms of Use ")
//                                            .font(.system(size: 15,weight: .medium))
//                                            .foregroundColor(.gray)
//
//                                    }
                                    Link("Terms of Use", destination: URL(string: "https://vi.wikipedia.org/wiki/Apple_Inc.")!)
                                        .font(.system(size: 15,weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                    
                                    Divider()
                                        .background(Color.white)
                                        .frame(width: 12, height: 17)
                                    
//                                    Button {
//
//                                       //todo
//
//                                    } label: {
//
//                                        Text("Privacy Policy")
//                                            .font(.system(size: 15,weight: .medium))
//                                            .foregroundColor(.gray)
//
//                                    }
                                    
                                    Link("Privacy Policy", destination: URL(string: "https://www.apple.com/")!)
                                        .font(.system(size: 15,weight: .medium))
                                        .foregroundColor(.gray)
                                    
                                }.font(.system(size: 16,weight: .medium))
                                    .frame(width: UIScreen.width-21, height: 18)
                            }
                            .foregroundColor(.black)

                        }
                        .frame(width: UIScreen.width, height:UIScreen.height - 20)
                    }
                    VStack{
                        HStack{
                            Button {
                                dismiss.wrappedValue.dismiss()
                                //todo
                            } label: {
                                Text("Close")
                                    .font(.system(size: 16, weight:.bold))
                                    .opacity(0.8)
                                    .foregroundColor(Color(.white))
                                    
                            }
                            Spacer()
                            Button {
                                
                                //todo
                            } label: {
                                Text("Restore")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(.black))
                            }
                        }.padding(.top, 50)
                            .frame( width: UIScreen.width - 80, height: 50, alignment: .center)
                            
                        
                        Spacer()
                    }
                }
            }
            .background {
                Color("background")
                    .ignoresSafeArea()
            }
            
            .frame(width: UIScreen.width, height: UIScreen.height, alignment: .center)
            
        }
    }
}
enum Price{
    case week
    case month
    case year
}
struct ButtonPrice: View{
    @Binding var priceString: String
    
    @State var price: Price
    
    @Binding var currentPrice: Price
    
    @Binding var savePrice: String
    
    @Binding var datePrice: String
    
    var body: some View{
        let isActive = currentPrice == price
        Button {
            currentPrice = price
        } label: {
            HStack{
                Image(isActive ? "ic_sub5" : "ic_sub6" )
                HStack{
                    Text(priceString)
                        .font(.headline)
                        .foregroundColor(.black)
                    Group{
                        Text(datePrice)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Spacer()
                        Text(savePrice)
                            .font(.system(size: 12,weight: .regular))
                            .foregroundColor(Color(.black).opacity(0.8))
                    }
                }
            }
        }.frame(width: UIScreen.width - 85, height: 44).padding([.leading,.trailing],12)
            .background{
                RoundedRectangle(cornerRadius: 10).stroke(.black,lineWidth: isActive ? 1 : 0)
            }

    }
}





struct SubScriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubScriptionView()
    }
}
