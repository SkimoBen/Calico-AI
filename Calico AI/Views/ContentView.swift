//
//  ContentView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI
import PencilKit


struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModelClass //for the background image
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var DrawingView = DrawingView_UIView()
    @State var size: CGSize = .zero //size of canvas
    
    
    //for the API image
    @State var generatedImage: UIImage? = nil
    @State var generatedImages: [UIImage]? = nil
    @State var generationFailure: String = ""
    //@State private var updateView = false //workaround for button tap bug
    
    //For showing different views
    @State private var showingAlert = false
    @State private var showAIGenerationView = false
    @State var isImagePickerPresented = false
    @State var showPromptView = false
    @State var showPlayModalView = true
    @State var showProfileView = false
    @State var showPaywallView = false
    
    //---AI variables
    @State var positivePromptState = ""
    @State var negativePromptState = ""
    @State var widthState = 512
    @State var heightState = 512
    @State var samplesState: Double = 30
    @State var guidanceState: Double = 7
    @State var seedState = "0"
    @State var imgGuidanceState: Double = 0.5
    @State var useControlNet: Bool = false
    @State var useCannyImg2Img: Bool = false
    @State var numImages: Double = 1
    @State var syncAspectRatio = false
    @State var firstAppearance = true
    var body: some View {
        
        ZStack {
            VStack {
                //DEBUG: Button for random stuff
//                Button("save"){
//                    saveDrawing()
//                }
//                .padding(.top,20)
                
                //StatusView()
   
                //Spacer()
                   
                if viewModel.background != nil {
                    
                    UserImageView()
                        .onAppear {
                            currentAspectRatio(viewModel: viewModel, size: size)
                            
                            viewModel.shouldBecomeFirstResponder = false
                        }

                    
                } else {
                    
                    DrawingView
                        .saveSize(in: $size) //Size for the scribble.
                        .onAppear {
                            viewModel.shouldBecomeFirstResponder = true
                            
                            //if a drawing or image exists, find the aspect ratio, and then sync the width and height states.
                            if ImagesExist(viewModel: viewModel, drawing: DrawingView.drawing) == true {
                                currentAspectRatio(viewModel: viewModel, size: size)
                                if syncAspectRatio == true {
                                    widthState = 512
                                    heightState = closestMultipleOfEight(Double(widthState) * viewModel.aspectRatio)
                                }
                                
                            }
                            
                            
                        }
                }
            }
            .padding(.top, -12)
  
            
            //MARK: Modal section
            VStack {
                HStack {
                    EditorsButtonsView(showingAlert: $showingAlert, isImagePickerPresented: $isImagePickerPresented, showProfileView: $showProfileView, showPaywallView: $showPaywallView, showPromptView: $showPromptView)
                        .shadow(color: .primary.opacity(0.5), radius: 10 )
                    Spacer() //fill space between elements
                    
                    VStack {
                        Button(action: {
                            //need for the Menu bug.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showPaywallView.toggle()
                            }
                            
                        }, label: {
                            EntitlementsView()
                                .shadow(color: userViewModel.currentUserEntitlements.accentColour[0].opacity(0.5), radius: 5 )
                                
                        })
                        .padding(.bottom, 60)
                        
                    }
                    
                   
                    
                    Spacer()
                    
                    RightMenuView(showingAlert: $showingAlert, showProfileView: $showProfileView)
                        .shadow(color: .primary.opacity(0.5), radius: 10 )
                }
                Spacer() //fill space on the bottom
            }
            //MARK: Image Picker section
            if (isImagePickerPresented) {
                ImagePicker(isImagePickerPresented: $isImagePickerPresented, viewModel: viewModel)
                
            }
            
        }
        //For debgging
//        .onAppear {
//            print(userViewModel.currentUserEntitlements)
//            
//        }
        //alert is for calling the API and switching to image gen view
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Generate Image?"), message: Text("Do you want to generate an image from your drawing? This will take ~1 minute"), primaryButton: .default(Text("Yes")) {
                
                // Perform the action when the user presses OK
                //This is setting up the API variables then triggering the call
                negativePrompt = negativePromptState
                positivePrompt = positivePromptState
                imageHeight = heightState
                imageWidth = widthState
                samples = Int(samplesState)
                guidance = roundToNearestHalf(number: guidanceState)
                seed = Int(seedState) ?? 0
                strength = imgGuidanceState
                num_images_per_prompt = Int(numImages)
                
                //this is to switch pipelines if there's no image input
                if DrawingView.canvasView.drawing.bounds.isEmpty && viewModel.background == nil {
                    preProcessor = "txt2img"
                    showAIGenerationView = true
                } else {
                    returnBase64Image(completion: {
                        print("completion success, calling sendit")
                        //Then show the user the AI generation view in a fullscreen modal
                        showAIGenerationView = true
                    })
                }
                
                
            }, secondaryButton: .cancel())
        }
        //MARK: Bottom of the ZStack, this shows the image generation view.
        .fullScreenCover(isPresented: $showAIGenerationView) {
            AIGenerationView(images: $generatedImages, failure: $generationFailure, showAIGenerationView: $showAIGenerationView).onAppear {
                sendIt(userViewModel: userViewModel, completion: { (images) in
                    self.generatedImages = images
                }, failure: { (error) in
                    withAnimation {
                        self.generationFailure = error
                    }
                    
                })
            }
        }
