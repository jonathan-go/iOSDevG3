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
        
        let appReference = UIApplication.sharedApplication()
        let appDelegate = appReference.delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        appReference.cancelAllLocalNotifications()
        
        let fetchRequest = NSFetchRequest(entityName: "Run")
        let currentDate = NSDate()
        
        fetchRequest.predicate = NSPredicate(format: "(status = %i) AND (startDate > %@)", RunHelper.Status.Scheduled.rawValue, currentDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        var runs = [Run]()
        var error: NSError?
        let result = managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as [Run]?
        
        if let uResult = result {
            runs = uResult
            
            if runs.count > 0 {
                let notRun = runs[0]
                
                println(notRun.startDate)
                var notification = UILocalNotification()
                
                let calendar = NSCalendar()
                var offsetComponents = NSDateComponents()
                offsetComponents.minute = -15
                let notificationDate = calendar.dateByAddingComponents(offsetComponents, toDate: notRun.startDate, options: nil)
                
                notification.alertAction = "You have a scheduled run in 15 min!"
                notification.alertBody = "The weather is nice, I promise!"
                notification.fireDate = NSDate(timeIntervalSinceNow: 10)
                appReference.scheduleLocalNotification(notification)
            }
        }
    }
    
    class func onApplicationStartFromNotification(inout window: UIWindow) {
        // Get the correct run and start active run delen
        // TODO: Complete this function and change fireDate to normal before launch
    }
}