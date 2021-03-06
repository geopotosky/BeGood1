//
//  EventTextDelegate.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//


import Foundation
import UIKit

class EventTextDelegate: NSObject, UITextFieldDelegate {
    
    //-Ask the delegate if the textfield should change
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText: NSString = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        return true;
    }
    
    //-Let the delegate know that editing has begun
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //-Check to see if the initial value of the textfield is TOP. If it is, clear it.
        if textField.text == "Enter Event Description" {
            textField.text = ""
        }
        
    }
    
    //-Ask the delegate if the RETURN key should be processed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
    
        return true;
    }
    
    
}

