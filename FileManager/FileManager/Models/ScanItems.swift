//
//  ScanItems.swift
//  FileManager
//
//  Created by Macbook on 10/07/2024.
//

import Foundation
import UIKit


public enum ScannedItemColorOption{
    case color
    case grayscale
}

/// Data structure containing information about one page scanned
public class ScannedItem{
    
    /// The original image taken by the user, prior to the cropping applied by WeScan.
    var originalImage:UIImage?

    /// The detected rectangle which was used to generate the `scannedImage`.
    var quad:Quadrilateral?
    
    /// The rotation applied to the resulting image
    var rotation:Double = 0.0
    
    /// The color preference for the output of this image

    
    /// The deskewed and cropped orignal image using the detected rectangle, without any filters.
    var renderedImage:UIImage? = nil

    public init(originalImage:UIImage, quad:Quadrilateral? = nil, colorOption:ScannedItemColorOption = .color) {
        self.originalImage = originalImage
        self.quad = quad

    }
    
    public func render(completion: @escaping (_ image: UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let originalImage = self.originalImage,
                  let quad = self.quad else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let processedImage = self.cropAndTransform(originalImage: originalImage, quad: quad)
            
            DispatchQueue.main.async {
                self.renderedImage = processedImage
                completion(self.renderedImage)
            }
        }
    }

    private func cropAndTransform(originalImage: UIImage, quad: Quadrilateral) -> UIImage? {
        let ciImage = CIImage(image: originalImage)
        let cgOrientation = CGImagePropertyOrientation(originalImage.imageOrientation)
        let orientedImage = ciImage!.oriented(forExifOrientation: Int32(cgOrientation.rawValue))


        // Cropped Image
        var cartesianScaledQuad = quad.toCartesian(withHeight: originalImage.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])

        let croppedImage = UIImage.from(ciImage: filteredImage)
        
        return croppedImage
    }
    
    
    func adjustImageOrientation(image: UIImage, originImage: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let orientation = originImage.imageOrientation

        switch orientation {
        case .right:
            return UIImage(cgImage: cgImage, scale: 1.0, orientation: .down)
        case .down:
            return UIImage(cgImage: cgImage, scale: 1.0, orientation: .left)
        case .left:
            return UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        default:
            return image
        }
    }

}

extension UIImage {
    func cgOrientation() -> CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
