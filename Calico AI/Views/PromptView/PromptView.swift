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
    @State var isInfoShowing: Bool = false
    var body: some View {
        if isInfoShowing == true {
            PromptInfoView(isInfoShowing: $isInfoShowing)
        } else {
            
            
            
            //note, it's only a NavigationView because that's the only view that lets a toolbar work.
            NavigationView {
                VStack {
                    
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
                                    
                                    //                                .popover(isPresented: $isInfoShowing, attachmentAnchor: .point(.center), content: {
                                    //                                    PromptInfoView()
                                    //                                       // .background(Color.red.opacity(1))
                                    //                                       // .background(Material.ultraThin.blendMode(.multiply).opacity(0.1))
                                    //
                                    //
                                    //                                })
                                    
                                    
                                }
                                
                                
                                Text("Positive Prompt")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 2)
                                    .padding(.leading, 25)
                                
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
                                
                                Text("Negative Prompt")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 10)
                                    .padding(.leading, 25)
                                
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
                        Group {
                            VStack {
                                Text("Width: \(widthState)")
                                Slider(value: Binding(get: {
                                    Double(widthState)
                                }, set: { (newValue) in
                                    let newWidth = Int(newValue)
                                    if syncAspectRatio {
                                        let newHeight = closestMultipleOfEight(Double(newWidth) * viewModel.aspectRatio)
                                        if newHeight <= 2000 {
                                            widthState = newWidth
                                            heightState = newHeight
                                        }
                                    } else {
                                        widthState = newWidth
                                    }
                                }), in: 8...2000, step: 8)
                                
                                Text("Height: \(heightState)")
                                Slider(value: Binding(get: {
                                    Double(heightState)
                                }, set: { (newValue) in
                                    let newHeight = Int(newValue)
                                    if syncAspectRatio {
                                        let newWidth = closestMultipleOfEight(Double(newHeight) / viewModel.aspectRatio)
                                        if newWidth <= 2000 {
                                            heightState = newHeight
                                            widthState = newWidth
                                        }
                                    } else {
                                        heightState = newHeight
                                    }
                                }), in: 8...2000, step: 8)
                                
                                Toggle(isOn: $syncAspectRatio) {
                                    Text("Sync Aspect Ratio")
                                }
                                .onChange(of: syncAspectRatio) { newValue in
                                    if newValue {
                                        widthState = 512
                                        heightState = closestMultipleOfEight(Double(widthState) * viewModel.aspectRatio)
                                    }
                                }
                            }
                            .padding([.leading, .trailing], 25)
                        }
                        
                        //Advanced Settings Group
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
                                Slider(value: $samplesState, in: 1...50)
                                
                                
                            }
                            .padding([.leading, .trailing], 25)
                            
                            HStack {
                                Text("Guidance: \(String(format: "%.1f", guidanceState))")
                                    .frame(maxWidth: 130, alignment: .leading)
                                Slider(value: $guidanceState, in: 1...30)
                            }
                            .padding([.leading, .trailing], 25)
                            
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
                        }.transition(.opacity)
                    }
                    
                    
                    
                    Spacer()
                }
                //.background(Color.clear)
                .cornerRadius(10)
                .padding()
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
                
                .clearModalBackground()
                
            }
            //.clearModalBackground()
            .background(Material.ultraThin)
        }
    }
}

struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView(syncAspectRatio: .constant(false), positivePromptState: .constant(""), negativePromptState: .constant(""), widthState: .constant(512), heightState: .constant(512), samplesState: .constant(30), guidanceState: .constant(7.5), seedState: .constant("100"))
    }
}
