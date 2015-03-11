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

// Class for handling notifications
class NotificationManager {
    
    // The application handles the notifications when the app is closed or moved
    // to the background. This way the app will only schedule a notification of
    // the most relevant run and the phones queue will be managed correctly.
    // (Otherwise the phones queue will be full and scheduled notifications would
    // be removed).
    class func onApplicationExit() {
        // Delete pending notifications and create one for pending run.
        
        let appReference = UIApplication.sharedApplication()
        let appDelegate = appReference.delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        // Deleting the scheduled notifications
        appReference.cancelAllLocalNotifications()
        
        // Fetching the correct run to schedule notification for
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
                // Create notification
                var notification = UILocalNotification()
                
                // Calculate datetime
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
}