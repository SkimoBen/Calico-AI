//
//  Calico_AIApp.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI
import RevenueCat

@main
struct Calico_AIApp: App {
    @StateObject private var viewModel = ViewModelClass()
    @StateObject private var userViewModel = UserViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(userViewModel)
        }
    }
    //initialize the Revenue Cat purchases
    init() {
        Purchases.logLevel = .debug //set to debug if needed.
        Purchases.configure(withAPIKey: "appl_QnniVIULUauINWMGECMiVXvRvyQ")
        
        
    }
}
