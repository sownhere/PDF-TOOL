//
//  ScannerManager.swift
//  FileManager
//
//  Created by Macbook on 09/07/2024.
//

import Foundation
import UIKit


class ScannerManager {
    
    static let share =  ScannerManager()
    
    private init() {}
    
    var imageScans: [UIImage] = []
    var quads: [Quadrilateral] = []
    
    
}
