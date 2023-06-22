//
//  AdvancedSettingsView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-22.
//

import Foundation
import SwiftUI
import Combine

struct AdvancedSettingsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var guidanceState: Double
    @Binding var seedState: String
    @Binding var imgGuidanceState: Double
    @Binding var useControlNet: Bool
    @Binding var useCannyImg2Img: Bool
    @Binding var samplesState: Double
    @Binding var useControlNetId: UUID
    @Binding var hidePromptView: Bool
    var body: some View {
        VStack {
            
            Text("Advanced Settings")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 25)
                .padding(.top, 5)
                .font(
                    .system(
                        size: 20,
                        weight: .light,
                        design: .rounded
                    )
                )
                .foregroundColor(Color.blue)
            
            
            
            
            HStack {
                Text("Samples: \(Int(samplesState))")
                    .frame(maxWidth: 130, alignment: .leading)
                Slider(value: $samplesState, in: 1...Double(userViewModel.currentUserEntitlements.maxSamples))
                
                
            }
            .padding([.leading, .trailing], 25)
            
            HStack {
                Text("Prompt Guidance: \(String(format: "%.1f", guidanceState))")
                    .frame(maxWidth: 130, alignment: .leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    
                    
                Slider(value: $guidanceState, in: 1...30, step: 0.5)
            }
            .padding( [.leading, .trailing], 25)
            
            HStack {
                Text("Diffusion \nStrength: \(String(format: "%.2f", imgGuidanceState))")
                    .frame(maxWidth: 130, alignment: .leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                   
                Slider(value: $imgGuidanceState, in: 0...1, step: 0.05)
            }
            .padding( [.leading, .trailing], 25)
            
            HStack {
                Text("Seed: ")
                    .frame(maxWidth: 130, alignment: .leading)
                
                TextField("seed", text: $seedState) { isEditing in
                    withAnimation {
                        self.hidePromptView = isEditing
                    }
                } onCommit: {}
                // .focused($isFocused)
                    .padding(3)
                    .font(.title3)
                
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 0.5))
                    .keyboardType(.numberPad)
                    .onReceive(Just(seedState)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.seedState = filtered
                        }
                    }
            }
            .padding([.leading, .trailing], 25)
            
            //Control net toggles
            VStack {
                Toggle(isOn: $useControlNet) {
                    Text("Use Control Net")
                }
                .tint(.blue)
                if useControlNet == true {
                    withAnimation {
                        Toggle(isOn: $useCannyImg2Img) {
                            Text("Use Image + Control Net")
                        }
                        .id(useControlNetId)
                        .tint(.blue)
                        .transition(.slide)
                    }
                    
                }
            }
            .padding([.leading, .trailing], 25)
            
        }.transition(.opacity)
    }
}
