//
//  DrawingView.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-09.
//

import SwiftUI
import PencilKit

struct DrawingView: View {
    @EnvironmentObject var viewModel: ViewModelClass
    var body: some View {
       DrawingView_UIView()
        
    }
}

struct DrawingView_UIView: UIViewRepresentable {
    @EnvironmentObject var viewModel: ViewModelClass
    
    let canvasView = PKCanvasView()
    
    let picker = PKToolPicker()
    let drawing = PKDrawing()
    
    
    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.tool = PKInkingTool(.pen, color: .red, width: 15)
       // self.canvasView.becomeFirstResponder()
        self.canvasView.drawing = drawing
       // self.canvasView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))) //just for tool picker to appear
       // self.canvasView.delegate = context.coordinator
        self.canvasView.drawingPolicy = .anyInput
        
        self.canvasView.backgroundColor = .white
        
        picker.addObserver(canvasView)
        picker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
        return canvasView
    }
    
    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        picker.addObserver(canvasView)
        picker.setVisible(true, forFirstResponder: canvasView)
        
        //from chatGPT
        if viewModel.shouldBecomeFirstResponder == true {
            DispatchQueue.main.async {
                canvasView.becomeFirstResponder()
                DispatchQueue.main.async {
                    canvasView.tool = picker.selectedTool
                }
            }
        } else {
            DispatchQueue.main.async {
                canvasView.resignFirstResponder()
            }
        }


    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView()
            .environmentObject(ViewModelClass())
    }
}
