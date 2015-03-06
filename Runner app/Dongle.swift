//
//  Dongle.swift
//  Runner app
//
//  Created by Alexander Lagerqvist on 06/03/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class dongle {
    
    //Create's run object using parameters
    class func createRunObjectAndStore(runName: String, runStartDate: NSDate, runStatus: NSNumber)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: managedContext)
        let templateRun = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as Run
        
        templateRun.name = runName
        templateRun.startDate = runStartDate
        templateRun.status = runStatus
        
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save/schedule run")
        }
    
    }
    
    //Create's date from a series of integers
    class func dateFromValues(year:Int,month:Int,day:Int,hour:Int,minute:Int, second:Int) -> NSDate{
        
        let calendar = NSCalendar.currentCalendar()
        let component = NSDateComponents()
        
        component.year = year
        component.month = month
        component.day = day
        component.hour = hour
        component.minute = minute
        component.second = second
        
        let dateToReturn = calendar.dateFromComponents(component)
        return dateToReturn!
    }
    
    //Tests
    class func runCases(){
    
        //Case 1
        
        createRunObjectAndStore("Case1", runStartDate: dateFromValues(2015, month: 3, day: 31, hour: 23, minute: 0, second: 0), runStatus: RunHelper.Status.Completed.rawValue)
        
        //Case 2
        
        createRunObjectAndStore("Case2", runStartDate: dateFromValues(2015, month: 3, day: 1, hour: 0, minute: 0, second: 1), runStatus: RunHelper.Status.Completed.rawValue)
        
        //Case 3
        
        createRunObjectAndStore("Case3", runStartDate: dateFromValues(2015, month: 2, day: 28, hour: 23, minute: 0, second: 0), runStatus: RunHelper.Status.Completed.rawValue)
        
        //Case 4
        
        createRunObjectAndStore("Case4", runStartDate: dateFromValues(2015, month: 4, day: 1, hour: 0, minute: 0, second: 1), runStatus: RunHelper.Status.Completed.rawValue)
        
        //Case 1.2
        
        createRunObjectAndStore("Case12", runStartDate: dateFromValues(2015, month: 3, day: 31, hour: 23, minute: 45, second: 0), runStatus: RunHelper.Status.Completed.rawValue)
        
        //Case 3.2
        
        createRunObjectAndStore("Case32", runStartDate: dateFromValues(2015, month: 2, day: 28, hour: 23, minute: 45, second: 0), runStatus: RunHelper.Status.Completed.rawValue)
        
        //Case 1.3
        
        createRunObjectAndStore("Case13", runStartDate: dateFromValues(2015, month: 3, day: 31, hour: 23, minute: 59, second: 59), runStatus: RunHelper.Status.Completed.rawValue)
        
        //Case 3.3
        
        createRunObjectAndStore("Case33", runStartDate: dateFromValues(2015, month: 2, day: 28, hour: 23, minute: 59, second: 59), runStatus: RunHelper.Status.Completed.rawValue)
    }
    
}