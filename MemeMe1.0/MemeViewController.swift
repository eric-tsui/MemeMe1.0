//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by EricTsui on 7/11/16.
//  Copyright © 2016 EricTsui. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    // MARK: - Outlets
    
    @IBOutlet weak var imagePickerVIew: UIImageView!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var buttomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigatonBar: UINavigationBar!
    
    // MARK: - Variables and Constants
    
    let memeDelegate = memeTextFieldDelegate()
    var memedImage:UIImage?
    
    // MARK: - Actions
    
    //Pick an Image
    enum ToolBarButtonItem: Int{
        case Camera = 0
        case Album  = 1
    }
    
    @IBAction func pickAnImage(_ sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        //If there was an existed image in UIImageView
        if imagePickerVIew.image != nil {
            //generate a memed image and save to meme struct
            memedImage = generateMemedImage()
            saveMeme(memedImage: self.memedImage!)
        }
        
        //Pick a new image from Camera or Album
        switch ToolBarButtonItem(rawValue: sender.tag)! {
        case .Camera:
            pickerController.sourceType = UIImagePickerControllerSourceType.camera
        case .Album:
            pickerController.sourceType =
                UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(pickerController, animated: true, completion: nil)
    }
    
    //Share the Memed Image
    @IBAction func shareMemedImage(_ sender: AnyObject) {
        // define an instance of the ActivityViewController
        // pass the ActivityViewController a memedImage as an activity item
        let shareVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        // present the ActivityViewController
        present(shareVC, animated: true, completion: nil)
    }
    
    //Exit the Meme
    @IBAction func cancelMeme(_ sender: AnyObject) {
        //dummy now for Meme 1.0
    }
    
    
    // MARK: - Lifeycycle methods
    
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
        
        setupTextField(textField: topTextField, memeText: "TOP133")
        setupTextField(textField: buttomTextField, memeText: "BUTTOM2")
    }
    
    // MARK: - Private methods
    
    // MARK: Generate and Save Meme
    
    //Generate Memed Image
    private func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        navigatonBar.isHidden = true
        toolBar.isHidden = true
        
        //Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        navigatonBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
    
    //Save to Meme Array
    private func saveMeme(memedImage : UIImage){
        //Create the meme struct instance
        let meme = Meme(topText: self.topTextField.text!, buttomText: self.buttomTextField.text!,
                        originImage: self.imagePickerVIew.image!, memedImage: memedImage)
        
        //Add it to the memes array in the Application Delegate
        (UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
    }
    
    // MARK: Util to setup Text Field
    
    private func setupTextField(textField: UITextField, memeText: String) {
        let memeTextAttributtes = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
            ] as [String : Any]
        
        textField.defaultTextAttributes = memeTextAttributtes
        //need to put textAlignmnet after defaultTextAttributes assignment,otherwise the alignment will not make effect
        textField.textAlignment = .center
        textField.delegate = memeDelegate
        
        textField.text = memeText
    }
    
    // MARK: Utils to move the view
    
    func keyboardWillShow(_ notification: NSNotification) {
        //Only the buttom Text Field needs to adjust the view
        if buttomTextField.isFirstResponder {
            //move the view when the keyboard covers the text field
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillHide() {
        //Move the view back when the keyboard is dismissed
        self.view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    // MARK: - Delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerVIew.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Extensions
    
    }