//        .fullScreenCover(isPresented: $showAIGenerationView) {
//            AIGenerationView(image: $generatedImage, failure: $generationFailure, showAIGenerationView: $showAIGenerationView).onAppear {
//                sendIt(userViewModel: userViewModel, completion: { (image) in
//                    self.generatedImage = image
//                }, failure: { (error) in
//                    withAnimation {
//                        self.generationFailure = error
//                    }
//
//                })
//            }
//        }
        .fullScreenCover(isPresented: $showProfileView) {
            ProfileView(showProfileView: $showProfileView, showPaywallView: $showPaywallView)

        }
        //MARK: PROMPT VIEW
        .sheet(isPresented: $showPromptView) {
            PromptView(syncAspectRatio: $syncAspectRatio, positivePromptState: $positivePromptState, negativePromptState: $negativePromptState, widthState: $widthState, heightState: $heightState, samplesState: $samplesState, guidanceState: $guidanceState, seedState: $seedState, imgGuidanceState: $imgGuidanceState, useControlNet: $useControlNet, useCannyImg2Img: $useCannyImg2Img, numImages: $numImages)
                .clearModalBackground()
                .onAppear {
                    if firstAppearance == true {
                        syncAspectRatio = true
                        firstAppearance = false
                    }
                    
                    //do this so that it isn't set to 512 X 512, but rather the actual aspect ratio.
//                    if ImagesExist(viewModel: viewModel, drawing: DrawingView.drawing) == true {
//                        currentAspectRatio(viewModel: viewModel, size: size)
//                        //heightState = closestMultipleOfEight(Double(widthState) * viewModel.aspectRatio)
//                        print("Images exist = true")
//                        if viewModel.background == nil {
//                            print("background = nil")
//                        }
//                        if DrawingView.drawing.bounds.isEmpty {
//                            print("drawing is empty")
//                        }
//                        syncAspectRatio = true
//                    } else {
//                        syncAspectRatio = false
//                    }
//
//                    viewModel.shouldBecomeFirstResponder = false
                }
                .onDisappear {
                    if viewModel.background == nil {
                        viewModel.shouldBecomeFirstResponder = true
                    }
                    showPromptView = false
                }
        }
        .sheet(isPresented: $showPaywallView) {
            Paywall()
               .clearModalBackground()
        }
    }
    
    func ImagesExist(viewModel: ViewModelClass, drawing: PKDrawing) -> Bool {
        if viewModel.background != nil || drawing.bounds.isEmpty == false {
            return false
        }
        return true
    }
    
    //MARK: Functions which should be removed from the view but I would need to pass in the DrawingView.
    //function to save the drawing to photos. NOT USED CURRENTLY- was for testing purposes.
    func saveDrawing() -> UIImage {
        // Define the dimensions of the drawing.
        let imgRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // Create an image from the drawing with a scale that controls resolution.
        let drawingImage = DrawingView.canvasView.drawing.image(from: imgRect, scale: 4.0)

        // Create an image representation of black or white background depending on system colours.
        let background = UIImage(color: colorScheme == .dark ? .black : .white, size: imgRect.size)
        
        // Begin a new image context.
        UIGraphicsBeginImageContextWithOptions(imgRect.size, false, 4.0)
        
        // Draw the black background and the drawing.
        background?.draw(in: imgRect)
        drawingImage.draw(in: imgRect)
        
        // Retrieve the combined image.
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the image context.
        UIGraphicsEndImageContext()
        
        // Save to photo library.
        if let finalImage = combinedImage {
            
            UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
            return finalImage
        }
        return UIImage()
    }
    
    func returnBase64Image(completion: @escaping () -> Void) {

        let image: UIImage
        
        //if there is a photo, use photo, otherwise use the scribble
        if viewModel.background == nil {
            //image = DrawingView.canvasView.drawing.image(from: imgRect, scale: 4.0)
            image = saveDrawing()
            preProcessor = "scribble"
        } else {
            if let compressedImage = compressImage(viewModel.background!, toByte: 256 * 256) { // for 250kb size
                //resize it so it fits the output dimensions
                let resizedImage = resizeImage(image: compressedImage, targetLength: CGFloat(max(imageHeight, imageWidth)))
                
                image = resizedImage
                //switch between canny or CannyImg2Img, or Img2Img depending on the toggle values
                //preProcessor = useControlNet ? "canny" : "img2img"
                if useControlNet == false {
                    preProcessor = "img2img"
                } else if useCannyImg2Img {
                    preProcessor = "cannyimg2img"
                } else {
                    preProcessor = "canny"
                }
                
            } else {
                // handle error, e.g., by setting image to a default value or returning
                return
            }
        }
        //DEBUG: save image here for debugging
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        let jpegData = image.jpegData(compressionQuality: 1)
        
        
        base64ImageString = (jpegData?.base64EncodedString())!
        
        completion()
        return
        
    }
    
    //for the sampler. For some reason the preview throws an error if it's not in here, but it still runs fine
    func roundToNearestHalf(number: Double) -> Double {
        return round(number * 2) / 2
    }

}
    







struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModelClass())
            .environmentObject(UserViewModel())
    }
}


