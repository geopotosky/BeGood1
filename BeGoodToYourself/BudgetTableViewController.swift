//
//  BudgetTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class BudgetTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var printList: UIBarButtonItem!
    
    //-View Outlets
    @IBOutlet weak var totalLabel: UILabel!
    
    //-Global objects, properties & variables
    var events: Events!
    var eventIndexPath2: IndexPath!
    var headerText: String!
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //-Colorize NavBar & ToolBar
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        self.navigationController?.toolbar.barTintColor = UIColor(red: 0.66, green: 0.97, blue: 0.59, alpha: 1.0)
        
//        //-Create NavBar Items
//        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(TodoTableViewController.cancelTodoList))
//        self.navigationItem.leftBarButtonItem = newBackButton
//        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(TodoTableViewController.addTodoList))
//        
//        //-Create toolBarItems
//        let toolBar1 = self.editButtonItem
//        let toolBar2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        //        //let toolBar3 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(TodoTableViewController.printListPage))
//        
//        let printerImage = UIImage(named: "printer2-30.png") as UIImage?
//        let toolBar3 = UIBarButtonItem(image: printerImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(TodoTableViewController.printListPage))
//        
//        
//        self.toolbarItems = [toolBar1, toolBar2, toolBar3]
//        
//        //-Show the toolBar
//        self.navigationController!.setToolbarHidden(false, animated: true)

        
        
        
        
