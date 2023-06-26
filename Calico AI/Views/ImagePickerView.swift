//
//  ImagePickerView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    
    typealias UIViewControllerType = UIImagePickerController
    
    //binding Vars
    @Binding var isImagePickerPresented: Bool
    let viewModel: ViewModelClass
    
    init(isImagePickerPresented: Binding<Bool>, viewModel: ViewModelClass) {
        _isImagePickerPresented = isImagePickerPresented
        self.viewModel = viewModel
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isImagePickerPresented: $isImagePickerPresented, viewModel: viewModel)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary //if is using camera = true, open the camera.
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //do nothing
    }
    
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //isShown stuff is so the cancel button works
    @Binding var isImagePickerPresented: Bool
    let viewModel: ViewModelClass
    
    
    init(isImagePickerPresented: Binding<Bool>, viewModel: ViewModelClass) {
            _isImagePickerPresented = isImagePickerPresented
            self.viewModel = viewModel
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //user cancelled
        withAnimation(.easeInOut(duration: 0.5)) {
            isImagePickerPresented = false
            //check if there's a background image. if there isn't, make canvasview the first responder
            if viewModel.background == nil {
                viewModel.shouldBecomeFirstResponder = true
            }
            
            //print(viewModel.background ?? "nil")
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let uiimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        viewModel.shouldBecomeFirstResponder = false
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.background = uiimage
            isImagePickerPresented = false
            
        }
        currentAspectRatio(viewModel: viewModel, size: CGSize(width: 256, height: 256))
        
    }
}


