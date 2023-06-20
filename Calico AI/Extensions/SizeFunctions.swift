//
//  SizeFunctions.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import Foundation
import SwiftUI

//MARK: View Size Calculator
//Can be used on any view by adding .saveSize to a State variable in the parent view
struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

//MARK: make a number divisible by 8

func closestMultipleOfEight(_ value: Double) -> Int {
    let value = Int(round(value))
    let remainder = value % 8
    if remainder < 4 {
        return value - remainder
    } else {
        return value + (8 - remainder)
    }
}


//get the current aspect ratio of either the image or the canvas, depending on which is active.
func currentAspectRatio(viewModel: ViewModelClass, size: CGSize) {
    let width: Double
    let height: Double
    
    if viewModel.background == nil {
        width = Double(size.width)
        height = Double(size.height)

    } else {
        width = Double((viewModel.background?.size.width)!)
        height = Double((viewModel.background?.size.height)!)
        print("width: \(width)")
        print("height \(height)")
    }
    
    //this if statement is basically to set aspect ratio depending on portrait or landscape mode.
    if (height >= width) {
        viewModel.aspectRatio = height / width
        print("aspect ratio = height / width \(height / width)")
    } else {
        viewModel.aspectRatio = height / width
        print("aspect ratio = width / height \(height / width)")
    }
   
}
