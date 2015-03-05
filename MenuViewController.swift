//
//  MenuViewController.swift
//  Runner app
//
//  Created by Emil Lygnebrandt on 19/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData
protocol ScheduleRunsFirstViewControllerDelegate{
    func updateScheduleRunsTable()
}

class MenuViewController: UIViewController, ScheduleRunsViewControllerDelegate {
    
    var delegate: ScheduleRunsViewControllerDelegate! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "quickstart" {
            
            //Saves Run to CoreData
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: managedContext)
            let run = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as Run
            
            let timeAsString = NSDate().description
            let stringLength = countElements(timeAsString)
            let substringIndex = 10 //Ensures that Year, Month and day will be shown
            
            run.name = "Quickstart " + timeAsString.substringToIndex(advance(timeAsString.startIndex, substringIndex))
            run.startDate = NSDate()
            run.status = RunHelper.Status.Scheduled.rawValue
            run.repeatingStatus = RunHelper.RepeatingStatus.None.rawValue
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save/schedule run")
            }
            
            //Sends Objet to ActiveRun
            let popup = segue.destinationViewController as ActiveRunViewController
            popup.runToShow = run
            popup.delegate = self
        }
        else{
            let popup = segue.destinationViewController as ScheduleARunViewController
            popup.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateScheduleRunsTable() {
        self.dismissViewControllerAnimated(false, completion: nil)
        delegate.updateScheduleRunsTable()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
