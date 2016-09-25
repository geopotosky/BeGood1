//
//  TodoTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//


import UIKit
import CoreData


class TodoTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var printList: UIBarButtonItem!
    //-Global objects, properties & variables
    var events: Events!
    var eventIndexPath2: IndexPath!
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Colorize NavBar & ToolBar
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        self.navigationController?.toolbar.barTintColor = UIColor(red: 0.66, green: 0.97, blue: 0.59, alpha: 1.0)
        
        //-Create NavBar Items
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TodoTableViewController.cancelTodoList))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(TodoTableViewController.addTodoList))
        
        //-Create toolBarItems
        //let toolBar1 = self.editButtonItem
        //let toolBar2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //        //let toolBar3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(TodoTableViewController.printListPage))
        
        //let printerImage = UIImage(named: "printer2-30.png") as UIImage?
        //let toolBar3 = UIBarButtonItem(image: printerImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(TodoTableViewController.printListPage))
        
        
        //self.toolbarItems = [toolBar2, toolBar3]
        
        //-Show the toolBar
        self.navigationController!.setToolbarHidden(false, animated: true)
        
        
        //-Create buttons
//        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
//        let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TodoTableViewController.cancelTodoList))
//        self.navigationItem.leftBarButtonItem = newBackButton
//        
//        let b1 = self.editButtonItem
//        let b2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(TodoTableViewController.addTodoList))
//        self.navigationItem.rightBarButtonItems = [b2, b1]
        
        do {
            //-Call Fetch method
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        
    }
    
    
    //-Reset the Table Edit view when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        resetEditing(false, animated: false)
    }
    
    
    //-Force set editing toggle (delete line items)
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //-Reset the Table Edit view when the view disappears
    func resetEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //-Table view data source
    
    
    //-Add the "sharedContext" convenience property
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //-Fetch the To Do List data
    lazy var fetchedResultsController: NSFetchedResultsController<TodoList> = {
        
        let fetchRequest = NSFetchRequest<TodoList>(entityName: "TodoList")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "todoListText", ascending: true)]
                fetchRequest.predicate = NSPredicate(format: "events == %@", self.events);
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()

    
    //-Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let CellIdentifier = "todoTableCell"
            let todos = fetchedResultsController.object(at: indexPath) 
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as
            UITableViewCell
            
            configureCell(cell, withList: todos)
            return cell
    }
    

    override func tableView(_ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
            
            switch (editingStyle) {
            case .delete:
                
                //-Here we get the To Do List item, then delete it from Core Data
                let todos = fetchedResultsController.object(at: indexPath) 
                sharedContext.delete(todos)
                CoreDataStackManager.sharedInstance().saveContext()
                
            default:
                break
            }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType) {
            
            switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                
            default:
                return
            }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
            let todos = controller.object(at: indexPath!) as! TodoList
            self.configureCell(cell!, withList: todos)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    
    //-Display To Do List data in table scene
    func configureCell(_ cell: UITableViewCell, withList todos: TodoList) {
        cell.textLabel?.text = todos.todoListText
    }
    
    
    //-Save edited To Do List data
    @IBAction func editToMainViewController (_ segue:UIStoryboardSegue) {
        
        let detailViewController = segue.source as! TodoEditTableViewController
        
        let todos = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!) 
        todos.todoListText = detailViewController.editedModel!
        self.sharedContext.refresh(todos, mergeChanges: true)
        
        CoreDataStackManager.sharedInstance().saveContext()
        tableView.reloadData()
        
    }
    
    
    //-Save New To Do List data
    @IBAction func saveToMainViewController (_ segue:UIStoryboardSegue) {
        
        let detailViewController = segue.source as! TodoAddTableViewController
        let listText = detailViewController.editedModel
        let todos = TodoList(todoListText:  listText, context: self.sharedContext)
        todos.events = self.events
        
        CoreDataStackManager.sharedInstance().saveContext()
        tableView.reloadData()
        
    }
    
    
    //-Navigation
    
    //-Prepare for segue to next navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit" {
            
            let path = tableView.indexPathForSelectedRow
            let detailViewController = segue.destination as! TodoEditTableViewController
            detailViewController.events = self.events
            detailViewController.todosIndexPath = path
            
        }
    }
    
    
    //-Add To Do List item function
    func addTodoList(){

        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TodoAddTableViewController") as! TodoAddTableViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Cancel To Do List item function
    
    func cancelTodoList(){
        let tmpController :UIViewController! = self.presentingViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
        
    }
    
    //-Print the To Do List
    @IBAction func printList(_ sender: UIBarButtonItem) {
//    }
//    func printListPage(){
        
        //-Take a snapshot of the screen
        let rect: CGRect = view.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        view.layer.render(in: context)
        let capturedScreen: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let printImage: UIImage = UIImage(cgImage: capturedScreen.cgImage!, scale: 1.0, orientation: .up)
        
        //if UIPrintInteractionController.canPrintURL(imageURL) {
        let printInfo = UIPrintInfo(dictionary: nil)
        //printInfo.jobName = imageURL.lastPathComponent
        printInfo.outputType = .general
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
        
        printController.printingItem = printImage
        
        printController.present(animated: true, completionHandler: nil)
        //}
    }
    
}

