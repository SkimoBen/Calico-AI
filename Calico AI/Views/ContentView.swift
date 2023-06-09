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
    
    @State var DrawingView = DrawingView_UIView()
    @State var size: CGSize = .zero //size of canvas
    @State var showPromptView = false //
    @State var showPlayModalView = true
    @State var syncAspectRatio = true
    
    //for the API image
    @State var generatedImage: UIImage? = nil
    @State var generationFailure: String = ""
    @State private var updateView = false //workaround for button tap bug
    //For the popup
    @State private var showingAlert = false
    @State private var showAIGenerationView = false
    @State var isImagePickerPresented = false
    
    //---AI variables
    @State var positivePromptState = ""
    @State var negativePromptState = ""
    @State var widthState = 512
    @State var heightState = 512
    @State var samplesState: Double = 30
    @State var guidanceState: Double = 7.5
    @State var seedState = "0"
    


    var body: some View {
        
        ZStack {
            VStack {
                
                TopBarView(showPromptView: $showPromptView, isImagePickerPresented: $isImagePickerPresented, showingAlert: $showingAlert, updateView: $updateView)
                
                
                Spacer()
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
//                            if viewModel.background != nil || DrawingView.canvasView.drawing.bounds.isEmpty == false {
//                                currentAspectRatio(viewModel: viewModel, size: size)
//                            }
                            if AreImagesEmpty(viewModel: viewModel, drawing: DrawingView.drawing) == true {
                                currentAspectRatio(viewModel: viewModel, size: size)
                                syncAspectRatio = true
                            } else {
                                syncAspectRatio = false
                            }
                            
                            
                        }
                }
            }
            if (isImagePickerPresented) {
                ImagePicker(isImagePickerPresented: $isImagePickerPresented, viewModel: viewModel)
                    
            }
        }
        .onAppear {
            // viewModel.background = nil
        }
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
                
                //this is to switch pipelines if there's no image input for control net
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
        .fullScreenCover(isPresented: $showAIGenerationView) {
            AIGenerationView(image: $generatedImage, failure: $generationFailure).onAppear {
                sendIt(completion: { (image) in
                    self.generatedImage = image
                }, failure: { (error) in
                    withAnimation {
                        self.generationFailure = error
                    }
                    
                })
            }
        }

            .sheet(isPresented: $showPromptView) {
                PromptView(syncAspectRatio: $syncAspectRatio, positivePromptState: $positivePromptState, negativePromptState: $negativePromptState, widthState: $widthState, heightState: $heightState, samplesState: $samplesState, guidanceState: $guidanceState, seedState: $seedState)
                    .clearModalBackground()
                    .onAppear {
                        //do this so that it isn't set to 512 X 512, but rather the actual aspect ratio.
                        if AreImagesEmpty(viewModel: viewModel, drawing: DrawingView.drawing) == true {
                            currentAspectRatio(viewModel: viewModel, size: size)
                            //heightState = closestMultipleOfEight(Double(widthState) * viewModel.aspectRatio)
                    
                        } else {
                            syncAspectRatio = false
                        }
                        
                        viewModel.shouldBecomeFirstResponder = false
                    }
                    .onDisappear {
                        if viewModel.background == nil {
                            viewModel.shouldBecomeFirstResponder = true
                        }
                    }
            }
        
    }
    
    func AreImagesEmpty(viewModel: ViewModelClass, drawing: PKDrawing) -> Bool {
        if viewModel.background != nil || drawing.bounds.isEmpty == false {
            return false
        }
        return true
    }
    
    //Functions which should be removed from the view but I would need to pass in the DrawingView.
    //function to save the drawing to photos
    func saveDrawing() {
        //define the dimensions of the drawing.
        let imgRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        //create image from the drawing, scale controls resolution.
        let image = DrawingView.canvasView.drawing.image(from: imgRect, scale: 4.0)
        //save to photo library
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func returnBase64Image(completion: @escaping () -> Void) {
        //define the dimensions of the drawing.
        let imgRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let image: UIImage
        
        //if there is a photo, use photo, otherwise use the scribble
        if viewModel.background == nil {
            image = DrawingView.canvasView.drawing.image(from: imgRect, scale: 4.0)
            preProcessor = "scribble"
        } else {
            if let compressedImage = compressImage(viewModel.background!, toByte: 256 * 256) { // for 250kb size
                //resize it so it fits the output dimensions
                let resizedImage = resizeImage(image: compressedImage, targetLength: CGFloat(max(imageHeight, imageWidth)))
                
                image = resizedImage
                preProcessor = "canny"
            } else {
                // handle error, e.g., by setting image to a default value or returning
                return
            }
        }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
    

struct TopBarView: View {
    @Binding var showPromptView: Bool
    @EnvironmentObject var viewModel: ViewModelClass
    @Binding var isImagePickerPresented: Bool
    @Binding var showingAlert: Bool
    @Binding var updateView: Bool
    var body: some View {
        HStack {
            //PromptView button
            Button(action: {
                showPromptView.toggle()
            }, label: {
        
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30)
                    .padding(.leading, 40)
        
            })
            Spacer()
            
            //Play button for image generation
            Button(action: {
                showingAlert = true
            }, label: {
        
                Image(systemName: "play")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 30)
                    .padding(.leading, 15)
        
            })
            
            Spacer()
            //Pencil menue view for sketch vs image picker
            Menu {
                PencilMenuView(showingAlert: $showingAlert, isImagePickerPresented: $isImagePickerPresented)
            }label: {
                Image(systemName: "pencil.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 40)
            }
            
        }
        
    }
}


struct PencilMenuView: View {
    @Binding var showingAlert: Bool
    @EnvironmentObject var viewModel: ViewModelClass
    @Binding var isImagePickerPresented: Bool
    
    var body: some View {
        
        Button(action: {
            withAnimation {
                viewModel.shouldBecomeFirstResponder = true
                viewModel.background = nil
            }
        }, label: {
            HStack {
                Text("Generate image from sketch")
                Image(systemName: "scribble")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }

        })
        
        Button(action: {
            //upload a photo from camera roll
            withAnimation {
                viewModel.shouldBecomeFirstResponder = false
                isImagePickerPresented = true
            }
        }, label: {
            HStack {
                Text("Upload your own photo")
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            
        })
        
        Button(action: {
            
           var image: UIImage
            if viewModel.background == nil {
               print("no pixxx")
                preProcessor = "scribble"
            } else {
                if let compressedImage = compressImage(viewModel.background!, toByte: 256 * 256) { // for 250kb size
                    //resize it so it fits the output dimensions
                    print("max size: \(max(imageHeight, imageWidth))")
                    let resizedImage = resizeImage(image: compressedImage, targetLength: CGFloat(max(imageHeight, imageWidth)))
                    
                    image = resizedImage
                    preProcessor = "canny"
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } else {
                    // handle error, e.g., by setting image to a default value or returning
                    return
                }
            }
            
        }, label: {
            Text("Resize Image")
        })
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModelClass())
    }
}
