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

class ScheduleRunsViewController: UITableViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, ScheduleRunsViewControllerDelegate, WeatherHelperDelegate {
    var runs = [Run]()
    var locationManager = CLLocationManager()
    var longitude = ""
    var latitude = ""
    var date = NSDate()
    //var unsortedRuns = [Run]()

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
            //weatherBox.image = UIImage(named: "chance_of_strom")
            if let iconForWeather = run.weather {
                weatherBox.image = WeatherHelper.getWeatherImage(iconForWeather)
            }
//            date = run.startDate
//            if longitude != "" && latitude != ""{
//                WeatherHelper.getImagecodeFromApi(date, longitude: longitude, latitude: latitude, delegate: self)
//            }
        }
        
        return cell
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateTable()
         self.tableView.reloadData()
    }
    
    func updateScheduleRunsTable() {
        updateTable()
        self.tableView.reloadData()
    }
    
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
        }
    
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        longitude = locationManager.location.coordinate.longitude.description
        latitude = locationManager.location.coordinate.latitude.description
    }
    
    func updateWeatherImage(imagecode: String) {
        println(imagecode)
        let image = WeatherHelper.getWeatherImage(imagecode)
    }

}

