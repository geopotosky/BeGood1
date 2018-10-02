//
//  CMPopoverViewController.swift
//  Countdown Magic
//
//  Created by George Potosky October 2018.
//  Copyright (c) 2018 GeoWorld. All rights reserved.
//


import UIKit
import CoreData


enum AdaptiveMode{
    case `default`
    case landscapePopover
    case alwaysPopover
}


class CMPopoverViewController: UITableViewController, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBInspectable var popoverOniPhone:Bool = false
    @IBInspectable var popoverOniPhoneLandscape:Bool = true
    
    //-Global objects, properties & variables
    var events: Events!
    var eventIndexPath2: IndexPath!
    var headerText: String!
    
    //-Info Alert variables
    var infoMessage: String!
    var infoTitle: String!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        //-Cancel button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(CMPopoverViewController.tapCancel(_:)))
        //-Popover settings
        modalPresentationStyle = .popover
        popoverPresentationController!.delegate = self
        self.preferredContentSize = CGSize(width:200,height:200)
    }
    
    
    @objc func tapCancel(_ : UIBarButtonItem) {
        //-tap cancel
        dismiss(animated: true, completion:nil)
    }
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.popoverPresentationController?.backgroundColor = UIColor.white
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController<Events> = {
        
        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textEvent", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){

        let eventMenu = tableView.cellForRow(at: indexPath)!.textLabel!.text
        if eventMenu == "To Do List" {
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "TodoTableViewController") as! TodoTableViewController
            let event = fetchedResultsController.object(at: eventIndexPath2) 
            
            controller.eventIndexPath2 = eventIndexPath2
            controller.events = event
            controller.headerText = self.headerText!
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(navController, animated: true, completion: nil)
            
        } else if eventMenu == "Budget Sheet" {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "BudgetTableViewController") as! BudgetTableViewController
            
            let event = fetchedResultsController.object(at: eventIndexPath2) 
            
            controller.eventIndexPath2 = eventIndexPath2
            controller.events = event
            controller.headerText = self.headerText!
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            self.present(navController, animated: true, completion: nil)
            
        } else if eventMenu == "Magic Wand Info" {
            
            //-Call the Info Alert message
            self.infoTitle = "What is the Magic Wand?"
            self.infoMessage = "The Magic Wand is a unique Countdown Magic method not available in any other countdown app. The Magic Wand removes the current day of the event counter since the current day has already started, and removes the final day of the event counter since the last day is so close to the end and can be considered part of the event day. The Magic Wand button is ON if the wand has a white star. \n\nHold the Magic Wand button down to view a quick tip."
            self.InfoAlertMessage()
            
        } else if eventMenu == "About the App" {
            
            //-Call the Info Alert message
            self.infoTitle = "About Countdown Magic"
            self.infoMessage = "Version 1.0\r\r Countdown Magic is an event tracker and countdown App. Events are automatically saved after they are created/edited.  The app includes the ability to fully customize the event view with an endless selection of pictures or photos, along with adding and printing To Do lists and budget sheets for each event. Users can add their events to their local calendar and share them with social media apps.\r\r Copyright(c) 2018 GeoWorld. All rights reserved."
            self.InfoAlertMessage()
        }
        
    }
    
    
    //-popover settings, adaptive for horizontal compact trait
    func adaptivePresentationStyle(for PC: UIPresentationController) -> UIModalPresentationStyle{
        
        //-this method is only called by System when the screen has compact width
        
        //-return .None means we still want popover when adaptive on iPhone
        //-return .FullScreen means we'll get modal presetaion on iPhone
        
        switch(popoverOniPhone, popoverOniPhoneLandscape){
        case (true, _): //-always popover on iPhone
            return .none
            
        case (_, true): //-popover only on landscape on iPhone
            let size = PC.presentingViewController.view.frame.size
            if(size.width>320.0){ //landscape
                return .none
            }else{
                return .fullScreen
            }
            
        default: //-no popover on iPhone
            return .fullScreen
        }
    }
    
    
    func presentationController(_: UIPresentationController, viewControllerForAdaptivePresentationStyle _: UIModalPresentationStyle)
        -> UIViewController?{
            return UINavigationController(rootViewController: self)
    }
    
    
    //-Info Alert Message function
    func InfoAlertMessage(){
        DispatchQueue.main.async {
            
            let actionSheetController = UIAlertController(title: "\(self.infoTitle!)", message: "\(self.infoMessage!)", preferredStyle: .alert)
            
            //-Update alert colors and attributes
            let subview = actionSheetController.view.subviews.first!
            let alertContentView = subview.subviews.first!
            alertContentView.backgroundColor = UIColor.green
            alertContentView.layer.cornerRadius = 12

            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in

            self.dismiss(animated: true, completion: {})
                
            }
            actionSheetController.addAction(okAction)
            
            
            //-Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }

}


