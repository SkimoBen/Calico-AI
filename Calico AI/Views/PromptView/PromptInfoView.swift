//
//  PromptInfoView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI

struct PromptInfoView: View {
    @State private var animatedHue = false
    @State private var animatedPosition = false
    @Binding var isInfoShowing: Bool
    var body: some View {
        VStack {
            ScrollView {
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {
                            isInfoShowing = false
                        }, label: {
                            HStack {
                                Image(systemName: "chevron.backward")
                                Text("back")
                            }
                            
                                
                        })
                        .background(.clear)
                        .padding(.leading)
                        Spacer()
                    }
                    //Prompts
                    Group {
                        SectionView(header: "Positive Prompt", text: "Describe your photo / sketch. Adding style keywords is very important. Try submitting a blank canvas with the prompt: 'poster of a cat standing alone on hill, centered, very fluffy, Pixar, key visual, intricate detail, breathtaking, vibrant, cinematic, 3D'")
                        
                        SectionView(header: "Negative Prompt", text: "Describe what you don't want in your image. Try adding 'plants, grass, trees' along with the positive prompt above.")
                    }
                    
                    
                    
                    SectionView(header: "Width and Height", text: "The desired dimensions of your image, in pixels.")
                    
                    SectionView(header: "Sync Aspect Ratio", text: "When enabled, the aspect ratio of your output image is locked to the aspect ratio of your input image. This is recommended unless you aren't using any visual inputs (scribbles / photos).")
                    
                    SectionView(header: "Samples", text: "The number of calculations the AI model takes, sometimes more is better if you have a complex prompt. More samples = more time to generate an image.")
                    
                    SectionView(header: "Prompt Guidance", text: "How closely should the AI model follow your prompt? Higher numbers make it follow the prompt more, sometimes at the cost of image quality.")
                    
                    SectionView(header: "Diffusion Strength", text: "How much should the model diffuse your image before re-creating it? 0 will not diffuse your image at all, 1 will turn it into complete noise.")
                    
                    SectionView(header: "Seed", text: "0 will create a different image even if you don't change the inputs, if you want to get the same output, choose a random number like 12345678 and use it for different generations.")
                    SectionView(header: "Control Net", text: "The generation will be guided by an outline of your original image. Useful if you want to maintain the composition of the original image but want the elements or colours to change.")
                    
                    SectionView(header: "Image + Control Net", text: "Use your existing image in addition to Control Net. Your image will be diffused according to the Diffusion Strength parameter.")
                    
                
                }
                .padding()
                
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [.cyan, .blue, .red]), startPoint: animatedPosition ? .topLeading : .topTrailing, endPoint: animatedPosition ? .bottomTrailing : .bottomLeading)
                    .hueRotation(.degrees(animatedHue ? 90 : 0))
                    .ignoresSafeArea()
                    .opacity(0.2)
            )
            //start the hue animation on the background
            .onAppear {
                withAnimation(
                    .linear(duration: 15.0)
                    
                    .repeatForever(autoreverses: true)
                ){
                    
                    self.animatedHue.toggle()
                    
                    
                    
                }
                //for the position of the gradient
                withAnimation(
                    .linear(duration: 15.0)
                    
                    .repeatForever(autoreverses: true)
                ){
                    
                    
                    self.animatedPosition.toggle()
                    
                }
            }
        }
    }
}
    
    struct SectionView: View {
        var header: String
        var text: String
        @Environment(\.colorScheme) var colorScheme
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(header)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(
                        .system(size: 24, design: .rounded)
                        .weight(.light)
                        
                    )
                    .foregroundColor(colorScheme == .light ? Color.init(hue: 198, saturation: 0.6, brightness: 0.2) : Color.init(hue: 191/360, saturation: 0.15, brightness: 0.99))
                    .padding(.top, 10)
                    
                
                Text(text)
                    .font(
                        .system(size: 16)
                        .weight(.light)
                    )
                    .foregroundColor(colorScheme == .light ? Color.init(hue: 198, saturation: 0.6, brightness: 0.2) : Color.init(hue: 191/360, saturation: 0.15, brightness: 0.99))
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                .thinMaterial
                //.blendMode(.hardLight)
                .opacity(0.9)
                
            )
            .cornerRadius(10)
        }
    }
    
    struct PromptInfoView_Previews: PreviewProvider {
        
        static var previews: some View {
            PromptInfoView(isInfoShowing: .constant(false))
        }
    }
