//
//  ProfileView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-11.
//

import SwiftUI
import RevenueCat

struct ProfileView: View {
    //Allow the user to dismiss the view
    @Environment(\.dismiss) var dismiss
    @Binding var showProfileView:  Bool
    @Binding var showPaywallView: Bool
    @EnvironmentObject var userViewModel: UserViewModel
    @State var restorePurchasesError = false
    @State var restorePurchaseSuccess = false
    @State var showFAQ: Bool = false
    var body: some View {
        //topbar
        ZStack {
            VStack {
                //MARK: Top bar
                HStack {
                    Button(action: {
                        showProfileView = false
                        dismiss()
                    }, label: {
                        Image(systemName: "x.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 30)
                    })
                    .padding(.leading, 15)
                    
                    Spacer()
                }///:- HStack Bottom
                .background(Color.clear)
    ///------------------------------------------------------------------------------------
                //MARK: Title
                Text("Calico AI")
                    .frame(maxWidth: 190)
                    .font(
                        .system(
                            size: 40,
                            weight: .light,
                            design: .rounded
                        )
                        
                    )
                    .padding(10)
                    .background(Material.bar)
                    .background(
                        LinearGradient(colors: [.red, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 70))
                    .padding(.bottom, 30)
    ///------------------------------------------------------------------------------------
                //MARK: PillBarView
                VStack {
                    PillBarView(firstText: "Current Plan",
                                secondText: userViewModel.currentUserEntitlements.title)
                    
                    PillBarView(firstText: "Current Credits", secondText: "\(userViewModel.totalTokens)")
                    
                    PillBarView(firstText: "Next topup", secondText: "\(Date(timeIntervalSince1970: TimeInterval(userViewModel.refillDate)).formatted(.dateTime.day().month().year()))")
                }
                .padding(.bottom, 40)
            //
    ///------------------------------------------------------------------------------------
            
                //MARK: Buttons View
                HStack {

                    Link("Privacy Policy", destination: URL(string: "https://www.freeprivacypolicy.com/live/b60ca8c5-2d36-4b38-a65d-423eff3f4b07")!)
                        .frame(maxWidth: 110)
                        .padding(8)
                        .background(Material.bar)
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue.opacity(0.5), lineWidth: 1))
                    Spacer()
                    
                    Link("Terms of Use", destination: URL(string:"https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        .frame(maxWidth: 110)
                        .padding(8)
                        .background(Material.bar)
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue.opacity(0.5), lineWidth: 1))
                    

                }
                .frame(maxWidth: 300)
                .padding()
                
                HStack {
                    Button(action: {
                        withAnimation {
                            showFAQ.toggle()
                        }
                        
                    }, label: {
                        Text("FAQ")
                            .frame(maxWidth: 110)
                            .padding(8)
                            .background(Material.bar)
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                            .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue.opacity(0.5), lineWidth: 1))
                    })
                    Spacer()
                    
                    Button(action: {
                        showProfileView = false
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)  {
                            showPaywallView = true
                        }
                        
                    }, label: {
                        Text("Change Plan")
                            .frame(maxWidth: 110)
                            .padding(8)
                            .background(Material.bar)
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 40))
                            .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue.opacity(0.5), lineWidth: 1))
                    })
                }
                .frame(maxWidth: 300)
                .padding()
               
                //MARK: Restore Purchases
                Button(action: {
                    Purchases.shared.restorePurchases { (customerInfo, error) in
                        //... check customerInfo to see if entitlement is now active
                        if customerInfo?.entitlements.all["Apprentice"]?.isActive == true {
                            userViewModel.currentUserEntitlements = UserEntitlements().Apprentice
                            restorePurchaseSuccess = true
                        } else if customerInfo?.entitlements.all["Sorcerer"]?.isActive == true  {
                            userViewModel.currentUserEntitlements = UserEntitlements().Sorcerer
                            restorePurchaseSuccess = true
                            
                        } else if customerInfo?.entitlements.all["Illusionist"]?.isActive == true{
                            userViewModel.currentUserEntitlements = UserEntitlements().Illusionist
                            restorePurchaseSuccess = true
                        } else if (error != nil) {
                            restorePurchasesError = true
                        }
                    }
                }, label: {
                    Text("Restore Purchases")
                        .frame(maxWidth: 150)
                        .padding(8)
                        .background(Material.bar)
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue.opacity(0.5), lineWidth: 1))
                })
                //Error alert
                .alert(isPresented: $restorePurchasesError) {
                    Alert(title: Text("Error"), message: Text("Sorry, we encountered an error while fetching your purchases."), dismissButton: .default(Text("OK")))
                }
                //Success Alert
                .alert(isPresented: $restorePurchaseSuccess) {
                    Alert(title: Text("Success"), message: Text("Your plan has been restored."), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
            } ///:- VStack Bottom
          
            
            
            FAQView(showFAQ: $showFAQ)
                .background(Material.ultraThin)
                .cornerRadius(10)
                .offset(x: 0, y: showFAQ ? 0 : 2000)
                .animation(.easeInOut(duration: 0.7), value: showFAQ)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            // If the downward drag is more than 100 points, toggle showFAQ
                            if value.translation.height > 100 {
                                withAnimation {
                                    showFAQ = false
                                }
                            }
                        }
                )
            
        }///:- ZStack Bottom
        .gesture(
            DragGesture()
                .onEnded { value in
                    // If the downward drag is more than 100 points, toggle showFAQ
                    if value.translation.height > 100 {
                        withAnimation {
                            showProfileView = false
                            dismiss()
                        }
                    }
                }
        )
    }
}

