//
//  CMCollectionViewController.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit


class CMCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    //-View Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var SelectEventLabel: UILabel!
    
    //-Global objects, properties & variables
    var events = [Events]()
    var eventIndex: Int!
    
    //-Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag: Bool!
    var editButtonFlag: Bool!
    
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [IndexPath]()
    
    //-Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    
    //-Perform when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Create Navbar Buttons
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(CMCollectionViewController.editButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(CMCollectionViewController.addEvent))
                
        //-Manage Top and Bottom bar colors
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        self.tabBarController?.tabBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        // Unarchive the event when the list is first shown
        self.events = NSKeyedUnarchiver.unarchiveObject(withFile: eventsFilePath) as? [Events] ?? [Events]()
        
        //-Add notification observer
        NotificationCenter.default.addObserver(self, selector: #selector(CMCollectionViewController.refreshList), name: NSNotification.Name(rawValue: "TodoListShouldRefresh"), object: nil)
    }
    
    
    //-Layout the collection view cells
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that there are 3 cells accross
        // with white space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        
        let screenWidth = self.collectionView?.bounds.size.width
        let totalSpacing = layout.minimumInteritemSpacing * 3.0
        let imageSize = (screenWidth! - totalSpacing)/3.0
        layout.itemSize = CGSize(width: imageSize, height: imageSize)
        
        collectionView.collectionViewLayout = layout
        
    }
    
    
    //-Only allow 64 events (push notification limitation)
    @objc func refreshList() {
        if (events.count >= 64) {
            self.navigationItem.rightBarButtonItem!.isEnabled = false // disable 'add' button
        }
        collectionView.reloadData()
    }
    
    
    //-Perform when view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Archive the graph any time this list of events is displayed.
        NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
        
        //-Hide the tab bar
        self.tabBarController?.tabBar.isHidden = false
        
        bottomButton.isHidden = true
        SelectEventLabel.isHidden = true
        
        editButtonFlag = true
        
        //-Brute Force Reload the scene to view collection updates
        self.collectionView.reloadData()
    }
    
    
    //-Perform when view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Brute Force Reload the scene to view collection updates
        self.collectionView.reloadData()
    }
    
    
    //-Reset the collection Edit view when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CMCollectionViewController.editButton))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        bottomButton.isHidden = true
        editButtonFlag = true
        SelectEventLabel.isHidden = true
        
        let index : Int = 0
        for _ in selectedIndexes{
            selectedIndexes.remove(at: index)
        }
    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Edit Events button function
    @objc func editButton(){
        
        if self.navigationItem.leftBarButtonItem?.title == "Done" {
            
            //-Recreate navigation Back button and change name to "Edit"
            self.navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CMCollectionViewController.editButton))
            self.navigationItem.leftBarButtonItem = newBackButton
            editButtonFlag = true
            //-Hide the bottom text and button
            bottomButton.isHidden = true
            SelectEventLabel.isHidden = true
            
            //-Reset the collection view cells
            let index : Int = 0
            for _ in selectedIndexes{
                selectedIndexes.remove(at: index)
            }
            //-Brute Force Reload the scene to view collection updates
            self.collectionView.reloadData()
            
            
        } else {
            
            //-Recreate navigation Back button and change name to "Done"
            self.navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(CMCollectionViewController.editButton))
            self.navigationItem.leftBarButtonItem = newBackButton
            editButtonFlag = false
            //-Make bottom text visible
            SelectEventLabel.isHidden = false
        }
    }
    
    
    //-UICollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CMCollectionViewCell", for: indexPath) as! CMCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    
    //-If a collection entry is selected, pull up the Event Details page
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if editButtonFlag == false {
            
            let cell = collectionView.cellForItem(at: indexPath) as! CMCollectionViewCell
            
            //-Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
            if let index = selectedIndexes.firstIndex(of: indexPath) {
                selectedIndexes.remove(at: index)
            }
            else {
                
                //-De-select the previously selected cell
                let index : Int = 0
                for _ in selectedIndexes{
                    selectedIndexes.remove(at: index)
                }
                //-Brute Force Reload the scene to view collection updates
                self.collectionView.reloadData()
                //-Add the New selected cell
                selectedIndexes.append(indexPath)
            }
            
            //-Then reconfigure the cell
            configureCell(cell, atIndexPath: indexPath)
            
        } else {
            
            let controller =
            storyboard!.instantiateViewController(withIdentifier: "CMShowViewController") as! CMShowViewController

            controller.eventIndexPath = indexPath
            controller.eventIndex = (indexPath as NSIndexPath).row
            
            self.navigationController!.pushViewController(controller, animated: true)
            
        }
    }
    
    
    //-Configure Cell
    func configureCell(_ cell: CMCollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        let event = fetchedResultsController.object(at: indexPath) 
        
        //-Format the Date for the cell
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone(identifier: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.short //Set date style
        //dateFormatter.timeZone = TimeZone()
        
        if (event.isOverdue) { // the current time is later than the to-do item's deadline
            cell.eventDateCellLabel?.textColor = UIColor.red
        } else {
            cell.eventDateCellLabel?.textColor = UIColor.white // we need to reset this because a cell with red
        }
        
        cell.eventDateCellLabel!.text = dateFormatter.string(from: event.eventDate!)
        
        let eventImage2 = event.eventImage
        let finalImage = UIImage(data: eventImage2!)
        cell.eventImageView!.image = finalImage
        cell.layer.cornerRadius = 7.0
        
        //-Change cell appearance based on selection for deletion
        if self.selectedIndexes.firstIndex(of: indexPath) != nil {
            cell.eventImageView!.alpha = 0.5
            bottomButton.isHidden = false
            SelectEventLabel.isHidden = true
        } else {
            cell.eventImageView!.alpha = 1.0
            if selectedIndexes.isEmpty {
                bottomButton.isHidden = true
                //-show select event for removal label if still in edit mode
                if self.navigationItem.leftBarButtonItem?.title == "Done"{
                    SelectEventLabel.isHidden = false
                }
            }
        }
    }
    
    
    //-NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<Events> = {
        
        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    //-Fetched Results Controller Delegate
    
    //-Whenever changes are made to Core Data the following three methods are invoked. This first method is used to
    //-create three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    //-The second method may be called multiple times, once for each picture object that is added, deleted, or changed.
    //-We store the index paths into the three arrays.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
            
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            break
        @unknown default:break
        // <#fatalError()#>
        }
    }

    
    //-This method is invoked after all of the changed in the current batch have been collected
    //-into the three index path arrays (insert, delete, and upate). We now need to loop through the
    //-arrays and perform the changes.
    //
    //-The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    //-Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            }, completion: nil)
    }
    
    
    //-Click Button Decision function
    @IBAction func buttonButtonClicked() {
        deleteSelectedEvents()
    }
    
    
    //-Delete All Pictures before adding new pictures function
    func deleteAllEvents() {
        
        for event in (self.fetchedResultsController.fetchedObjects as [Events]?)! {
            self.sharedContext.delete(event)
        }
    }
    
    
    //-Delete Selected Event
    func deleteSelectedEvents() {
        
        var eventsToDelete = [Events]()
        
        for indexPath in selectedIndexes {
            eventsToDelete.append(fetchedResultsController.object(at: indexPath) )
        }
        
        for event in eventsToDelete {
            
            //-Delete the event notificaton
            if String(describing: event.eventDate!) > String(describing: Date()) { //...if event date is greater than the current date, remove the upcoming notification. If not, skip this routine.
                
                for notification in UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] { // loop through notifications...
                    if (notification.userInfo!["UUID"] as! String == String(describing: event.textEvent!)) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                        UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on title
                        break
                    }
                }
            }
        
        //-Call Delete Calendar Event
        
        if event.textCalendarID == nil {
            print("No calendar event.")
        } else {
            let eventStore = EKEventStore()
            let eventID = event.textCalendarID!
            let eventToRemove = eventStore.event(withIdentifier: eventID)
            
            if (eventToRemove != nil) {
                do {
                    try eventStore.remove(eventToRemove!, span: .thisEvent)
                } catch {
                    print("Calender Event Removal Failed.")
                }
            }
        }
        sharedContext.delete(event)
        }
        //-Delete Main Event        
        selectedIndexes = [IndexPath]()
        //-Save Object
        CoreDataStackManager.sharedInstance().saveContext()
        bottomButton.isHidden = true
        
        //-Archive the graph any time this list of events changes
        NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
    }
    
    
    //-Create a New Event
    @objc func addEvent() {        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CMAddEventViewController") as! CMAddEventViewController
        controller.editEventFlag = false
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Saving the array. Helper.
    var eventsFilePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        //print(url.URLByAppendingPathComponent("events").path!)
        return url.appendingPathComponent("events").path
    }
    
}


