//
//  Creation.swift
//  Gridy
//
//  Created by Ellen Covey on 22/07/2019.
//  Copyright © 2019 Ellen Covey. All rights reserved.
//

import Foundation
import UIKit

class Creation {
    var image: UIImage
    
    static var defaultImage: UIImage {
        return UIImage.init(named: "pic-ben")!
    }
    
    init() { // stored property initialisation
        image = Creation.defaultImage
    }
    
    
    
}
