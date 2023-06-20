//
//  PromptView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI
import Combine
import UIKit

struct PromptView: View {
   // @ObservedObject private var keyboard = KeyboardResponder()
    @EnvironmentObject var viewModel: ViewModelClass
    @State var hidePromptView = false //to hide the prompt view when necessary
    @State var hideSettingsView = false
    @Binding var syncAspectRatio: Bool
    @FocusState var isFocused: Bool
    @Binding var positivePromptState: String
    @Binding var negativePromptState: String
    @Binding var widthState: Int
    @Binding var heightState: Int
    @Binding var samplesState: Double
    @Binding var guidanceState: Double
    @Binding var seedState: String
    @Binding var imgGuidanceState: Double
    @Binding var useControlNet: Bool
    @Binding var useCannyImg2Img: Bool
    @Binding var numImages: Double
    @State var isInfoShowing: Bool = false
    @State var useControlNetId = UUID()
    @State var enhancing: Bool = false
    //@Binding var numImagesMax: Double
    var body: some View {
        if isInfoShowing == true {
            PromptInfoView(isInfoShowing: $isInfoShowing)
        } else {
            
            //note, it's only a NavigationView because that's the only view that lets a keyboard toolbar work.
            NavigationView {
                ScrollViewReader { proxy in
                    ScrollView {
                        
                        //Prompt group elements
                        Group {
                            if hidePromptView {
                                EmptyView()
                                
                            } else {
                                VStack {
                                    
                                    HStack {
                                        Text("Prompts")
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
                                        Spacer()
                                        
                                        Button(action: {
                                            isInfoShowing = true
                                            
                                        }, label: {
                                            Image(systemName: "info.bubble")
                                                .padding()
                                        })
                                        
                                    }
                                    
                                    
                                    PositivePromptView(positivePromptState: $positivePromptState, enhancing: $enhancing)
                                    
                                    
                                    TextEditor(text: $positivePromptState)
                                        .focused($isFocused)
                                        .frame(minHeight: 100)
                                        .background(.clear)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                        .padding([.leading, .trailing], 20)
                                        .onTapGesture {
                                            
                                            withAnimation {
                                                self.hideSettingsView = true
                                            }
                                            
                                        }
                                    
                                    NegativePromptView(negativePromptState: $negativePromptState)
                                    
                                    TextEditor(text: $negativePromptState)
                                        .frame(minHeight: 100)
                                        .focused($isFocused)
                                        .background(.clear)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                        .padding([.leading, .trailing], 20)
                                        .padding(.bottom)
                                        .onTapGesture {
                                            withAnimation {
                                                self.hideSettingsView = true
                                            }
                                        }
                                }.transition(.opacity)
                            }
                        }
                        
                        if hideSettingsView {
                            EmptyView()
                            
                        } else {
                            
                            //Image dimensions group
                           ImageDimensionsView(syncAspectRatio: $syncAspectRatio, numImages: $numImages, widthState: $widthState, heightState: $heightState)
                            
                            
                            //Advanced Settings Group
                            //TODO: Should be refactored out into its own view
                            Group {
                                
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
                                    Slider(value: $samplesState, in: 1...100)
                                    
                                    
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
                                    Text("Diffusion \nStrength: \(String(format: "%.1f", imgGuidanceState))")
                                        .frame(maxWidth: 130, alignment: .leading)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                       
                                    Slider(value: $imgGuidanceState, in: 0...1)
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

                        Spacer()
                    }
                    .clearModalBackground()
                    //Scrollview goes to the bottom when the controlnet toggle is turned on.
                    .onChange(of: useControlNet) { _ in  // Add onChange
                        useControlNetId = UUID()
                        delay(0.1) {
                            withAnimation {
                                proxy.scrollTo(useControlNetId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                //.background(Color.clear)
                .cornerRadius(10)
                .padding()
                .clearModalBackground()
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            //focusedField = nil
                            isFocused = false
                            withAnimation {
                                hideSettingsView = false
                                hidePromptView = false
                            }
                            
                            UIApplication.shared.endEditing()
                        }
                    }
                }
            }
            .background(Material.ultraThin)
        }
    }
}

struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView(syncAspectRatio: .constant(false), positivePromptState: .constant(""), negativePromptState: .constant(""), widthState: .constant(512), heightState: .constant(512), samplesState: .constant(30), guidanceState: .constant(7.5), seedState: .constant("100"), imgGuidanceState: .constant(0.5), useControlNet: .constant(true), useCannyImg2Img: .constant(false), numImages: .constant(1))
                .environmentObject(ViewModelClass())
    }
       
}
