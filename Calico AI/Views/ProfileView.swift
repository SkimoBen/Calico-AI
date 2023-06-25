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
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        //topbar
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
                
                PillBarView(firstText: "Current Credits", secondText: "\(userViewModel.currentTokens)")
                
                PillBarView(firstText: "Next topup", secondText: "\(Date(timeIntervalSince1970: TimeInterval(userViewModel.refillDate)))")
            }
            .padding(.bottom, 40)
        //.formatted(.dateTime.day().month().year())
///------------------------------------------------------------------------------------
        
            //MARK: Buttons View
            HStack {
                Button(action: {
                    
                }, label: {
                    Text("Privacy Policy")
                        .frame(maxWidth: 110)
                        .padding(8)
                        .background(Material.bar)
                        .background(.purple.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1))
                })
                Spacer()
                Button(action: {
                    
                }, label: {
                    Text("Terms of Use")
                        .frame(maxWidth: 110)
                        .padding(8)
                        .background(Material.bar)
                        .background(.purple.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1))
                })
            }
            .frame(maxWidth: 300)
            .padding()
            
            HStack {
                Button(action: {
                    
                }, label: {
                    Text("FAQ")
                        .frame(maxWidth: 110)
                        .padding(8)
                        .background(Material.bar)
                        .background(.purple.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1))
                })
                Spacer()
                
                Button(action: {
                    
                }, label: {
                    Text("Change Plan")
                        .frame(maxWidth: 110)
                        .padding(8)
                        .background(Material.bar)
                        .background(.purple.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1))
                })
            }
            .frame(maxWidth: 300)
            .padding()
           
            Button(action: {
                Purchases.shared.restorePurchases { (customerInfo, error) in
                    //... check customerInfo to see if entitlement is now active
                    if customerInfo?.entitlements.all["Apprentice"]?.isActive == true {
                        userViewModel.currentUserEntitlements = UserEntitlements().Apprentice
                    } else if customerInfo?.entitlements.all["Sorcerer"]?.isActive == true  {
                        userViewModel.currentUserEntitlements = UserEntitlements().Sorcerer
                    } else if customerInfo?.entitlements.all["Illusionist"]?.isActive == true{
                        userViewModel.currentUserEntitlements = UserEntitlements().Illusionist
                    }
                }
            }, label: {
                Text("Restore Purchases")
                    .frame(maxWidth: 150)
                    .padding(8)
                    .background(Material.bar)
                    .background(.purple.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .overlay(RoundedRectangle(cornerRadius: 40).stroke(Color.blue, lineWidth: 1))
            })
            Spacer()
            
        } ///:- VStack Bottom
        
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
        ProfileView(showProfileView: .constant(true))
            .environmentObject(UserViewModel())
    }
}
