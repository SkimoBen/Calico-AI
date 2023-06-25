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

//MARK: ViewModelClass
class ViewModelClass: ObservableObject {
    @Published var background: UIImage? = nil
    @Published var aspectRatio: Double = 1.0
    @Published var drawing: PKDrawing = PKDrawing()
    @Published var shouldBecomeFirstResponder: Bool = true
    @Published var useTxt2Img: Bool = true
    @Published var enhancedPrompt: String = ""
    @Published var numImagesMax: Double = 4
}

//MARK: UserViewModel Class
class UserViewModel: ObservableObject {
    
    //    @Published var isPurchasing = false
    @Published var currentUserEntitlements: PermissionsStruct = UserEntitlements().Trial ///DONT   FORGET   TO   SET   TO   TRIAL
    @Published var totalPurchases: Int {
        didSet {
            //save the current tokens to user defaults every time it changes.
            UserDefaults.standard.set(totalPurchases, forKey: "totalPurchases")
        }
    }
    @Published var latestPurchaseDate: Int {
        didSet {
            //save the current tokens to user defaults every time it changes.
            UserDefaults.standard.set(latestPurchaseDate, forKey: "latestPurchaseDate")
        }
    }
    
    @Published var currentTokens: Int {
        didSet {
            //save the current tokens to user defaults every time it changes.
            UserDefaults.standard.set(currentTokens, forKey: "currentTokens")
        }
    }
    @Published var refillDate: Int {
        didSet {
            //save the current tokens to user defaults every time it changes.
            UserDefaults.standard.set(refillDate, forKey: "refillDate")
        }
    }
    @Published var lastKnownTitle: String {
        didSet {
            UserDefaults.standard.set(lastKnownTitle, forKey: "lastKnownTitle")
        }
    }
    
