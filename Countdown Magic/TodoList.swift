//
//  TodoList.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//


import UIKit
import CoreData

@objc(TodoList)


class TodoList : NSManagedObject {
    
    @NSManaged var todoListText: String?
    @NSManaged var events: Events?
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(todoListText: String?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "TodoList", in: context)!
        super.init(entity: entity,insertInto: context)
        
        self.todoListText = todoListText
        
    }
    
}
