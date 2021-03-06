//
//  TodoAddTableViewController.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//


import UIKit
import CoreData


class TodoAddTableViewController: UITableViewController {
    
    //-View Outlet
    @IBOutlet weak var editModelTextField: UITextField!
    
    //-Global objects, properties & variables
    var events: Events!
    var editedModel:String?
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    //-Table view data source
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
            if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row == 0 {
                editModelTextField.becomeFirstResponder()
            }
            tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //-Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveDataAdd" {
            editedModel = editModelTextField.text
        }
        else {
            print("Segue Error")
        }

    }
    
    
}


