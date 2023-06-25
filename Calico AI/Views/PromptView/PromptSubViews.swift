//
//  PromptSubViews.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-16.
//

import Foundation
import SwiftUI

func MaxGenerations(UserMax: Int, currentWidth: Int, currentHeight: Int) -> Int {
    let resolution = max(currentHeight, currentWidth)
    var resolutionMax: Int = 0
    
    switch resolution{
    case ...1024:
        resolutionMax = 4
    case 1024...1600:
        resolutionMax = 2
    case 1600...:
        resolutionMax = 1
    default:
        resolutionMax = 4
    }
    
    if UserMax > resolutionMax {
//        print("Res Max_____")
//        print(resolutionMax)
        return resolutionMax
    } else {
//        print("User Max_____")
//        print(UserMax)
        return UserMax
    }
    
}
    //MARK: Image dimensions view
    struct ImageDimensionsView: View {
        @Binding var syncAspectRatio: Bool
        @Binding var numImages: Double
        @Binding var widthState: Int
        @Binding var heightState: Int
        @EnvironmentObject var viewModel: ViewModelClass
        @EnvironmentObject var userViewModel: UserViewModel
        @State var maxGenerations: Int = 4
        @State private var isFirstAppear = true
        
        var body: some View {
            let maxResolution = userViewModel.currentUserEntitlements.maxResolution
            
            
            Group {
                VStack {
                    //MARK: Width slider
                    Text("Width: \(widthState)")
                    Slider(value: Binding(get: {
                        Double(widthState)
                    }, set: { (newValue) in
                        
                        if syncAspectRatio {
                            let potentialNewWidth = min(Int(newValue), maxResolution)
                            let potentialNewHeight = closestMultipleOfEight(Double(potentialNewWidth) * viewModel.aspectRatio)

                            if potentialNewHeight <= maxResolution {
                                widthState = potentialNewWidth
                                heightState = potentialNewHeight
                            }
                        } else {
                            widthState = min(Int(newValue), maxResolution)
                        }
                        //check the max gnerations
                        maxGenerations = MaxGenerations(UserMax: userViewModel.currentUserEntitlements.maxGenerations, currentWidth: widthState, currentHeight: heightState)
                    
                    }), in: 8...Double(maxResolution), step: 8)
                    
                    //MARK: Height slider
                    Text("Height: \(heightState)")
                    Slider(value: Binding(get: {
                        Double(heightState)
                    }, set: { (newValue) in
                        //need this here for the slider because toggle is its own thing.
                        if syncAspectRatio {
                            let potentialNewHeight = min(Int(newValue), maxResolution)
                            let potentialNewWidth = closestMultipleOfEight(Double(potentialNewHeight) / viewModel.aspectRatio)

                            if potentialNewWidth <= maxResolution {
                                heightState = potentialNewHeight
                                widthState = potentialNewWidth
                            }
                        } else {
                            heightState = min(Int(newValue), maxResolution)
                        }

                        //check the max gnerations
                        maxGenerations = MaxGenerations(UserMax: userViewModel.currentUserEntitlements.maxGenerations, currentWidth: widthState, currentHeight: heightState)
                        
                    }), in: 8...Double(maxResolution), step: 8)
                    
                    Toggle(isOn: $syncAspectRatio) {
                        Text("Sync Aspect Ratio")
                    }
                    .tint(.blue)
                    //MARK: On change functions
                    .onChange(of: syncAspectRatio) { newValue in
                        if newValue {
                            if viewModel.aspectRatio < 1 {
                                //landscape mode
                                widthState = maxResolution
                                heightState = closestMultipleOfEight(Double(widthState) * viewModel.aspectRatio)
                            } else {
                                //portrait mode
                                heightState = maxResolution
                                widthState = closestMultipleOfEight(Double(heightState) / viewModel.aspectRatio)
                            }
                            
                            
                        }
                    }
                    //MARK: Generations
                    HStack {
                        Text("Generations: \(Int(numImages))")
                            .frame(maxWidth: 130, alignment: .leading)
                        if (heightState > 1600 || widthState > 1600) || userViewModel.currentUserEntitlements.maxGenerations == 1 {
                            Spacer()
                        } else {
                            Slider(value: $numImages, in: 1...Double(maxGenerations), step: 1)
                        }
                        
                        
                    }
                    
                }
                .padding([.leading, .trailing], 25)
                .onChange(of: maxGenerations) { newValue in
                    if numImages > Double(newValue) {
                        numImages = Double(newValue)
                    }
                }
                .onAppear {
                    maxGenerations = MaxGenerations(UserMax: userViewModel.currentUserEntitlements.maxGenerations, currentWidth: widthState, currentHeight: heightState)
                }
            }
        }
    }

//MARK: Negative Prompt View
struct NegativePromptView: View {
        @Binding var negativePromptState: String
        var body: some View {
            HStack {
                Text("Negative Prompt")
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.leading, 25)
                
                Button(action: {
                    //update the negative prompt
                    negativePromptState = negativePromptState + easyNegative.joined(separator: ",")
                    
                    
                }, label: {
                    Text("Easy Negative")
                        .foregroundColor(.primary)
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 4)
                        .font(
                            .caption
                        )
                })
                .background(Color.blue.opacity(0.4))  // Set the background color to cyan
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))// Give the button rounded corners
                .padding(.trailing, 25)
                .padding(.top,10)
            }
        }
    }
    
//MARK: Positive Prompt View
    struct PositivePromptView: View {
        @Binding var positivePromptState: String
        @Binding var enhancing: Bool
        @EnvironmentObject var viewModel: ViewModelClass
        
        var body: some View {
            Group {
                HStack {
                    Text("Positive Prompt")
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 2)
                        .padding(.leading, 25)
                    
                    Button(action: {
                        //update the prompt var for API call
                        positivePrompt = positivePromptState
                        updateCerebriumPromptEnhancerJSONObject()
                        enhancing = true
                        //call the API
                        EnhancePrompt(viewModel: viewModel,
                                      completion: {
                            positivePromptState = viewModel.enhancedPrompt
                            enhancing = false
                        },
                                      failure: { error in
                            print("Failure: \(error)")
                            enhancing = false
                        })
                    }, label: {
                        if enhancing == true {
                            
                            ProgressView()
                        } else {
                            Text("Enhance Prompt")
                                .foregroundColor(.primary)
                                .padding([.leading, .trailing], 10)
                                .padding([.top, .bottom], 4)
                                .font(
                                    .caption
                                )
                        }
                        
                    })
                    .background(enhancing ? Color.clear : Color.blue.opacity(0.4))  // Set the background color to cyan
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(enhancing ? nil : RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))// Give the button rounded corners
                    .padding(.trailing, 25)
                }
            }
        }
    }
    
//MARK: Previews
    struct PromptSubview_Previews: PreviewProvider {
        static var previews: some View {
            PromptView(syncAspectRatio: .constant(false), positivePromptState: .constant(""), negativePromptState: .constant(""), widthState: .constant(512), heightState: .constant(512), samplesState: .constant(30), guidanceState: .constant(7.5), seedState: .constant("100"), imgGuidanceState: .constant(0.5), useControlNet: .constant(true), useCannyImg2Img: .constant(false), numImages: .constant(1))
                .environmentObject(ViewModelClass())
                .environmentObject(UserViewModel())
        }
    }

