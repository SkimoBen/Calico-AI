//
//  Extensions.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import Foundation
import SwiftUI


func ChooseEndpoint(preProcessor: String) -> String {
    let cerebriumPart1 = "https://run.cerebrium.ai/v2/p-2f24fdd5/cerebriumpart1/predict"
    let cerebriumPart2 = "https://run.cerebrium.ai/v2/p-2f24fdd5/cerebriumpart2/predict"
    
    switch preProcessor {
    case "canny":
        return cerebriumPart1
    case "cannyimg2img":
        return cerebriumPart1
    case "img2img":
        return cerebriumPart2
    case "txt2img":
        return cerebriumPart2
    case "scribble2img":
        return cerebriumPart2
    default:
        return cerebriumPart2 //shouldnt ever fail since it would default to txt2img in Cerebrium.
    }
    
}


//MARK: Code snippet to make clear sheet backgrounds


struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct ClearBackgroundViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .background(ClearBackgroundView())
    }
}

extension View {
    func clearModalBackground()->some View {
        self.modifier(ClearBackgroundViewModifier())
    }
}

//Make the keyboard disappear on tap
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//Get the size of the keyboard
//not currently in use
//TO USE:
//@ObservedObject private var keyboard = KeyboardResponder()
//.padding(.bottom, keyboard.currentHeight)
class KeyboardResponder: ObservableObject {
    @Published private(set) var currentHeight: CGFloat = 0

    var _center: NotificationCenter

    init(center: NotificationCenter = .default) {
        _center = center
        _center.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        _center.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            currentHeight = keyboardSize.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        currentHeight = 0
    }
}

//MARK: image compressor; It compresses the image without changing the dimensions
func compressImage(_ image: UIImage, toByte maxSize: Int) -> UIImage? {
    var compression: CGFloat = 1.0
    let maxByte = maxSize
    var imageData = image.jpegData(compressionQuality: compression)
    
    while((imageData?.count ?? 0) > maxByte && compression > 0.01) {
        compression -= 0.05
        imageData = image.jpegData(compressionQuality: compression)
    }
    
    var compressedImage: UIImage? = nil
    if let data = imageData {
        compressedImage = UIImage(data: data)
    }
    
    return compressedImage
}

//This one resizes the dimensions without changing the aspect ratio. Target length is the largest side you want
func resizeImage(image: UIImage, targetLength: CGFloat) -> UIImage {
    let scale = UIScreen.main.scale
    let targetLengthInPoints = targetLength / scale
    
    let originalSize = image.size
    let maxDimension = max(originalSize.width, originalSize.height)
    
    if maxDimension <= targetLengthInPoints {
        // If the image is smaller than the target size, return the original image
        return image
    }
    
    var targetSize: CGSize
    if originalSize.width > originalSize.height {
        // If width is greater, scale height proportionally
        let scaleFactor = targetLengthInPoints / originalSize.width
        targetSize = CGSize(width: targetLengthInPoints, height: originalSize.height * scaleFactor)
    } else {
        // If height is greater or equal, scale width proportionally
        let scaleFactor = targetLengthInPoints / originalSize.height
        targetSize = CGSize(width: originalSize.width * scaleFactor, height: targetLengthInPoints)
    }
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    print("target size: \(targetSize)")
    let resizedImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
    
    return resizedImage
}

//use for delays
func delay(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}



//This one resizes the dimensions without changing the aspect ratio. Target length is the largest side you want
//func resizeImage(image: UIImage, targetLength: CGFloat) -> UIImage {
//    let originalSize = image.size
//    let maxDimension = max(originalSize.width, originalSize.height)
//
//    if maxDimension <= targetLength {
//        // If the image is smaller than the target size, return the original image
//        return image
//    }
//
//    var targetSize: CGSize
//    if originalSize.width > originalSize.height {
//        // If width is greater, scale height proportionally
//        let scaleFactor = targetLength / originalSize.width
//        targetSize = CGSize(width: targetLength, height: originalSize.height * scaleFactor)
//    } else {
//        // If height is greater or equal, scale width proportionally
//        let scaleFactor = targetLength / originalSize.height
//        targetSize = CGSize(width: originalSize.width * scaleFactor, height: targetLength)
//    }
//
//    let renderer = UIGraphicsImageRenderer(size: targetSize)
//    print("target size: \(targetSize)")
//    let resizedImage = renderer.image { _ in
//        image.draw(in: CGRect(origin: .zero, size: targetSize))
//    }
//
//    return resizedImage
//}
