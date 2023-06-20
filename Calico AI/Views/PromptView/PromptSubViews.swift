//
//  PromptSubViews.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-16.
//

import Foundation
import SwiftUI

struct ImageDimensionsView: View {
    @Binding var syncAspectRatio: Bool
    @Binding var numImages: Double
    @Binding var widthState: Int
    @Binding var heightState: Int
    @EnvironmentObject var viewModel: ViewModelClass
   
    
    var body: some View {
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
                .tint(.blue)
                .onChange(of: syncAspectRatio) { newValue in
                    if newValue {
                        widthState = 512
                        heightState = closestMultipleOfEight(Double(widthState) * viewModel.aspectRatio)
                    }
                }
                
                HStack {
                    Text("Number of Images: \(Int(numImages))")
                        .frame(maxWidth: 130, alignment: .leading)
                    Slider(value: $numImages, in: 1...viewModel.numImagesMax, step: 1)
                    
                    
                }
            }
            .padding([.leading, .trailing], 25)
            
        }
    }
}

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

struct PromptSubview_Previews: PreviewProvider {
    static var previews: some View {
        PromptView(syncAspectRatio: .constant(false), positivePromptState: .constant(""), negativePromptState: .constant(""), widthState: .constant(512), heightState: .constant(512), samplesState: .constant(30), guidanceState: .constant(7.5), seedState: .constant("100"), imgGuidanceState: .constant(0.5), useControlNet: .constant(true), useCannyImg2Img: .constant(false), numImages: .constant(1))
                .environmentObject(ViewModelClass())
    }
}
