//
//  memeTextFieldDelegate.swift
//  MemeMe1.0
//
//  Created by EricTsui on 7/11/16.
//  Copyright © 2016 EricTsui. All rights reserved.
//

import Foundation
import UIKit

class memeTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
