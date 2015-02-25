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
                
                var notification = UILocalNotification()
                
                var offsetComponents = NSDateComponents()
                offsetComponents.minute = -15
                let minutesToStartDate = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMinute, fromDate: currentDate, toDate: notRun.startDate, options: NSCalendarOptions(0))
                let notificationDate = NSCalendar.currentCalendar().dateByAddingComponents(offsetComponents, toDate: notRun.startDate, options: NSCalendarOptions(0))
                println(minutesToStartDate)
                
                notification.alertAction = "Scheduled run"
                if minutesToStartDate.minute < 15 {
                    notification.alertBody = "You have a run scheduled to start in \(minutesToStartDate.minute) minutes!"
                } else {
                    notification.alertBody = "You have a run scheduled to start in 15 minutes!"
                }
                notification.fireDate = notificationDate
                appReference.scheduleLocalNotification(notification)
            }
        }
    }
    
    class func onApplicationStartFromNotification(inout window: UIWindow) {
        // Get the correct run and start active run delen
        // TODO: Complete this function and change fireDate to normal before launch
    }
}