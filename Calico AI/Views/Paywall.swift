//
//  Paywall.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-11.
//

import SwiftUI
import RevenueCat

//MARK: Paywall View
struct Paywall: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isPurchasing = false
    @State var currentOffering: Offering?
    @State var showErrorAlert: Bool = false
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    
                    VStack {
                        Spacer()
                        
                        Package(
                            Tier: "Calico Apprentice",
                            price: "$1.99 per month",
                            Point1: "• 1000 credits per month (~350 images)",
                            Point2: "• 720 X 720 Max resolution",
                            Point3: "• Generate 1 image at a time",
                            Point4: "• 50 samples / image",
                            frameSize: (geometry.size.width * 0.85),
                            buttonColor: colorScheme == .dark ? [.white] : [.black],
                            accentColor: colorScheme == .dark ? [.white] : [.black],
                            packageID: "Apprentice_Monthly",
                            entitlementID: "Apprentice",
                            PermissionsLevel: UserEntitlements().Apprentice,
                            isPurchasing: $isPurchasing,
                            currentOffering: $currentOffering,
                            showErrorAlert: $showErrorAlert
                        )
                        .shadow(radius: 10)
                        Spacer()
                        Package(
                            Tier: "Calico Sorcerer",
                            price: "$9.99 per month",
                            Point1: "• 6500 credits per month (~2200 images)",
                            Point2: "• 1024 X 1024 Max resolution",
                            Point3: "• Generate 2 images at a time",
                            Point4: "• 75 samples / image",
                            frameSize: (geometry.size.width * 0.9),
                            buttonColor: [.mint],
                            accentColor: [.mint],
                            packageID: "Sorcerer_Monthly",
                            entitlementID: "Sorcerer",
                            PermissionsLevel: UserEntitlements().Sorcerer,
                            isPurchasing: $isPurchasing,
                            currentOffering: $currentOffering,
                            showErrorAlert: $showErrorAlert
                        )
                        
                        .shadow(radius: 10)
                        Spacer()
                        Package(
                            Tier: "Calico Illusionist",
                            price: "$24.99 per month",
                            Point1: "• 20,000 credits per month",
                            Point2: "• 2048 X 2048 Max resolution",
                            Point3: "• Generate 4 images at a time",
                            Point4: "• 100 samples / image",
                            frameSize: (geometry.size.width * 0.85),
                            buttonColor: colorScheme == .dark ? [.cyan, .blue] : [.cyan, .blue, .blue],
                            accentColor: colorScheme == .dark ? [.cyan, .blue] : [.cyan, .blue, .blue],
                            packageID: "Illusionist_Monthly",
                            entitlementID: "Illusionist",
                            PermissionsLevel: UserEntitlements().Illusionist,
                            isPurchasing: $isPurchasing,
                            currentOffering: $currentOffering,
                            showErrorAlert: $showErrorAlert
                        )
                        .shadow(radius: 10)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 500)
                    
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(1.0))
            }
            .frame(maxWidth: .infinity)
            .background(
                AngularGradient(colors: [.cyan, .pink, .white, .red, .blue, .white, .cyan],
                                center: .center,
                                startAngle: Angle(degrees: 0),
                                endAngle: Angle(degrees: 350)
                               ).opacity(0.3)
            )
            //The overlay appears when the user starts purchasing
            .overlay(content: {
                processView(isPurchasing: $isPurchasing)
            })
            //Error alert
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text("Sorry, we encountered an error while processing your order."), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                print("getting current offerings")
                Purchases.shared.getOfferings { offerings, error in
                    if let offer = offerings?.current, error == nil {
                        currentOffering = offer
                    }
                }
            }
        }
    }
}

//check if the user is upgrading or downgrading their current subscription
func UpgradeOrDowngrade(currentPermissionLevel: String, purchasePermissionLevel: String) -> String {
    let upgrade = "upgrade"
    let downgrade = "downgrade"
    
    if currentPermissionLevel == "Apprentice" {
        //user is Apprentice
        switch purchasePermissionLevel {
        case "Sorcerer":
            return upgrade
        case "Illusionist":
            return upgrade
        default:
            return upgrade
        }
        //user is Sorcerer
    } else if currentPermissionLevel == "Sorcerer" {
        switch purchasePermissionLevel {
        case "Apprentice":
            return downgrade
        case "Illusionist":
            return upgrade
        default:
            return downgrade
        }
    } else {
        //user is Illusionist
        switch purchasePermissionLevel {
        case "Apprentice":
            return downgrade
        case "Sorcerer":
            return downgrade
        default:
            return downgrade
        }
    }
}

