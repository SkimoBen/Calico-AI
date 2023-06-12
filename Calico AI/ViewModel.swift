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
}

class UserViewModel: ObservableObject {
    @Published var isSubscriptionActive = false //DONT FORGET TO SET FALSE
    @Published var isPurchasing = false
    init() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["spotWx Pro"]?.isActive == true {
                // User is "premium"
                
                self.isSubscriptionActive = true
                
                
            }
        }
        
    }
}
