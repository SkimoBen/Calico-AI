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
    @EnvironmentObject var userViewModel: UserViewModel
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
    @State var useControlNetId = UUID()
    @Binding var useCannyImg2Img: Bool
    @Binding var numImages: Double
    @State var isInfoShowing: Bool = false
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
                        
                        //MARK: Prompt Group elements
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
                                    
                                    //MARK: Poitive Prompt View
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
                                    //MARK: Negative Prompt View
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
                            
                            //MARK: Image dimensions group
                           ImageDimensionsView(syncAspectRatio: $syncAspectRatio, numImages: $numImages, widthState: $widthState, heightState: $heightState)
                               
                            
                            
                            //MARK: Advanced Settings Group
                            AdvancedSettingsView(guidanceState: $guidanceState, seedState: $seedState, imgGuidanceState: $imgGuidanceState,  useControlNet: $useControlNet, useCannyImg2Img: $useCannyImg2Img, samplesState: $samplesState, useControlNetId: $useControlNetId, hidePromptView: $hidePromptView)
                            
                        }

                        Spacer()
                    }//MARK: Bottom of ScrollView
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
                //MARK: Bottom of Scrollview Reader
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
            }//MARK: Bottom of Navigation View
            .background(Material.ultraThin)
        }
    }
}

//MARK: Previews
struct PromptView_Previews: PreviewProvider {
    static var previews: some View {
        PromptView(syncAspectRatio: .constant(false), positivePromptState: .constant(""), negativePromptState: .constant(""), widthState: .constant(512), heightState: .constant(512), samplesState: .constant(30), guidanceState: .constant(7.5), seedState: .constant("100"), imgGuidanceState: .constant(0.5), useControlNet: .constant(true), useCannyImg2Img: .constant(false), numImages: .constant(1))
                .environmentObject(ViewModelClass())
                .environmentObject(UserViewModel())
    }
       
}
