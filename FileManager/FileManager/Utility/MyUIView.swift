//
//  MyUIView.swift
//  FileManager
//
//  Created by SownFrenky on 29/7/24.
//

import Foundation
import UIKit
import PencilKit

class MyUIView: UIView {

    var drawing: PKDrawing?
    var canvasView: PKCanvasView = PKCanvasView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCanvasView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCanvasView()
    }
    
    private func setupCanvasView() {
        canvasView.frame = bounds
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        addSubview(canvasView)
        
        // Set the tool picker
///        if let window = window, let toolPicker = PKToolPicker.shared(for: window) {
///            toolPicker.setVisible(true, forFirstResponder: canvasView)
///            toolPicker.addObserver(canvasView)
///            canvasView.becomeFirstResponder()
///        }
        MyUIViewToolPickerModel.shared.addObserverToCanvasView(canvasView, in: self)
    }
    
    func popAnnotations(to thatCanvasView: PKCanvasView) -> PKDrawing? {
//        
//        guard let annotations = drawing?.strokes else {
//            return nil
//        }
//
//        var drawing: PKDrawing?
//
//        for annotation in annotations {
//            if let base64EncodedString = annotation.contents,
//               let drawingData = Data(base64Encoded: base64EncodedString) {
//                do {
//                    let retrievedDrawing = try PKDrawing(data: drawingData)
//                    self.drawing = retrievedDrawing
//                    drawing = retrievedDrawing
//                    self.removeAnnotation(annotation)
//                } catch {
//                    print("\(#function): \(error.localizedDescription)")
//                }
//            }
//        }
//        return drawing
//    }
        guard let annotations = drawing?.strokes else {
            return nil
        }

        var drawing: PKDrawing?

//        for stroke in annotations {
//            // Assuming you have custom logic to convert stroke to a PKDrawing
//            // The following is an example, but you need to adjust according to your actual implementation
//
//            // Example of base64 string (pseudo code)
//             let base64EncodedString = customGetBase64StringFromStroke(stroke)
//
//             let drawingData = Data(base64Encoded: base64EncodedString)
//             if let drawingData {
//                 do {
//                     let retrievedDrawing = try PKDrawing(data: drawingData)
//                     self.drawing = retrievedDrawing
//                     drawing = retrievedDrawing
//                     // Here you remove the stroke from the drawing (if needed)
//                 } catch {
//                     print("\(#function): \(error.localizedDescription)")
//                 }
//             }
//        }
        
        // Apply the drawing to the provided canvas view
        thatCanvasView.drawing = drawing!
        return drawing
    }
}
