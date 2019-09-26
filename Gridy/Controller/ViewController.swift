//
//  ViewController.swift
//  Gridy
//
//  Created by Ellen Covey on 19/07/2019.
//  Copyright © 2019 Ellen Covey. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // outlets for image picking buttons
    @IBOutlet weak var pickButtonLocal: PickButton!
    @IBOutlet weak var pickButtonCamera: PickButton!
    @IBOutlet weak var pickButtonLibrary: PickButton!
    
    // actions for image picking buttons
    @IBAction func pickLocalImage(_ sender: Any) {
        pickRandom()
    }
    @IBAction func openCamera(_ sender: Any) {
        displayCamera()
    }
    @IBAction func openLibrary(_ sender: Any) {
        displayLibrary()
    }
    
    // array of all local images
    var localImages = [UIImage].init()
    
    var creationImageView: UIImageView!
    
     // default image
    var creation = Creation.init()
    
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "We don't have permission to access your camera."
            
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    }
                    else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            @unknown default:
                self.troubleAlert(message: noPermissionMessage)
            }
        }
        else {
            troubleAlert(message: "Sorry, we can't access your camera.")
        }
    }
    
    func displayLibrary() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionMessage = "We don't have permission to access your photos."
            
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    }
                    else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            @unknown default:
                self.troubleAlert(message: noPermissionMessage)
            }
        }
        else {
            troubleAlert(message: "Sorry, we can't access your photos.")
        }
        
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func troubleAlert(message: String?) {
        let alertController = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // got an image
        picker.dismiss(animated: true, completion: nil)
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        processPicked(image: newImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // cancelled
        picker.dismiss(animated: true, completion: nil)
    }
    
    func processPicked(image: UIImage?) {
        if let newImage = image {
            creation.image = newImage
            performSegue(withIdentifier: "PickedImageSegue", sender: nil)
        }
    }
    
    func pickRandom() {
        processPicked(image: randomImage())
    }
    
    // sends images to variable, called in configure func
    func collectLocalImageSet() {
        localImages.removeAll()
        let imageNames = ["pic-ben", "pic-bird", "pic-boat", "pic-icecream", "pic-road", "pic-sunset"]
        
        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImages.append(image)
            }
        }
    }
    
    // gets one random image from array
    func randomImage() -> UIImage? {
        if localImages.count > 0 {
            while true {
                let randomIndex = Int.random(in: 0 ..< localImages.count)
                let newImage = localImages[randomIndex]
                return newImage
            }
        }
        return nil
    }
    
    // called when view loads
    func configure() {
        // collect images
        collectLocalImageSet()
        
        // set images and text for image picking buttons
        pickButtonLocal.mainLabel.text = "Random"
        pickButtonLocal.mainImage.image = UIImage(named: "name-small-grey")
        pickButtonCamera.mainLabel.text = "Camera"
        pickButtonCamera.mainImage.image = UIImage(named: "icon-camera")
        pickButtonLibrary.mainLabel.text = "Library"
        pickButtonLibrary.mainImage.image = UIImage(named: "icon-library")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configure()
    }
    
    // sends chosen image to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedImageSegue"
        {
            if let destinationVC = segue.destination as? EditedImageViewController {
                destinationVC.pickedImage = creation.image
            }
        }
    }
}
