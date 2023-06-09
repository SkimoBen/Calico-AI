//
//  Calico_AIApp.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI

@main
struct Calico_AIApp: App {
    @StateObject private var viewModel = ViewModelClass()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
