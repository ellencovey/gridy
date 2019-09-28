//
//  WinViewController.swift
//  Gridy
//
//  Created by Ellen Covey on 27/09/2019.
//  Copyright © 2019 Ellen Covey. All rights reserved.
//

import Foundation
import UIKit

class WinViewController: UIViewController {
    
    @IBOutlet weak var winImage: UIImageView!
    @IBOutlet weak var winMoves: UILabel!
    @IBAction func share(_ sender: Any) {
        displaySharingOptions()
    }
    
    var fullImage: UIImage?
    var finalMoves = 0
    
    // sharing configuration
    func displaySharingOptions() {
        // prepare content to share
        let note = "I completed my puzzle in only \(finalMoves) moves!"
        let image = fullImage
        let items = [image as Any, note as Any]
        
        // create activity view controller
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        
        // present activity view controller
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        winImage.image = fullImage
        winMoves.text = String(finalMoves)
        
    }
    
}
