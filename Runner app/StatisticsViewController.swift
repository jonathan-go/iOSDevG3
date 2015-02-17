//
//  StatisticsViewController.swift
//  Runner app
//
//  Created by Jonathan Holm on 17/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController {
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    func getDateFromString(date: String) -> NSDate {
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let d = dateStringFormatter.dateFromString(date)
        return NSDate(timeInterval: 0, sinceDate: d!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: self.managedObjectContext!) as Run
        
        newItem.name = "Testrun OAOAOA"
        newItem.distance = 12
        newItem.startDate = getDateFromString("2015-02-17 13:00")
        newItem.lastResumeDate = getDateFromString("2015-02-17 17:00")
        newItem.savedTime = Double(600.0)
        
        var error: NSError?
        if !newItem.managedObjectContext!.save(&error) {
            println("Could not save \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func CreateTestRuns(sender: UIButton) {
        
        
    }
}
