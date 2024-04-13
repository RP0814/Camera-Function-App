//
//  FilterViewController.swift
//  Assignment
//
//  Created by My Mac on 13/04/24.
//

import UIKit
enum Subviews {
    case Caption, CapturedImage, Overlay
}

class FilterViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
     
    var originalImage = UIImage() 
    let textField  = UITextView(frame: CGRect(x: 5, y: 5, width: 100, height: 50))
    let overlayImg = UIImageView(frame: CGRect(x: 100, y: 200, width: 50, height: 50))
    var isAddingOverlay = false
    var imagePicker = UIImagePickerController()
    var backGroundImd =  UIImage()
    fileprivate let filterNameList = [
        "No Filter",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectProcess",

   ]
    
    fileprivate let filterDisplayNameList = [
        "Normal",
        "Chrome",
        "Fade",
        "Instant",
        "Process",
    ]
    fileprivate var smallImage: UIImage?
    fileprivate var filterIndex = 0
    var CapturedImage = UIImage()
    fileprivate let context = CIContext(options: nil)
    
    fileprivate let overlayNameList = ["Rocket","Coffee","Girl","Music"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imgView.image = CapturedImage
        smallImage = CapturedImage
    }
     
    @IBAction func backBtnAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        guard let image = imgView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // Called when image save is complete (with error or not)
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("ERROR: \(error)")
        }
        else {
            self.showAlert("Image saved", message: "The iamge is saved into your Photo Library.")
        }
    }
    /// Show popup with title and message
    /// - Parameters:
    ///   - title: the title
    ///   - message: the message
    private func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addText(_ sender: Any) {
        guard imgView.image != nil else { return }
      
        textField.backgroundColor = .clear
        textField.text = "Enter capction"
        textField.textColor = .red
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.red.cgColor
        textField.delegate = self
        imgView.addSubview(textField)
        imgView.isUserInteractionEnabled = true
        addGesture(type: .Caption)
        
    }
    @IBAction func btnOverlayClicked(_ sender: Any) {
        isAddingOverlay = true
        filterCollectionView.reloadData()
    }
    @IBAction func btnFilterClicked(_ sender: Any) {
        isAddingOverlay = false
        filterCollectionView.reloadData()
    }
    @IBAction func btnAddBGClicked(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum;
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
}
  
//MARK: - BG
extension FilterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {
            backGroundImd = pickedImage
        }
        dismiss(animated: true, completion: nil)
        imgView.image = UIImage.imageByMergingImages(topImage: imgView.image!, bottomImage: backGroundImd )
    }
}

extension FilterViewController: UIGestureRecognizerDelegate {
    
    func addGesture(type:Subviews) {
        
        //add pan gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        
        //add pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
         
        //add rotate gesture.
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
          
        switch type {
        case .Caption:
            textField.addGestureRecognizer(gestureRecognizer)
            textField.isUserInteractionEnabled = true
            textField.isMultipleTouchEnabled = true
            textField.addGestureRecognizer(pinchGesture)
            textField.addGestureRecognizer(rotate)
            return
        case .CapturedImage:
            imgView.addGestureRecognizer(gestureRecognizer)
            imgView.isUserInteractionEnabled = true
            imgView.isMultipleTouchEnabled = true
            imgView.addGestureRecognizer(pinchGesture)
            imgView.addGestureRecognizer(rotate)
            return
        case .Overlay:
            overlayImg.addGestureRecognizer(gestureRecognizer)
            overlayImg.isUserInteractionEnabled = true
            overlayImg.isMultipleTouchEnabled = true
            overlayImg.addGestureRecognizer(pinchGesture)
            overlayImg.addGestureRecognizer(rotate)
            return
        }
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            // note: 'view' is optional and need to be unwrapped
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        if let view = pinch.view {
            view.transform = view.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
    }
    
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    //MARK:- UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}

extension FilterViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension FilterViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isAddingOverlay ? overlayNameList.count : filterDisplayNameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        
        if isAddingOverlay {
            cell.imgView.image = UIImage(named: overlayNameList[indexPath.row] + ".png")
            cell.filterNameLabel.text = overlayNameList[indexPath.row]
        } else {
            var filteredImage = smallImage
            if indexPath.row != 0 {
                filteredImage = createFilteredImage(filterName: filterNameList[indexPath.row], image: smallImage!)
            }
            if indexPath.row == filterIndex{
                cell.filterNameLabel.textColor = UIColor(named: "9315FF")
            }else{
                cell.filterNameLabel.textColor = UIColor.black
            }
            cell.imgView.image = filteredImage
            cell.filterNameLabel.text = filterDisplayNameList[indexPath.row]
        }
        cell.imgView.layer.borderColor = UIColor.lightGray.cgColor
        cell.imgView.layer.borderWidth = 1
        cell.imgView.layer.cornerRadius = 5
        cell.imgView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAddingOverlay {
           
            overlayImg.image = UIImage(named: overlayNameList[indexPath.row] + ".png")
            
            imgView.addSubview(overlayImg)
            imgView.isUserInteractionEnabled = true
            addGesture(type: .Overlay)
        } else {
            filterIndex = indexPath.row
            if filterIndex != 0 {
                let filterName = filterNameList[filterIndex]
                imgView.image = createFilteredImage(filterName: filterName, image: CapturedImage)
            } else {
                imgView.image = CapturedImage
                
            }
            filterCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize  {
        return CGSize(width: 80, height: 80)
    }
    
    func createFilteredImage(filterName: String, image: UIImage) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!)
        
        //filteredImage = UIImage(cgImage: newImage as! CGImage)
        return filteredImage
    }
    
}

extension UIImage {

    static func imageByMergingImages(topImage: UIImage, bottomImage: UIImage, scaleForTop: CGFloat = 1.0) -> UIImage {
        let size = bottomImage.size
        let container = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        UIGraphicsGetCurrentContext()!.interpolationQuality = .high
        bottomImage.draw(in: container)

        let topWidth = (size.width / scaleForTop) - 40
        let topHeight = (size.height / scaleForTop) -  100
        let topX = (size.width / 2.0) - (topWidth / 2.0)
        let topY = (size.height / 2.0) - (topHeight / 2.0)

        topImage.draw(in: CGRect(x: topX, y: topY, width: topWidth, height: topHeight), blendMode: .normal, alpha: 1.0)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

}
