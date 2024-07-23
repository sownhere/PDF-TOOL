//
//  UIImage+Utils.swift
//  WeScan
//
//  Created by Bobo on 5/25/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    /// Draws a new cropped and scaled (zoomed in) image.
    ///
    /// - Parameters:
    ///   - point: The center of the new image.
    ///   - scaleFactor: Factor by which the image should be zoomed in.
    ///   - size: The size of the rect the image will be displayed in.
    /// - Returns: The scaled and cropped image.
    func scaledImage(atPoint point: CGPoint, scaleFactor: CGFloat, targetSize size: CGSize) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let scaledSize = CGSize(width: size.width / scaleFactor, height: size.height / scaleFactor)
        let midX = point.x - scaledSize.width / 2.0
        let midY = point.y - scaledSize.height / 2.0
        let newRect = CGRect(x: midX, y: midY, width: scaledSize.width, height: scaledSize.height)

        guard let croppedImage = cgImage.cropping(to: newRect) else {
            return nil
        }

        return UIImage(cgImage: croppedImage)
    }

    /// Scales the image to the specified size in the RGB color space.
    ///
    /// - Parameters:
    ///   - scaleFactor: Factor by which the image should be scaled.
    /// - Returns: The scaled image.
    func scaledImage(scaleFactor: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let customColorSpace = CGColorSpaceCreateDeviceRGB()

        let width = CGFloat(cgImage.width) * scaleFactor
        let height = CGFloat(cgImage.height) * scaleFactor
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let bitmapInfo = cgImage.bitmapInfo.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: customColorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }

        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        return context.makeImage().flatMap { UIImage(cgImage: $0) }
    }

    /// Returns the data for the image in the PDF format
//    func pdfData() -> Data? {
//        // Typical Letter PDF page size and margins
//        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)
//        let margin: CGFloat = 40
//
//        let imageMaxWidth = pageBounds.width - (margin * 2)
//        let imageMaxHeight = pageBounds.height - (margin * 2)
//
//        let image = scaledImage(scaleFactor: size.scaleFactor(forMaxWidth: imageMaxWidth, maxHeight: imageMaxHeight)) ?? self
//        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
//
//        let data = renderer.pdfData { ctx in
//            ctx.beginPage()
//
//            ctx.cgContext.interpolationQuality = .high
//
//            image.draw(at: CGPoint(x: margin, y: margin))
//        }
//
//        return data
//    }

    func pdfData(pageSize: CGSize = CGSize(width: 595.2, height: 841.8)) -> Data? {  // A4 size in points (1 point = 1/72 inch)
            let pdfRendererFormat = UIGraphicsPDFRendererFormat()
            let pdfRendererBounds = CGRect(origin: .zero, size: pageSize)
            let pdfRenderer = UIGraphicsPDFRenderer(bounds: pdfRendererBounds, format: pdfRendererFormat)

            let pdfData = pdfRenderer.pdfData { (context) in
                context.beginPage()
                let imageAspectRatio = self.size.width / self.size.height
                let pageAspectRatio = pageSize.width / pageSize.height
                
                var imageRectWidth: CGFloat
                var imageRectHeight: CGFloat
                
                if imageAspectRatio > pageAspectRatio {
                    // Image is more wide than the page, fit to width
                    imageRectWidth = pageSize.width
                    imageRectHeight = imageRectWidth / imageAspectRatio
                } else {
                    // Image is taller or same aspect ratio, fit to height
                    imageRectHeight = pageSize.height
                    imageRectWidth = imageRectHeight * imageAspectRatio
                }
                
                let imageRectX = (pageSize.width - imageRectWidth) / 2  // Horizontally center
                let imageRectY = (pageSize.height - imageRectHeight) / 2  // Vertically center
                let imageRect = CGRect(x: imageRectX, y: imageRectY, width: imageRectWidth, height: imageRectHeight)
                
                self.draw(in: imageRect)
            }
            return pdfData
        }
    
    /// Function gathered from [here](https://stackoverflow.com/questions/44462087/how-to-convert-a-uiimage-to-a-cvpixelbuffer)
    /// to convert UIImage to CVPixelBuffer
    ///
    /// - Returns: new [CVPixelBuffer](apple-reference-documentation://hsVf8OXaJX)
    func pixelBuffer() -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        var pixelBufferOpt: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBufferOpt
        )
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOpt else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }

        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

    /// Creates a UIImage from the specified CIImage.
    static func from(ciImage: CIImage) -> UIImage {
        if let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
        }
    }

    /// Creates UIImage from pdf page
    func fromPDF(at page: Int) -> UIImage? {
        guard let data = self.pdfData() else { return nil }
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        guard let document = CGPDFDocument(provider) else { return nil }
        guard let page = document.page(at: page) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)

        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }
    }
}
