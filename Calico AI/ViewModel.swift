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
    @Published var isApprentice = false
    @Published var isSorcerer = false
    @Published var isIllusionist = false //DONT FORGET TO SET FALSE
    @Published var isPurchasing = false
    init() {
        //initialize the UserViewModel by calling the Revenue Cat DB to check for the users entitlement. Entitlements control the permissions inside the app. 
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["Apprentice"]?.isActive == true {
                // User is "Apprentice"
                self.isApprentice = true
                
            } else if (customerInfo?.entitlements.all["Sorcerer"]?.isActive == true ) {
                self.isSorcerer = true
                
            } else if (customerInfo?.entitlements.all["Illusionist"]?.isActive == true ) {
                self.isIllusionist = true
            }
        }
        
    }
}
