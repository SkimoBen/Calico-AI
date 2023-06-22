//
//  ViewModel.swift
//  AI Tattoo Creator
//
//  Created by Ben Pearman on 2023-05-28.
//

import Foundation
import SwiftUI
import PencilKit
import RevenueCat

class ViewModelClass: ObservableObject {
    @Published var background: UIImage? = nil
    @Published var aspectRatio: Double = 1.0
    @Published var drawing: PKDrawing = PKDrawing()
    @Published var shouldBecomeFirstResponder: Bool = true
    @Published var useTxt2Img: Bool = true
    @Published var enhancedPrompt: String = ""
    @Published var numImagesMax: Double = 4
}


class UserViewModel: ObservableObject {
//    @Published var isApprentice = false
//    @Published var isSorcerer = false
//    @Published var isIllusionist = false
//    @Published var isPurchasing = false
    @Published var currentUserEntitlements: PermissionsStruct = UserEntitlements().Illusionist ///DONT   FORGET   TO   SET   TO   TRIAL
    init() {
        ///initialize the UserViewModel by calling the Revenue Cat DB to check for the users entitlement. Entitlements control the permissions inside the app.
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["Apprentice"]?.isActive == true {
                
                /// User is "Apprentice"
                self.currentUserEntitlements = UserEntitlements().Apprentice
                
            } else if (customerInfo?.entitlements.all["Sorcerer"]?.isActive == true ) {
                
                /// User is "Sorcerer"
                self.currentUserEntitlements = UserEntitlements().Sorcerer
                
            } else if (customerInfo?.entitlements.all["Illusionist"]?.isActive == true ) {
                
                /// User is "Illusionist
                self.currentUserEntitlements = UserEntitlements().Illusionist
            }
        }
        
    }
}
