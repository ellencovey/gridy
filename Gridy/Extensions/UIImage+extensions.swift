//
//  UIImage+extensions.swift
//  Gridy
//
//  Created by Ellen Covey on 31/07/2019.
//  Copyright © 2019 Ellen Covey. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func slice(into howMany: Int) -> [UIImage] {
        let width: CGFloat
        let height: CGFloat
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            width = self.size.height
            height = self.size.width
        default:
            width = self.size.width
            height = self.size.height
        }
        
        let tileWidth = Int(width / CGFloat(howMany))
        let tileHeight = Int(height / CGFloat(howMany))
        
        let scale = Int(self.scale)
        var images = [UIImage]()
        let cgImage = self.cgImage!
        
        var adjustedHeight = tileHeight
        
        var y = 0
        for row in 0 ..< howMany {
            if row == (howMany - 1) {
                adjustedHeight = Int(height) - y
            }
            var adjustedWidth = tileWidth
            var x = 0
            for column in 0 ..< howMany {
                if column == (howMany - 1) {
                    adjustedWidth = Int(width) - x
                }
                let origin = CGPoint(x: x * scale, y: y * scale)
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
                let tileCGImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                images.append(UIImage(cgImage: tileCGImage, scale: self.scale, orientation: self.imageOrientation))
                x += tileWidth
            }
            y += tileHeight
        }
        print("SlicingDone")
        return images
    }
    
}