//MARK: Purchase Button
struct PurchaseButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPurchasing: Bool
    @Binding var showErrorAlert: Bool
    @Binding var currentOffering: Offering?
    @EnvironmentObject var userViewModel: UserViewModel
    var packageID: String
    var entitlementID: String
    var buttonColor: [Color]
    var PermissionsLevel: PermissionsStruct
    var body: some View {
        if currentOffering != nil {
            // Find the package within the current offering.
            let Package = currentOffering!.availablePackages.first(where: { $0.identifier ==
                packageID
            })
//            let thing = currentOffering?.availablePackages.first?.identifier
//
            
                Button(action: {
                    isPurchasing = true
                    if let package = Package {
                        Purchases.shared.purchase(package: package) { (transaction, customerInfo, error, userCancelled) in
                            
                            if userViewModel.currentUserEntitlements.title != "Free Trial" {
                                //Direction will either be upgrade or downgrade
                                let Direction = UpgradeOrDowngrade(currentPermissionLevel: userViewModel.currentUserEntitlements.title, purchasePermissionLevel: entitlementID)
                                if Direction == "downgrade" {
                                    if error != nil {
                                        showErrorAlert = true
                                        isPurchasing = false
                                    } else if (userCancelled == true){
                                        isPurchasing = false
                                    } //else {
//                                        var newToks = 0
//                                        switch entitlementID {
//                                        case "Apprentice":
//                                            newToks = 1000
//                                        case "Sorcerer":
//                                            newToks = 6500
//                                        case "Illusionist":
//                                            newToks = 20000
//                                        default:
//                                            newToks = 0
//                                        }
//                                        userViewModel.currentTokens += newToks
//                                    }
                                    isPurchasing = false
                                }
                            } else {
                                //Upgrade Flow
                                if customerInfo?.entitlements.all["\(entitlementID)"]?.isActive == true {
                                    // Unlock the corresponding package permissions
                                    userViewModel.currentUserEntitlements = PermissionsLevel
                                    //this is to sync title status because of apple settings upgrades possibility
                                    userViewModel.lastKnownTitle = userViewModel.currentUserEntitlements.title
                                    //Add the tokens for initial purchase
                                    userViewModel.currentTokens += userViewModel.currentUserEntitlements.monthlyTokens
                                    userViewModel.totalTokens = userViewModel.currentTokens + userViewModel.currentTrialTokens
                                    isPurchasing = false
                                } else if (userCancelled == true){
                                    isPurchasing = false
                                } else if (error != nil) {
                                    showErrorAlert = true
                                    isPurchasing = false
                                }
                            }
                            
                           
                        }
                    }
                }, label: {
                    Text("Subscribe")
                        .padding(5)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(maxWidth: 200)
                })
                .background(RadialGradient(colors: buttonColor, center: .trailing, startRadius: 0, endRadius: 130))
                .clipShape(Capsule())
            
        }
    }

}

//MARK: Package struct
struct Package: View {
    var Tier: String
    var price: String
    var Point1: String
    var Point2: String
    var Point3: String
    var Point4: String
    var frameSize: CGFloat
    var buttonColor: [Color]
    var accentColor: [Color]
    var packageID: String
    var entitlementID: String
    var PermissionsLevel: PermissionsStruct
    @Binding var isPurchasing: Bool
    @Binding var currentOffering: Offering?
    @Binding var showErrorAlert: Bool
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            //HEADER
            Text(Tier)
                .font(
                    .largeTitle
                    .weight(.regular)
                )
                .foregroundStyle(RadialGradient(colors: accentColor, center: .trailing, startRadius: 0, endRadius: 130))
                .padding(2)
            
            
            //POINTS
            VStack(alignment: .leading) {
                Text(Point1)
                    .font(
                        .body
                        .weight(.light)
                        
                    )
                    
  
                Text(Point2)
                    .font(
                        .body
                        //.system(.body, design: .rounded)
                        .weight(.light)
                    )
                    
                Text(Point3)
                    .font(
                        .body
                        //.system(.body, design: .rounded)
                        .weight(.light)
                    )
                
                Text(Point4)
                    .font(
                        .body
                        //.system(.body, design: .rounded)
                        .weight(.light)
                    )
            }
           // .frame(width: frameSize * 0.9, height: 90)
            .padding(.leading, 2)
            .padding(.trailing, 2)
            
            //PRICE
            Text(price)
                .font(
                    .callout
                    //.system(size: 24, design: .rounded)
                    .weight(.medium)
                )
                .padding(.top, 2)
            
            //SUBSCRIBE BUTTON
            PurchaseButton(isPurchasing: $isPurchasing, showErrorAlert: $showErrorAlert, currentOffering: $currentOffering, packageID: packageID, entitlementID: entitlementID, buttonColor: buttonColor, PermissionsLevel: PermissionsLevel)
            
            
        }//END of VStack
        .padding(8)
        .frame(maxWidth: frameSize )
        
        .background(.thinMaterial)
        .cornerRadius(10)
        //.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(borderColor), lineWidth: 2))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(LinearGradient(colors: accentColor, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
    }
}

//MARK: Process View
struct processView: View {
    @Binding var isPurchasing: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.black)
                .cornerRadius(10)
                .edgesIgnoringSafeArea(.all)
                
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                Text("We're processing your order.")
                    .foregroundColor(.white)
                    .padding()
            }
        }.opacity(isPurchasing ? 0.7 : 0)
    }
}

//MARK: Preview
struct Paywall_Previews: PreviewProvider {
    static var previews: some View {
        Paywall()
    }
}
