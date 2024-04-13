//
//  HomeViewController.swift
//  Assignment
//
//  Created by My Mac on 13/04/24.
//

import UIKit
import AVFoundation
class HomeViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        checkCameraPermission()
    }
    

    @IBAction func openCameraBtnAction(_ sender: Any) {
        if getCameraPermissiontouchBool(){
            
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {

                                
                imagePicker.sourceType = .savedPhotosAlbum;
                imagePicker.allowsEditing = false
                
                self.present(imagePicker, animated: true, completion: nil)
                          
            } else {
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true // Optional: Set to true if you want to allow editing
                present(imagePicker, animated: true, completion: nil)
            }
        }else{
            self.showPermissionDeniedAlert()
        }
    }
    
    @IBAction func editImageBtnAction(_ sender: Any) {
        
        guard let image = imgView.image else { return }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "FilterViewController" ) as! FilterViewController
        vc.CapturedImage = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
  
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // Camera access is authorized
            print("Camera access authorized")
            setCameraPermissiontouchBool(bool:true)
        case .notDetermined:
            // Request camera access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // Camera access granted by the user
                    print("Camera access granted")
                    setCameraPermissiontouchBool(bool:true)
                } else {
                    // Camera access denied by the user
                    setCameraPermissiontouchBool(bool:false)
                    DispatchQueue.main.async {
                        self.showPermissionDeniedAlert()
                    }
                   
                    print("Camera access denied")
                }
            }
        case .denied, .restricted:
            // Camera access is denied or restricted
            print("Camera access denied or restricted")
            setCameraPermissiontouchBool(bool:false)
            DispatchQueue.main.async {
                self.showPermissionDeniedAlert()
            }
           
        @unknown default:
            print("Unknown camera authorization status")
        }
    }
    
    func showPermissionDeniedAlert() {
            let alert = UIAlertController(title: "Camera Access Denied",
                                          message: "Please allow access to the camera in Settings to continue.",
                                          preferredStyle: .alert)
            
            // Add action to navigate to Settings
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            alert.addAction(settingsAction)
            
            // Add cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            imgView.image = pickedImage
        } else if let pickedImage = info[.originalImage] as? UIImage {
            imgView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
