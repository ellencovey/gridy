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
    
    //converts UIView to UIImage
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
    //splits image into pieces
    func splitImage(_ gridDimension: Int) -> [UIImage] {
        let y = scale * (size.height / CGFloat(gridDimension))
        let x = scale * (size.width / CGFloat(gridDimension))
        var images = [UIImage]()
        images.reserveCapacity(gridDimension * gridDimension)
        guard let cgImage = cgImage else { return [] }
        
        (0..<gridDimension).forEach { row in
            (0..<gridDimension).forEach { column in
                var width = Int(x)
                var height = Int(y)
                if row == gridDimension-1 && size.height.truncatingRemainder(dividingBy: CGFloat(gridDimension)) != 0 {
                    height = Int(scale * (size.height - size.height / CGFloat(gridDimension) * (CGFloat(gridDimension)-1)))
                }
                if column == gridDimension-1 && size.width.truncatingRemainder(dividingBy: CGFloat(gridDimension)) != 0 {
                    width = Int(scale * (size.width - (size.width / CGFloat(gridDimension) * (CGFloat(gridDimension)-1))))
                }
                if let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: column * Int(x), y:  row * Int(x)), size: CGSize(width: width, height: height))) {
                    images.append(UIImage(cgImage: image, scale: scale, orientation: imageOrientation))
                }
            }
        }
        return images
    }
    
}