//        //-Create Navbar Buttons
//        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
//        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BudgetTableViewController.cancelBudgetList))
//        self.navigationItem.leftBarButtonItem = newBackButton
//
//        let b1 = self.editButtonItem
//        let b2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(BudgetTableViewController.addBudgetList))
//        self.navigationItem.rightBarButtonItems = [b2, b1]
        
        //-Colorize NavBar & ToolBar
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        self.navigationController?.toolbar.barTintColor = UIColor(red: 0.66, green: 0.97, blue: 0.59, alpha: 1.0)
        
        //-Create NavBar Items
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(BudgetTableViewController.cancelBudgetList))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(BudgetTableViewController.addBudgetList))
        
        //-Show the toolBar
        self.navigationController!.setToolbarHidden(false, animated: true)
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        
    }
    
    
    //-Perform when view did appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var finalValue: Float! = 0.0
        
        if events.budget.count > 0 {
            var index : Int = 0
            for counter in events.budget{
                let priceCount = counter.priceBudgetText
                let counterInt = NumberFormatter().number(from: priceCount!)?.floatValue
                finalValue = finalValue + counterInt!
            }
            index += 1
        }

        let totals: String = "\nBudget:"
        let yourBudgetTotal = String.localizedStringWithFormat("%@ $%.2f", totals, finalValue)
        let formattedString = NSMutableAttributedString()
        _ = formattedString.bold(text: self.headerText!).normal(text: yourBudgetTotal)
        totalLabel.attributedText = formattedString
        
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
    
    
    //-Add the "sharedContext" convenience property
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    //-Fetch Budget data
    lazy var fetchedResultsController: NSFetchedResultsController<Budget> = {
        
        let fetchRequest = NSFetchRequest<Budget>(entityName: "Budget")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "itemBudgetText", ascending: true)]
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
            let CellIdentifier = "tableCell"
            let budget = fetchedResultsController.object(at: indexPath) 
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)! as
            UITableViewCell
            
            configureCell(cell, withList: budget)
            return cell
    }

    
    override func tableView(_ tableView: UITableView,
        commit editingStyle: UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
            
            switch (editingStyle) {
            case .delete:
                
                //-Here we get the budget item, then delete it from core data
                let budget = fetchedResultsController.object(at: indexPath) 
                sharedContext.delete(budget)
                CoreDataStackManager.sharedInstance().saveContext()
                
                //-Update Budget total on view
                var finalValue: Float! = 0.0
                if events.budget.count > 0 {
                    var index : Int = 0
                    for counter in events.budget{
                        let priceCount = counter.priceBudgetText
                        let counterInt = NumberFormatter().number(from: priceCount!)?.floatValue
                        finalValue = finalValue + counterInt!
                    }
                    index += 1
                }
                let totals: String = "\nBudget:"
                let yourBudgetTotal = String.localizedStringWithFormat("%@ $%.2f", totals, finalValue)
                let formattedString = NSMutableAttributedString()
                _ = formattedString.bold(text: events.textEvent!).normal(text: yourBudgetTotal)
                totalLabel.attributedText = formattedString
                
                
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
            let budget = controller.object(at: indexPath!) as! Budget
            self.configureCell(cell!, withList: budget)
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
        
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    
    //- Display Budget data in table scene
    func configureCell(_ cell: UITableViewCell, withList budget: Budget) {
        
        cell.textLabel?.text = budget.itemBudgetText
        let newValue = NumberFormatter().number(from: budget.priceBudgetText!)?.floatValue
        cell.detailTextLabel?.text = String.localizedStringWithFormat("$%.2f", newValue!)
        
    }

    
    //- Save edited Budget sheet data
    @IBAction func editToTableData(_ segue:UIStoryboardSegue) {
        
        let detailViewController = segue.source as! BudgetEditTableViewController
        let budget = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!) 
        budget.itemBudgetText = detailViewController.dataString!
        budget.priceBudgetText = detailViewController.priceString!
        self.sharedContext.refresh(budget, mergeChanges: true)
        
        CoreDataStackManager.sharedInstance().saveContext()
        tableView.reloadData()
    }
    
    //- Save new Budge sheet data
    @IBAction func saveToTableData(_ segue:UIStoryboardSegue) {
        
        let detailViewController = segue.source as! BudgetAddTableViewController
        let editedData = detailViewController.dataString
        let changedPrice = detailViewController.priceString
        let budget = Budget(itemBudgetText:  editedData, priceBudgetText: changedPrice, context: self.sharedContext)
        budget.events = self.events
        
        CoreDataStackManager.sharedInstance().saveContext()
        tableView.reloadData()
    }
    
    
    //-Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        //-Get the new view controller using [segue destinationViewController].
        //-Pass the selected object to the new view controller.
        
        if segue.identifier == "editBudget" {
            
            let path = tableView.indexPathForSelectedRow
            let detailViewController = segue.destination as! BudgetEditTableViewController
            detailViewController.events = self.events
            detailViewController.budgetIndexPath = path
        }
        
    }
    
    
    //-Add Budget item function
    func addBudgetList(){

        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BudgetAddTableViewController") as! BudgetAddTableViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Cancel Budget List item function
    func cancelBudgetList(){
        let tmpController :UIViewController! = self.presentingViewController;
        self.dismiss(animated: false, completion: {()->Void in
            tmpController.dismiss(animated: false, completion: nil);
        });
        
    }
    
    //-Print the To Do List
    @IBAction func printList(_ sender: UIBarButtonItem) {

        //-Take a snapshot of the screen
        self.navigationController!.setToolbarHidden(true, animated: true)
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let printImage: UIImage = UIImage(cgImage: screenshot!.cgImage!, scale: 1.0, orientation: .up)
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
        
        printController.printingItem = printImage
        
        printController.present(animated: true, completionHandler: nil)
        
        self.navigationController!.setToolbarHidden(false, animated: true)
        self.navigationController!.setNavigationBarHidden(false, animated: true)

    }
}

////-Bold and Normal Text Creation Function
//extension NSMutableAttributedString {
//    func bold(text:String) -> NSMutableAttributedString {
//        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "Helvetica-Bold", size: 17)!]
//        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
//        self.append(boldString)
//        return self
//    }
//    
//    func normal(text:String)->NSMutableAttributedString {
//        let normal =  NSAttributedString(string: text)
//        self.append(normal)
//        return self
//    }
//}