//MARK: FAQView
struct FAQView: View {
    @Binding var showFAQ: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        showFAQ = false
                    }
                }, label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 30)
                        .foregroundColor(.gray)
                })
                Spacer()
            }
            .padding()
            HStack {
                Text("Frequently Asked Questions")
                    .font(
                        .system(
                            size: 26,
                            weight: .light,
                            design: .rounded
                        ))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            //.padding(.leading, 25)
             
            List(faqList, id: \.0) { question, answer in
                DisclosureGroup(
                    content: {
                        Text(answer)
                            .font(.body)
                    },
                    label: {
                        Text(question)
                            .font(.headline)
                    })
            }
            .listStyle(PlainListStyle())
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            .background(.clear)
            
            
            Spacer()
        }

    }
}

///------------------------------------------------------------------------------------
//MARK: Pillbar Struct
struct PillBarView: View {
    var firstText: String
    var secondText: String
    
    var body: some View {
        VStack{
            HStack{
                Text(firstText)
                Spacer()
                Text(secondText)
            }
            .frame(maxWidth: 300)
            .padding(10)
            .background(Material.bar)
            .background(
                LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 70))
        }
    }
}

///------------------------------------------------------------------------------------
//MARK: Previews
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        //FAQView()
        ProfileView(showProfileView: .constant(true), showPaywallView: .constant(false))
            .environmentObject(UserViewModel())
    }
}


//struct ClearBackground: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .background(Color.clear)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//// View extension to use the modifier easily
//extension View {
//    func clearBackground() -> some View {
//        self.modifier(ClearBackground())
//    }
//}




//MARK: FAQ List
let faqList = [
    ("Can I switch subscription plans?", "Yes, you can switch subscription plans anytime you like. If you’re moving to a higher tier (like upgrading from Apprentice to Sorcerer) your upgrade will happen immediately. Occasionally, you will have to restart the app to see the changes."),
    ("What happens if I downgrade my subscription?", "If you downgrade your subscription, you will be charged up front, however you will still have the capabilities of the previous tier until the next billing cycle. For example, if you downgrade from Illusionist to Sorcerer on June 15th, and your billing cycle ends on June 25th, you will be charged $9.99 on June 15th, but you will have Illusionist capabilities until June 25th when your subscription for Sorcerer begins. Your new credits will be issued on June 25th as well."),
    ("Do my credits expire?", "Paid credits do not expire, however free trials have a maximum of 100 credits per month. If you have a paid subscription and then cancel it, you will retain the credits you accumulated during the subscription period."),
    ("How do credits work?", "Generating beautiful images takes a lot of computational power. The credit system is a way to measure how much compute resources a particular image took to be created. Increasing the image dimensions, number of samples, and number of generations will also increase the number of credits a generation takes."),
    ("Do I lose credits if the image generation fails?", "No, credits will only be deducted if the image is generated successfully."),
    ("Why does the max image generations change?", "Large images take a significantly longer time to process than smaller images. That's why we've set limits on how many images you can generate per prompt for a given resolution. This only effects the Illusionist tier, where you can generate 4 images up to 1024 resolution, then 2 images up to 1600 resolution. Any resolution over 1600 has a max of 1 image per generation. We wish we could let you generate as many images as you want, but our GPU's would run out of memory and melt! 🔥")
]
