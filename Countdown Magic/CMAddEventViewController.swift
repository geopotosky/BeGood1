//
//  CMAddEventViewController.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//

import UIKit
import CoreData
import EventKit
    
class CMAddEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate{
        
    //-View Outlets
    @IBOutlet weak var datePickerLable: UILabel!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var flickrButton: UIButton!
    @IBOutlet weak var textFieldEvent: UITextField!
    @IBOutlet weak var toolbarObject: UIToolbar!
    @IBOutlet weak var adjustImageLabel: UILabel!
    @IBOutlet weak var tempImage: UIImageView!
    
    //-Set the textfield delegates
    let eventTextDelegate = EventTextDelegate()
    
    //-Global objects, properties & variables
    var events: [Events]!
    var eventIndex2:Int!
    var eventIndexPath2: IndexPath!
    var todaysDate: Date!
    var editEventFlag: Bool!
    var currentEventDate: Date!
    var flickrImageURL: String!
    var flickrImage: UIImage!
    var calendarID: String!
    var untouchedImage: UIImage!
    var changedEventImage: UIImage!
    var eventImageFinal:UIImage!
    var bottomPadding: CGFloat!
    
    
    //-Alert variable
    var alertMessage: String!
    
    //-Display image based on imageFlag value (0-no pic, 1-photo library, 2-camera photo, 3-Flickr Image, 4-scroll adjusted image)
    var imageFlag: Int! = 0
    var scrollImageFlag: Int! = 0
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        
        //-Set Navbar Title
        self.navigationItem.title = "Event Editor"
        //-Create Navbar Buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(CMAddEventViewController.saveEvent))
        
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.isHidden = true
        
        
        //-ScrollView Min and Max settings
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0


        //-Adjust Image Text blur effects
        self.adjustImageLabel.textAlignment = NSTextAlignment.center
        self.adjustImageLabel.layer.shadowColor = UIColor.black.cgColor
        self.adjustImageLabel.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.adjustImageLabel.layer.shadowRadius = 7.0
        self.adjustImageLabel.layer.shadowOpacity = 0.5
        self.adjustImageLabel.layer.masksToBounds = false
        
        
        //-Set the Image Size and Aspect Programmatically
        self.view.addBackground()
        
        imageFlag = 0  //-reset imageFlag
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CMAddEventViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
        
        //-Date Picker Formatting
        let dateFormatter = DateFormatter()
        self.todaysDate = Date()
        let timeZone = TimeZone(identifier: "Local")
        dateFormatter.timeZone = timeZone
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        
        
        //-Set starting textfield default values
        self.textFieldEvent.text = "Enter Event Description"
        self.textFieldEvent.textAlignment = NSTextAlignment.center
        
        //-Textfield delegate values
        self.textFieldEvent.delegate = eventTextDelegate
        
        //-fetch saved event data
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        
        //-Set Values Based on New or Existing Event
        //-Disable SAVE button if creating new Event
        //-Enable SAVE button if editing existing Event
        //-Hide Adjust Image Text if Creating new Event
        //-View Adjust Image Text if editing existig Event
        
