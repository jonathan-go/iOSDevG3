//
//  FirstViewController.swift
//  Runner app
//
//  Created by Jonathan Holm on 29/01/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData

class ScheduleRunsViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    var runs = [Run]()
    
    
    //Test data
    //let runs = ["New York Marathon - Mon 13th", "Jönköping - Fri 6th", "Världen runt - 2014"]
    
    //let runs = [ TestRuns(newname: "New York Marathon", newdate: "06-02-2015"), TestRuns(newname: "Vetter rundan", newdate: "12-06-2015")]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        let fetchRequest = NSFetchRequest(entityName: "Run")
//        var error: NSError?
//        
//        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [Run]?
//        
//        if let results = fetchedResults{
//            runs = results
//        } else{
//            println("Could not fetch \(error), \(error!.userInfo)")
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addMenuSegue" {
            let popoverViewController = segue.destinationViewController as UIViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("runCell") as UITableViewCell
        
//        let run = runs[indexPath.row] as Run
//        if let namelbl = cell.viewWithTag(100) as? UILabel{
//            namelbl.text = run.name
//        }
        return cell
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

}

