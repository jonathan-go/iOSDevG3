//
//  ScheduleARunViewController.swift
//  Runner app
//
//  Created by Alexander Lagerqvist on 17/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData

protocol ScheduleRunsViewControllerDelegate{
    func updateScheduleRunsTable()
}
// This class handles the Schedule run view, which is used to schedule a run
class ScheduleARunViewController: UIViewController {
    
    var delegate: ScheduleRunsViewControllerDelegate! = nil

    @IBOutlet weak var txtbox_RunName: UITextField!
    @IBOutlet weak var uiDatePicker_RunDate: UIDatePicker!
    @IBOutlet weak var UISegCon_Repeat: UISegmentedControl!
    @IBOutlet weak var ImageView_Map: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Handles Cancel button. Will dismiss the View if clicked
    @IBAction func btn_scheduleARun_cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Handles Done button. Will schedule the current run
    @IBAction func btn_scheduleARun_done(sender: AnyObject) {
        
        //Get Values from Elements
        let runName = txtbox_RunName.text
        let runDate = uiDatePicker_RunDate.date
        let runRepeatMode = UISegCon_Repeat.selectedSegmentIndex
        let currentDate = NSDate()
        
        //Check Values for invalid values
        if( runName == nil || runName == "")
        {
            //User didnt name run
            createErrorMessage("Name is needed", alertMessage: "Scheduled run is unnamed")
        }
        else if( runDate.compare(currentDate) == NSComparisonResult.OrderedAscending)
        {
            //User tried to set scheduled date before current date
            createErrorMessage("Invalid Date", alertMessage: "Run is scheduled before current date")
        }
        else
        {
            //Save to CoreData
            saveScheduledRunToCoreData(runName, runDate: runDate, runRepeatMode: runRepeatMode)
            self.dismissViewControllerAnimated(true, completion: nil)
            delegate.updateScheduleRunsTable()
        }
        
    }
    
    //Saves the schedule to CoreData
    func saveScheduledRunToCoreData(runName: String, runDate: NSDate, runRepeatMode: Int){
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: managedContext)
        let run = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as Run

        if(runRepeatMode == 0){
            run.repeatingStatus = RunHelper.RepeatingStatus.None.rawValue
        }
        else if(runRepeatMode == 1){
            run.repeatingStatus = RunHelper.RepeatingStatus.Daily.rawValue
        }
        else if(runRepeatMode == 2){
            run.repeatingStatus = RunHelper.RepeatingStatus.Weekly.rawValue
        }
        else if(runRepeatMode == 3){
            run.repeatingStatus = RunHelper.RepeatingStatus.Monthly.rawValue
        }
        else {
            assert(false, "repeating status code is invalid. Terminating in 3...2...1")
        }
        
        run.name = runName
        run.startDate = runDate
        run.status = RunHelper.Status.Scheduled.rawValue
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save/schedule run")
        }
    }

    
    //Creates a popup with the desired tilte and message
    func createErrorMessage(alertTitle: String,alertMessage: String){
        
        var alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
