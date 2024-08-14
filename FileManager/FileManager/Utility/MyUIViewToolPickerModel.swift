//
//  MyUIViewToolPickerModel.swift
//  FileManager
//
//  Created by SownFrenky on 29/7/24.
//

import Foundation
import PencilKit
import UIKit

class MyUIViewToolPickerModel: NSObject {
    
    let toolPicker = PKToolPicker()
        
    static let shared = MyUIViewToolPickerModel()
    
    override init() {
        super.init()
        self.setToolToYellowHighlighter()
    }
    
    func setToolToYellowHighlighter() {
        let highlighterYellowColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.7)
        self.toolPicker.selectedTool = PKInkingTool(.marker, color: highlighterYellowColor, width: 25.0)
    }
    
    func addObserverToCanvasView(_ canvasView: PKCanvasView, in view: UIView) {
        if let window = view.window {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }
}
