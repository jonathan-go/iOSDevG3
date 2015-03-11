//
//  ScheduleARunViewController.swift
//  Runner app
//
//  Created by Alexander Lagerqvist on 17/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

protocol ScheduleRunsViewControllerDelegate{
    func updateScheduleRunsTable()
}

// This class handles the Schedule run view, which is used to schedule a run
class ScheduleARunViewController: UIViewController , CLLocationManagerDelegate, WeatherHelperDelegate{
    
    var delegate: ScheduleRunsViewControllerDelegate! = nil
    var locationManager = CLLocationManager()
    var longitude = ""
    var latitude = ""
    var date = NSDate()
    var imageCode = "no_weather"

    @IBOutlet weak var txtbox_RunName: UITextField!
    @IBOutlet weak var uiDatePicker_RunDate: UIDatePicker!
    @IBOutlet weak var UISegCon_Repeat: UISegmentedControl!
    @IBOutlet weak var ImageView_Map: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func dateChanged(sender: AnyObject) {
        var imagecode = ""
        date = datePicker.date
        if longitude != "" && latitude != ""{
            WeatherHelper.getImagecodeFromApi(date, longitude: longitude, latitude: latitude, delegate: self)
        }
    }
    
    func updateWeatherImage(imagecode: String) {
        println(imagecode)
        let image = WeatherHelper.getWeatherImage(imagecode)
        println(image)
        ImageView_Map.image = WeatherHelper.getWeatherImage(imagecode)
        imageCode = imagecode
        
    }
    
    // starts to update location
    // - Emil Lygnebrandt
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
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
    //Alexander Lagerqvist
    func saveScheduledRunToCoreData(runName: String, runDate: NSDate, runRepeatMode: Int){
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: managedContext)
        let run = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as Run

        //Translates the repeating status from the UI to the RunHelper class
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
        //Fills the run object with data
        run.name = runName
        run.startDate = runDate
        run.status = RunHelper.Status.Scheduled.rawValue
        run.weather = imageCode
        
        //Saves the run to CoreData
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
    
    // update location and assing to varaiables and the call getImageCodeFromApi
    // - Emil Lygnebrandt
    //
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        longitude = locationManager.location.coordinate.longitude.description
        latitude = locationManager.location.coordinate.latitude.description
        date = datePicker.date
        if longitude != "" && latitude != ""{
            WeatherHelper.getImagecodeFromApi(date, longitude: longitude, latitude: latitude, delegate: self)
        }
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
