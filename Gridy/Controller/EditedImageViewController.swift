//
//  EditedImageViewController.swift
//  Gridy
//
//  Created by Ellen Covey on 22/07/2019.
//  Copyright © 2019 Ellen Covey. All rights reserved.
//

import UIKit
import CoreImage

class EditedImageViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var chosenImageContainer: UIView!
    @IBOutlet weak var chosenImageView: UIImageView!
    @IBOutlet weak var startButton: RoundButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBAction func start(_ sender: Any) {
        print("Start")
    }
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // placeholder for user-chosen image
    var pickedImage = UIImage(named: "pic-ben")
    
    var initialImageViewOffset = CGPoint()
    
    // blur background image
    var context = CIContext(options: nil)
    
    func blurEffect() {
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: backgroundImage.image!)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        backgroundImage.image = processedImage
    }
    
    // to edit image - pan, rotate, scale within container
    func configureGestures() {
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
        panGestureRecognizer.delegate = self
        chosenImageView.addGestureRecognizer(panGestureRecognizer)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
        rotationGestureRecognizer.delegate = self
        chosenImageView.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
        pinchGestureRecognizer.delegate = self
        chosenImageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func moveImageView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: chosenImageView.superview)
        
        if sender.state == .began {
            initialImageViewOffset = chosenImageView.frame.origin
        }
        
        let position = CGPoint(x: translation.x + initialImageViewOffset.x - chosenImageView.frame.origin.x, y: translation.y + initialImageViewOffset.y - chosenImageView.frame.origin.y)
        
        chosenImageView.transform = chosenImageView.transform.translatedBy(x: position.x, y: position.y)
    }
    
    @objc func rotateImageView(_ sender: UIRotationGestureRecognizer) {
        chosenImageView.transform = chosenImageView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    @objc func scaleImageView(_ sender: UIPinchGestureRecognizer) {
        chosenImageView.transform = chosenImageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    // for allowing simultaneous rotate and scale edits
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // simultaneous gesture recognition will only be supported for creationImageView
        if gestureRecognizer.view != chosenImageView {
            return false
        }
        
        // neither of the recognised gestured should be tap
        // no simultaneous panning with scaling or rotating
        if gestureRecognizer is UITapGestureRecognizer
            || otherGestureRecognizer is UITapGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
            || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        
        return true
        
    }
    
    func composeCreationImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(chosenImageContainer.bounds.size, false, 0)
        chosenImageContainer.drawHierarchy(in: chosenImageContainer.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chosenImageView.image = pickedImage
        backgroundImage.image = pickedImage
        blurEffect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureGestures()
    }
    
    // sends edited image to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageToPuzzleSegue"
        {
            if let destinationVC = segue.destination as? PuzzleViewController {
                let screenshot = composeCreationImage()
                destinationVC.editedImage = screenshot
            }
        }
    }

}

