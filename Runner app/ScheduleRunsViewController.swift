//
//  FirstViewController.swift
//  Runner app
//
//  Created by Jonathan Holm on 29/01/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ScheduleRunsViewController: UITableViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, ScheduleRunsViewControllerDelegate, UpdateWeatherIconsDelegate {
    var runs = [Run]()
    var locationManager = CLLocationManager()
    var longitude = ""
    var latitude = ""
    var date = NSDate()
    var newIconsArray: [String] = [String]()
    var updateWeather: Bool = false
    var foundLocation: Bool = false
    //var unsortedRuns = [Run]()


    // Starts to update the weather and updates the table
    // - Emil Lygnebrandt
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        updateTable()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Sends delegate to menuviewcontroller to be sent to scheduleArun
    // - Emil Lygnebrandt
    //
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addMenuSegue" {
            let menuViewController = segue.destinationViewController as MenuViewController
            menuViewController.delegate = self
            menuViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            menuViewController.popoverPresentationController!.delegate = self
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    
    // Removes the run from the table and removes it from Core Data
    // - Elias Nilsson
    //
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(runs[indexPath.row] as NSManagedObject)
            runs.removeAtIndex(indexPath.row)
            managedContext.save(nil)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRun = runs[indexPath.row]
        /*let destinationVC = ActiveRunViewController()
        destinationVC.runToShow = selectedRun
        self.performSegueWithIdentifier("ScheduleToActive", sender: self)*/
        
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("ActiveRunViewController") as ActiveRunViewController
        viewController.runToShow = runs[indexPath.row]
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Assign data to the table cells
    // - Emil Lygnebrandt
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("runCell") as UITableViewCell
        
        let run = runs[indexPath.row] as Run
        if let namelbl = cell.viewWithTag(100) as? UILabel{
            namelbl.text = run.name
        }
        if let datelbl = cell.viewWithTag(101) as? UILabel{
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            let stringDate: String = formatter.stringFromDate(run.startDate)
            datelbl.text = stringDate
        }
        if let weatherBox = cell.viewWithTag(102) as? UIImageView{
            if let iconForWeather = run.weather {
                weatherBox.image = WeatherHelper.getWeatherImage(run.weather!)
            }
        }
        
        return cell
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    // calls updatetable and reloadData
    // - Emil Lygnebrandt
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
         self.tableView.reloadData()
    }
    
    // Delegate function
    // - Emil Lygnebrandt
    //
    func updateScheduleRunsTable() {
        updateTable()
        self.tableView.reloadData()
    }

    // updates the atbleview and rearange runs in order of the date
    // - Emil Lygnebrandt
    //
    func updateTable(){
        runs.removeAll(keepCapacity: false)
        //unsortedRuns.removeAll(keepCapacity: false)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Run")
        var error: NSError?
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [Run]?
        
        if let results = fetchedResults{
            var unsortedRuns = results
            for var i = 0; i < unsortedRuns.count; i++
            {
                if unsortedRuns[i].status != RunHelper.Status.Completed.rawValue
                {
                    if(unsortedRuns[i].status == RunHelper.Status.Running.rawValue || unsortedRuns[i].status == RunHelper.Status.Started.rawValue){
                        runs.append(unsortedRuns[i])
                    }
                }
            }
            for var i = 0; i < unsortedRuns.count; i++
            {
                if unsortedRuns[i].status != RunHelper.Status.Completed.rawValue
                {
                    if(unsortedRuns[i].status != RunHelper.Status.Running.rawValue && unsortedRuns[i].status != RunHelper.Status.Started.rawValue){
                        runs.append(unsortedRuns[i])
                    }
                }
            }
            updateWeatherFunc()
        }
    }
    
    // Assign data to location variables and calls updateweatherfunc
    // - Emil Lygnebrandt
    //
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        longitude = locationManager.location.coordinate.longitude.description
        latitude = locationManager.location.coordinate.latitude.description
        if longitude != "" && latitude != "" && !foundLocation {
            updateWeatherFunc()
            foundLocation = true
        }
    }
    
    // updates the weather images of scheduledruns
    // - Emil Lygnebrandt
    //
    func updateWeatherIcons(iconArray: [String]) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var error: NSError?
        
        //println(iconArray)
        for var i = 0; i < runs.count; i++ {
            let daysBetween = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: date, toDate: runs[i].startDate, options: NSCalendarOptions(0))
            if daysBetween.day < 16 && daysBetween.day > 0 {
                println(daysBetween.day)
                runs[i].weather = iconArray[daysBetween.day]
                println(iconArray[daysBetween.day])
            }
        }
        if !managedContext.save(&error) {
            println("Could not save/schedule run")
        }
        updateTable()
    }
    
    // Calls the weatherhelper to begin update weather icons
    // - Emil Lygnebrandt
    //
    func updateWeatherFunc()  {
        if updateWeather {
            WeatherHelper.updateWeatherIcons(longitude, latitude: latitude, delegate: self)
            updateWeather = false
        }
        else {
            updateWeather = true
        }
    }
}

