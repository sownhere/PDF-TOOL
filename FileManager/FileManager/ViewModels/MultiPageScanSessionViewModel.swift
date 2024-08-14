//
//  MultiPageScanSessionViewModel.swift
//  FileManager
//
//  Created by Macbook on 10/07/2024.
//

import Foundation
import UIKit

public class MultiPageScanSessionViewModel {
    
    public var imageScannerResults:Array<ImageScannerResults> = []
    
    public init(images:[UIImage]? = nil){
        if let images {
            for image in images {
                let imageScan = ImageScannerScan(image: image)
                detect(image: image) {
                    [weak self] quad in
                    
                    if let quad = quad {
                        let enhancedImageScan = ImageScannerScan(image: (CIImage(image: image)?.applyingAdaptiveThreshold())!)
                        let croppedImage = ImageScannerScan(image: self!.croppedImage(for: quad , in: image)!)
                        let imageScannerResult = ImageScannerResults(detectedRectangle: quad, originalScan: imageScan, croppedScan: croppedImage, enhancedScan: enhancedImageScan)
                        self!.imageScannerResults.append(imageScannerResult)
                    } else {
                        let enhancedImageScan = ImageScannerScan(image: (CIImage(image: image)?.applyingAdaptiveThreshold())!)
                        let quad = self!.defaultQuad(allOfImage: image)
                        let croppedImage = ImageScannerScan(image: self!.croppedImage(for: quad , in: image)!)
                        let imageScannerResult = ImageScannerResults(detectedRectangle: quad, originalScan: imageScan, croppedScan: croppedImage, enhancedScan: enhancedImageScan)
                        self!.imageScannerResults.append(imageScannerResult)
                    }
                    
                    
                }
                
            }
            
        }
    }
    
    public func updateImageScannerResult(at index: Int, with result: ImageScannerResults) {
            if index >= 0 && index < imageScannerResults.count {
                imageScannerResults[index] = result
            }
        }
    
    public func add(detectedRectangle: Quadrilateral, originalScan: ImageScannerScan, croppedScan: ImageScannerScan, enhancedScan: ImageScannerScan?){
        let item = ImageScannerResults(detectedRectangle: detectedRectangle, originalScan: originalScan, croppedScan: croppedScan, enhancedScan: enhancedScan)
        
        
        self.imageScannerResults.append(item)
    }
    
    public func add(image: UIImage, quad: Quadrilateral?) {
        let imageScan = ImageScannerScan(image: image)
        if let quad = quad {
            let croppedImage = ImageScannerScan(image: croppedImage(for: quad , in: image)!)
            var imageScannerResult = ImageScannerResults(detectedRectangle: quad, originalScan: imageScan, croppedScan: croppedImage, enhancedScan: nil)
            imageScannerResults.append(imageScannerResult)
        } else {
            let quad = defaultQuad(allOfImage: image)
            let croppedImage = ImageScannerScan(image: croppedImage(for: quad , in: image)!)
            var imageScannerResult = ImageScannerResults(detectedRectangle: quad, originalScan: imageScan, croppedScan: croppedImage, enhancedScan: nil)
            imageScannerResults.append(imageScannerResult)

        }

    }
    

    public func remove(index:Int){
        self.imageScannerResults.remove(at: index)
    }
    
    
    public func detect(image: UIImage, completion: @escaping (Quadrilateral?) -> Void) {
        // Whether or not we detect a quad, present the edit view controller after attempting to detect a quad.
        // *** Vision *requires* a completion block to detect rectangles, but it's instant.
        // *** When using Vision, we'll present the normal edit view controller first, then present the updated edit view controller later.
        
        guard let ciImage = CIImage(image: image) else { return }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))
        
        if #available(iOS 11.0, *) {
            // Use the VisionRectangleDetector on iOS 11 to attempt to find a rectangle from the initial image.
            VisionRectangleDetector.rectangle(forImage: ciImage, orientation: orientation) { quad in
                let detectedQuad = quad?.toCartesian(withHeight: orientedImage.extent.height)
                completion(detectedQuad)
            }
        } else {
            // Use the CIRectangleDetector on iOS 10 to attempt to find a rectangle from the initial image.
            let detectedQuad = CIRectangleDetector.rectangle(forImage: ciImage)?.toCartesian(withHeight: orientedImage.extent.height)
            completion(detectedQuad)
        }
    }
    
    public func defaultQuad(allOfImage image: UIImage, withOffset offset: CGFloat = 75) -> Quadrilateral {
        let topLeft = CGPoint(x: offset, y: offset)
        let topRight = CGPoint(x: image.size.width - offset, y: offset)
        let bottomRight = CGPoint(x: image.size.width - offset, y: image.size.height - offset)
        let bottomLeft = CGPoint(x: offset, y: image.size.height - offset)
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        return quad
    }
    
    public func croppedImage(for quad: Quadrilateral, in image: UIImage) -> UIImage? {
        
        let ciImage = CIImage(image: image)
        
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage?.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        
        
        // Cropped Image
        var cartesianScaledQuad = quad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage!.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        
        let croppedImage = UIImage.from(ciImage: filteredImage)
        return croppedImage
        
    }
}