        if editEventFlag == false {
            //-Load default values for new event
            tempImage.isHidden = false
            currentEventDate = Date()
            self.untouchedImage = nil //new image
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.adjustImageLabel.isHidden = true
            
        //editEventFlag is set to true
        } else {
            //-Load values for existing event
            tempImage.isHidden = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.adjustImageLabel.isHidden = false
            let event = fetchedResultsController.object(at: eventIndexPath2) 
            
            //-Add Selected text attributes and populate Editor fields
            self.textFieldEvent.text = event.textEvent
            imageViewPicker.image = UIImage(data: event.eventImage!)
            self.untouchedImage = imageViewPicker.image //image prior to updates
            currentEventDate = event.eventDate
            calendarID = event.textCalendarID
            
            let dateFormatter = DateFormatter()
            let timeZone = TimeZone(identifier: "Local")
            dateFormatter.timeZone = timeZone
            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            let strDate = dateFormatter.string(from: currentEventDate)
            datePickerLable.text = strDate
        }

    }
    
    
    //-Perform when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        //-Recognize the Flickr image request
        if imageFlag == 3 {
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.adjustImageLabel.isHidden = false
            self.imageViewPicker.image = flickrImage
            tempImage.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone(identifier: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        if currentEventDate != nil {
            let strDate = dateFormatter.string(from: currentEventDate)
            datePickerLable.text = strDate
        }
        
        //-Disable the CAMERA if you are using a simulator without a camera
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
       
    }
    
    //-Perform when view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 11, *) {
            
            //get the bottom padding below safearea
            self.bottomPadding = view.safeAreaInsets.bottom
            print("bottom padding:", bottomPadding as Any)
        }
    }
    
    
    //-Scrolling an Image Movements
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //-this view is touched 3 times by default
        //-if this view is touched only 3 times, then the image size was not changed.
        //-if this view is touched more than 3 times, then the image was zoomed.
        scrollImageFlag = scrollImageFlag + 1
        if scrollImageFlag > 3 {
            imageFlag = 4
        } else {
            imageFlag = 0
        }
        return self.imageViewPicker
    }
    
    
    //-Perform when view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()

    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()

    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController<Events> = {
        
        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        //fetchRequest.predicate = NSPredicate(format: "events == %@", self.events);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()

    
    //-Pick Event Date
    @IBAction func pickEventDate(_ sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CMPickDateViewController") as! CMPickDateViewController
        controller.editEventFlag2 = editEventFlag
        print("Hello Date Picker")
        controller.currentEventDate = self.currentEventDate
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Button to Pick an image from the library
    @IBAction func PickAnImage(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //-Select an image for the Event from your Camera Roll
    func imagePickerController(_ imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

            
            if let eventImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                imageFlag = 1
                self.imageViewPicker.image = eventImage
                self.adjustImageLabel.isHidden = false
                tempImage.isHidden = true
                
                //-Reset the ScrollView to original scale
                self.scrollView.zoomScale = 1.0
            }
        
            //-Enable the Right Navbar Button
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.dismiss(animated: true, completion: nil)
    }

    
    //-Cancel the picked image
    func imagePickerControllerDidCancel(_ imagePicker: UIImagePickerController){
        self.dismiss(animated: true, completion: nil)
    }
    

    //-Select an image by taking a Picture
    @IBAction func pickAnImageFromCamera (_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imageFlag = 2
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    //-Call the Flickr VC
    @IBAction func getFlickrImage(_ sender: UIButton) {

        imageFlag = 0
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CMFlickrViewController") as! CMFlickrViewController
        controller.editEventFlag2 = editEventFlag
        controller.eventIndexPath2 = self.eventIndexPath2
        controller.currentImage = self.imageViewPicker.image
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Dismissing the keyboard methods
    
    func addKeyboardDismissRecognizer() {
        //-Add the recognizer to dismiss the keyboard
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        //-Remove the recognizer to dismiss the keyboard
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        //-End editing here
        self.view.endEditing(true)
    }

    
    //-Create the adjusted Event Image
    func createSnapshotOfView() -> UIImage {
        
        //-Hide screen objects
        toolbarObject.isHidden = true
        self.navigationController!.navigationBar.isHidden = true
        datePickerLable.isHidden = true
        datePickerButton.isHidden = true
        textFieldEvent.isHidden = true
        adjustImageLabel.isHidden = true
        
        //-Capture the image
        imageFlag = 1
        //-Remove bottom padding for iOS 11 or newer
        let rect: CGRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height - bottomPadding)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        view.layer.render(in: context)
        let capturedScreen: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        let shareEventImage: UIImage = UIImage(cgImage: capturedScreen.cgImage!, scale: 1.0, orientation: .up)
        
        //-UnHide screen objects
        toolbarObject.isHidden = false
        self.navigationController!.navigationBar.isHidden = false
        datePickerLable.isHidden = false
        datePickerButton.isHidden = false
        textFieldEvent.isHidden = false
        
        return shareEventImage
    }
    
    
    //-Save the Event method
    @objc func saveEvent() {

        //-----------------------------------------------------
        //Pre-iPhone X (keep for now): Create the adjusted event image.
        //self.changedEventImage = createSnapshotOfView()
        //let eventImage = UIImageJPEGRepresentation(self.changedEventImage, 100)
        //-----------------------------------------------------
        
        //-check for changed image
        if imageFlag == 0 {
                eventImageFinal = self.imageViewPicker.image
            } else {
                self.changedEventImage = createSnapshotOfView()
                eventImageFinal = self.changedEventImage
            }
            let eventImage = self.eventImageFinal.jpegData(compressionQuality: 100)
        
        
        //-Verify Selected Date is greater than current date before saving
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss a"
        
        //-If the edit event flag is set to true, save an existing event
        if editEventFlag == true {
            
            //Debug Print Statements
            //print("event date: ", dateFormatter.string(from: self.currentEventDate))
            //print("current date: ", dateFormatter.string(from: Date()))
            
            //-Verify the Event title is not blank or the default text
            if textFieldEvent.text == "" || textFieldEvent.text == "Enter Event Description"{
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
                
            } else
                
                //-Verify Selected Date is greater than current date before saving
                if dateFormatter.string(from: self.currentEventDate) == dateFormatter.string(from: Date()){
                    self.alertMessage = "Please Verify the Event Date is Greater Than the Current Date"
                    self.textAlertMessage()
                } else {
            
                    //-Get the original event, then delete it from core data, delete related notifications,
                    //-and remove any existing Calendar Event
                
                    let event = fetchedResultsController.object(at: eventIndexPath2) 
                    print("New Event Date looks OK to me.")
                    
                    //-Delete the original event notificaton
                    
                    if String(describing: event.eventDate!) != String(describing: Date()) { //...if event date is not equal to the current date, remove the upcoming notification. If not, skip this routine.
                        for notification in UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] { // loop through notifications...
                            if (notification.userInfo!["UUID"] as! String == String(describing: event.textEvent!)) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                                UIApplication.shared.cancelLocalNotification(notification) // there should be a maximum of one match on title
                                break
                            } else{
                                print("notication UUID not equal to event textname")
                            }
                        }
                    }
                    
                    //-Prevent dupicates Event Names
                    do {
                    //-Save original event title in temporary object
                    let newEventTitle: String! = String(event.textEvent!)
                    //-Pull the objects to look for duplicates
                    let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
                    fetchRequest.predicate = NSPredicate(format: "textEvent == %@", textFieldEvent.text!);
                    let result = try self.sharedContext.fetch(fetchRequest)
                        if result.count == 1 && textFieldEvent.text! != newEventTitle{
                            self.alertMessage = "Duplicate Event Title Found. Enter a unique Event Title."
                            self.textAlertMessage()
                        }
                        else {
                            
                            //-Re-Add Event
                            event.textEvent = textFieldEvent.text!
                            event.eventDate = self.currentEventDate
                            event.eventImage = eventImage
                            event.textCalendarID = calendarID
                            
                            self.sharedContext.refresh(event, mergeChanges: true)
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                            //-Call Delete Calendar Event
                            if event.textCalendarID == nil {
                                
                                //-Pass event index info to Show view
                                let controller = self.navigationController!.viewControllers[1] as! CMShowViewController
                                controller.editEventFlag = true
                                controller.eventIndexPath = self.eventIndexPath2
                                controller.eventIndex = self.eventIndex2
                                
                                self.navigationController!.popViewController(animated: true)
                                
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
                                
                                //-Set the selected Calendar event Title, start date, and end date
                                let title = textFieldEvent.text!
                                let startDate = self.currentEventDate
                                let endDate = startDate!.addingTimeInterval(2 * 60 * 60)
                                
                                //-Call the Calendar Update Method
                                updateEventToCalendar(calendarTitle: title, startDate: startDate!, endDate: endDate as NSDate)
                                
                                //-Create a corresponding local notification
                                dateFormatter.dateFormat = "MMM dd 'at' h:mm a" // example: "Jan 01 at 12:00 PM"
                                
                                let notification = UILocalNotification()
                                notification.alertBody = "Event \(textFieldEvent.text!) - on \"\(dateFormatter.string(from: self.currentEventDate))\" is Overdue" // text that will be displayed in the notification
                                notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                                notification.fireDate = self.currentEventDate // Event item due date (when notification will be fired)
                                notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                                notification.userInfo = ["UUID": String(describing: self.textFieldEvent.text!)]
                                UIApplication.shared.scheduleLocalNotification(notification)
                                
                                //-Pass event index info to Show view
                                let controller = self.navigationController!.viewControllers[1] as! CMShowViewController
                                controller.editEventFlag = true
                                controller.eventIndexPath = self.eventIndexPath2
                                controller.eventIndex = self.eventIndex2
                                
                                self.navigationController!.popViewController(animated: true)
                            }
                        }
                    }
                    catch {
                        self.alertMessage = "No events found. Try again."
                        self.textAlertMessage()
                    }
            }
            
        //-If the edit event flag is set to false, save a new event
        } else {
            
            //-Debug Print Statements
            //print("New event date: ", dateFormatter.string(from: self.currentEventDate))
            //print("Current date: ", dateFormatter.string(from: Date()))
            
            //-Verify the Event title is not blank or the default text
            if textFieldEvent.text == "" || textFieldEvent.text == "Enter Event Description" {
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
            } else
                
                //-Verify Selected Date is greater than current date before saving
                if dateFormatter.string(from: self.currentEventDate) == dateFormatter.string(from: Date()){
                    self.alertMessage = "Please Verify the Event Date is Greater Than the Current Date"
                    self.textAlertMessage()
                    
                }else {
                
                    //-Prevent dupicates Event Names
                    do {
                        //-Pull the objects to look for duplicates
                        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
                        fetchRequest.predicate = NSPredicate(format: "textEvent == %@", textFieldEvent.text!);
                        let result = try self.sharedContext.fetch(fetchRequest)
                        if result.count == 1 {
                            self.alertMessage = "Duplicate Event Title Found. Enter a unique Event Title."
                            self.textAlertMessage()
                        }
                        else {
                            
                            //-Save new event
                            let _ = Events(eventDate: self.currentEventDate, textEvent: textFieldEvent.text!, eventImage: eventImage, textCalendarID: nil, context: sharedContext)
                            
                            //-Save the shared context, using the convenience method in the CoreDataStackManager
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                            //-Create a corresponding local notification
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMM dd 'at' h:mm a" // example: "Jan 01 at 12:00 PM"
                            
                            let notification = UILocalNotification()
                            notification.alertBody = "Event \(textFieldEvent.text!) - on \"\(dateFormatter.string(from: self.currentEventDate))\" is Overdue" // text that will be displayed in the notification
                            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
                            notification.fireDate = self.currentEventDate // event item due date (when notification will be fired)
                            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
                            notification.userInfo = ["UUID": String(describing: textFieldEvent.text!)]
                            UIApplication.shared.scheduleLocalNotification(notification)
                            
                            self.navigationController!.popViewController(animated: true)
                        }
                    }
                    catch {
                        self.alertMessage = "No events found. Try again."
                        self.textAlertMessage()
                    }
                }
            }
    }
    
    
    //-Add Event to the local calendar
    func updateEventToCalendar(calendarTitle: String, startDate: Date, endDate: NSDate, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        let eventStore = EKEventStore()
        let event = fetchedResultsController.object(at: eventIndexPath2)
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {

                //-Create Calendar Event
                let calendarEvent = EKEvent(eventStore: eventStore)
                calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
                calendarEvent.title = calendarTitle
                calendarEvent.startDate = startDate
                calendarEvent.endDate = endDate as Date
                
                //-Set alert for 1 hour prior to Event
                let alarm = EKAlarm(relativeOffset: -3600.0)
                calendarEvent.addAlarm(alarm)
                calendarEvent.notes = calendarTitle
                
                do {
                    try eventStore.save(calendarEvent, span: .thisEvent)
                } catch let errorC as NSError {
                    print("Calendar Save Error")
                    completion?(false, errorC)
                    return
                }
                event.textCalendarID = calendarEvent.eventIdentifier
                self.sharedContext.refresh(event, mergeChanges: true)
                CoreDataStackManager.sharedInstance().saveContext()
                completion?(true, nil)
            } else {
                print("Authorization Not Granted.")
                completion?(false, error as NSError?)
            }
        })
    }
    
    
    //-Alert Message function
    func textAlertMessage(){
        DispatchQueue.main.async {
            let actionSheetController = UIAlertController(title: "Alert!", message: "\(self.alertMessage!)", preferredStyle: .alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blue
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            //alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
            alertContentView.layer.cornerRadius = 12
            alertContentView.backgroundColor = UIColor.green
            
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in
                
            }
            actionSheetController.addAction(okAction)
            
            //-Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    
    //-Saving the array Helper.
    var eventsFilePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        //print(url.URLByAppendingPathComponent("events").path!)
        return url.appendingPathComponent("events").path
    }
    
}

//-Process to Set the Image Size & Aspect Programmatically
extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
