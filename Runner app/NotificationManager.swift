//
//  NotificationManager.swift
//  Runner app
//
//  Created by Jonathan Holm on 19/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotificationManager {
    
    class func onApplicationExit() {
        // Delete pending notifications and create one for pending run.
        
        return
        let appReference = UIApplication.sharedApplication()
        let appDelegate = appReference.delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        appReference.cancelAllLocalNotifications()
        
        let fetchRequest = NSFetchRequest(entityName: "Run")
        let currentDate = NSDate()
        //TODO: Continue
        let predicate = NSPredicate(format: "(status == %@) AND (startDate > %@) AND (startDate minsta)", "")
    }
}