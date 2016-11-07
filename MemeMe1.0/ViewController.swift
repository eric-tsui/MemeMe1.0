//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by EricTsui on 7/11/16.
//  Copyright © 2016 EricTsui. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    // MARK: Outlets
    
    @IBOutlet weak var imagePickerVIew: UIImageView!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var buttomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigatonBar: UINavigationBar!
    
    // MARK: Text Field Delegate Objects
    
    let memeTextAttributtes = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0
    ] as [String : Any]
    let memeDelegate = memeTextFieldDelegate()
    
    // MARK: Pick an Image
    
    enum ToolBarButtonItem: Int{
        case Camera = 0
        case Album  = 1
    }
    
    @IBAction func pickAnImage(_ sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        switch ToolBarButtonItem(rawValue: sender.tag)! {
        case .Camera:
            pickerController.sourceType = UIImagePickerControllerSourceType.camera
        case .Album:
            pickerController.sourceType =
                UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerVIew.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Generate Memed Image
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        self.navigatonBar.isHidden = true
        self.toolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO:  Show toolbar and navbar
        self.navigatonBar.isHidden = false
        self.toolBar.isHidden = false
        
        return memedImage
    }

    // MARK: Share the Memed Image
    
    @IBAction func shareMemedImage(_ sender: AnyObject) {
        // generate a memed image
        let image = generateMemedImage()
        
        // define an instance of the ActivityViewController
        // pass the ActivityViewController a memedImage as an activity item
        let shareVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // present the ActivityViewController
        present(shareVC, animated: true) {
            
            //Create the meme
            let meme = Meme(text: [self.topTextField.text!, self.buttomTextField.text!], image: self.imagePickerVIew.image!, memedImage: image)
            
            //Add it to the memes array in the Application Delegate
            (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
            //print("Save to memes array.")
        }
        
    }
    
    // MARK: Exit the Meme by 'Cancel' ToolBarButton
    
    @IBAction func cancelMeme(_ sender: AnyObject) {
        //dummy now for Meme 1.0
        //print("Clicked Cancel Bar Button in Nav Bar!")
    }
    
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        shareButton.isEnabled  = (imagePickerVIew.image != nil)
        cancelButton.isEnabled = false
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        topTextField.text = "TOP"
        buttomTextField.text = "BUTTOM"
        
        topTextField.defaultTextAttributes = memeTextAttributtes
        buttomTextField.defaultTextAttributes = memeTextAttributtes
        
        //need to put textAlignmnet below the defaultTextAttributes assignment, 
        //otherwise the alignment will not make effect
        topTextField.textAlignment = .center
        buttomTextField.textAlignment = .center
        
        self.topTextField.delegate = memeDelegate
        self.buttomTextField.delegate = memeDelegate
        
    }
    
    
    
    // Move the view when the keyboard covers the text field
    func keyboardWillShow(_ notification: NSNotification) {
        
        //Only the buttom Text Field needs to adjust the view
        if buttomTextField.isFirstResponder {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Move the view back when the keyboard is dismissed
    func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

