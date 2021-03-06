//
//  BudgetAddTableViewController.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//

import UIKit
import CoreData


class BudgetAddTableViewController: UITableViewController, UITextFieldDelegate {
    
    //-View Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    //-Global objects, properties & variables
    var events: Events!
    var dataString:String?
    var priceString:String?
    
    //set the textfield delegates
    let priceTextDelegate = PriceTextDelegate()
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Textfield delegate values
        self.priceTextField.delegate = priceTextDelegate
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
            textField.becomeFirstResponder()
        }
        else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            priceTextField.becomeFirstResponder()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //-Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveDataAdd" {
            dataString = textField.text
            priceString = priceTextField.text
        }
        else {
            print("Segue Error")
        }
    }
    
}
