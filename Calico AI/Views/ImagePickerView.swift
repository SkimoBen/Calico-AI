//
//  ImagePickerView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI

//struct ImagePickerView: View {
//    var body: some View {
//        ImagePicker(isImagePickerPresented: )
//    }
//}

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
            
            print(viewModel.background ?? "nil")
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
        
    }
}

//struct ImagePicker: UIViewControllerRepresentable {
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    var completionHandler: ((UIImage) -> Void)? = nil
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        var completionHandler: ((UIImage) -> Void)? = nil
//
//        init(completionHandler: ((UIImage) -> Void)?) {
//            self.completionHandler = completionHandler
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                print("Image selected: \(uiImage)") // Debug print
//                completionHandler?(uiImage)
//            }
//            picker.dismiss(animated: true)
//        }
//
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            picker.dismiss(animated: true)
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(completionHandler: completionHandler)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.sourceType = sourceType
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
//    }
//}


//struct ImagePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerView()
//    }
//}
