//
//  PickButton.swift
//  Gridy
//
//  Created by Ellen Covey on 19/07/2019.
//  Copyright © 2019 Ellen Covey. All rights reserved.
//

import UIKit

// custom rounded button with icon and label
class PickButton: UIButton {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    // initialising
    override init(frame: CGRect) { // for using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PickButton", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.cornerRadius = 10
    }

}