    //initialize a default date...not using.
    let defaultDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    init() {
        
        //First get the current tokens and last known purchase date.
        currentTokens = UserDefaults.standard.integer(forKey: "currentTokens")
        latestPurchaseDate = UserDefaults.standard.integer(forKey: "latestPurchaseDate")
        totalPurchases = UserDefaults.standard.integer(forKey: "totalPurchases")
        refillDate = UserDefaults.standard.integer(forKey: "refillDate")
        lastKnownTitle = UserDefaults.standard.string(forKey: "lastKnownTitle") ?? "Free Trial"
        
        // Check if the app is run for the first time (latestPurchaseDate is Unix Epoch time)
           if latestPurchaseDate == 0 {
               // Update latestPurchaseDate to the current time
               latestPurchaseDate = DateToInt(Date: Date())
               currentTokens = 100
           }
        
        //initialize the UserViewModel by calling the Revenue Cat DB to check for the users entitlement. Entitlements control the permissions inside the app.
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            
            //This is only because a user could upgrade from the apple settings thing. 
            if self.lastKnownTitle != self.currentUserEntitlements.title {
                print(self.lastKnownTitle)
                print(self.currentUserEntitlements.title)
                self.currentTokens += self.currentUserEntitlements.monthlyTokens
                self.lastKnownTitle = self.currentUserEntitlements.title
            }
            
            //MARK: Apprentice initialization
            if customerInfo?.entitlements.all["Apprentice"]?.isActive == true {
                /// User is "Apprentice"
                self.currentUserEntitlements = UserEntitlements().Apprentice
                
                //Get the last purchase date from revenueCat
                let PDate = DateToInt(Date: (customerInfo?.entitlements.all["Apprentice"]?.latestPurchaseDate)!)
                let willRenew = customerInfo?.entitlements.all["Apprentice"]?.willRenew
                
                //if the revenuecat purchase date is later than the last purchase on local storage, update it and add it to total purchases.
                self.updateTokensAndPurchases(PDate: PDate, willRenew: willRenew!)
                
                
                //repeat for other tiers
                //MARK: Sorcerer initialization
            } else if (customerInfo?.entitlements.all["Sorcerer"]?.isActive == true ) {
                /// User is "Sorcerer"
                self.currentUserEntitlements = UserEntitlements().Sorcerer
             
                let PDate = DateToInt(Date: (customerInfo?.entitlements.all["Sorcerer"]?.latestPurchaseDate)!)
                let willRenew = customerInfo?.entitlements.all["Sorcerer"]?.willRenew
                
                self.updateTokensAndPurchases(PDate: PDate, willRenew: willRenew!)
                
                //MARK: Illusionist initialization
            } else if (customerInfo?.entitlements.all["Illusionist"]?.isActive == true ) {
                /// User is "Illusionist
                self.currentUserEntitlements = UserEntitlements().Illusionist

                let PDate = DateToInt(Date: (customerInfo?.entitlements.all["Illusionist"]?.latestPurchaseDate)!)
                let willRenew = customerInfo?.entitlements.all["Illusionist"]?.willRenew
                
                self.updateTokensAndPurchases(PDate: PDate, willRenew: willRenew!)
                
                //MARK: Trial initialization
            } else {
                /// User is "Trial"
                self.currentUserEntitlements = UserEntitlements().Trial
                
                let currentDate = Date()
                
                // Convert latestPurchaseDate (Unix timestamp) to a Date object
                var latestPurchaseDateAsDate = Date(timeIntervalSince1970: TimeInterval(self.latestPurchaseDate))
                
                // Check if more than one month has passed since the latest token refill date
                let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: latestPurchaseDateAsDate)
                
                if let nextRefillDate = oneMonthLater, currentDate >= nextRefillDate {
                    
                    // If one month or more has passed since the last token refill, add new tokens
                    self.currentTokens = 100
                    
                    // Update the latest token refill date to one month from the previous refill date
                    let nextRefillDateAsInt = Int(nextRefillDate.timeIntervalSince1970)
                    self.latestPurchaseDate = nextRefillDateAsInt
                }
                ///Make the refill date. Needs to happen here because trials dont have RevenueCat purchase dates.
                latestPurchaseDateAsDate = Date(timeIntervalSince1970: TimeInterval(self.latestPurchaseDate))
                
                print("Latest Purchase Date: \(latestPurchaseDateAsDate)")
                // Calculate the date one month from latestPurchaseDate
                let refillDateAsDate = Calendar.current.date(byAdding: .month, value: 1, to: latestPurchaseDateAsDate)
                
                // Convert refillDate back to Unix timestamp (Int)
                self.refillDate = Int(refillDateAsDate!.timeIntervalSince1970)
            }
            
        }
        
    }
    //MARK: UpdateTokens and Purchases
    func updateTokensAndPurchases(PDate: Int, willRenew: Bool) {
        // If the RevenueCat purchase date is later than the last purchase on local storage, update it and add it to total purchases.
        if PDate > self.latestPurchaseDate {
            // Convert latestPurchaseDate and PDate (Unix timestamps) to Date objects
            let latestPurchaseDateAsDate = Date(timeIntervalSince1970: TimeInterval(self.latestPurchaseDate))
            let PDateAsDate = Date(timeIntervalSince1970: TimeInterval(PDate))
            
            // Calculate the number of months that have passed since the last purchase
            let calendar = Calendar.current
            
            let dateComponents = calendar.dateComponents([.month], from: latestPurchaseDateAsDate, to: PDateAsDate)
            let monthsPassed = dateComponents.month ?? 0
            
            //This is for debugging the token refresh.
//            let dateComponents = calendar.dateComponents([.minute], from: latestPurchaseDateAsDate, to: PDateAsDate)
//            let monthsPassed = dateComponents.minute ?? 0
            // Add tokens for all the months that have passed
            self.totalPurchases += monthsPassed
            self.currentTokens += self.currentUserEntitlements.monthlyTokens * monthsPassed
            
            // Update the latest purchase date
            self.latestPurchaseDate = PDate
        }
        if willRenew {
            // Convert latestPurchaseDate to Date
            let latestPurchaseDateAsDate = Date(timeIntervalSince1970: TimeInterval(self.latestPurchaseDate))
            
            // Calculate the date one month from latestPurchaseDate
            let refillDateAsDate = Calendar.current.date(byAdding: .second, value: 100, to: latestPurchaseDateAsDate)
            
            // Convert refillDate back to Unix timestamp (Int)
            self.refillDate = Int(refillDateAsDate!.timeIntervalSince1970)
        }
    }
}


