//
//  ActiveRunViewController.swift
//  Runner app
//
//  Created by Jonathan Holm on 06/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ActiveRunViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnStartPause: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    
    var runToShow: Run?
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    private var timer = NSTimer()
    private var startTime = NSTimeInterval()
    private var savedTime = NSTimeInterval()
    private var distance = 0.0
    
    private var running: Bool = false
    private var pauseLocation: Bool = false
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Test Run
        /*let newItem = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: self.managedObjectContext!) as Run
        runToShow = newItem
        
        runToShow?.name = "Testrun OAOAOA"
        runToShow?.distance = 12
        runToShow?.startDate = getDateFromString("2015-02-13 09:00")
        runToShow?.lastResumeDate = getDateFromString("2015-02-13 10:30")
        runToShow?.savedTime = Double(600.0)*/
        
        /*var error: NSError?
        if !runToShow!.managedObjectContext!.save(&error) {
        println("Could not save \(error)")
        }*/
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.activityType = .Fitness
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        
        
        // Initialize time with values.
        startTime = NSDate.timeIntervalSinceReferenceDate()
        savedTime = savedTime + runToShow!.savedTime.doubleValue
        if runToShow?.status == RunHelper.Status.Running.rawValue {
            var startDateSavedTime = NSDate().timeIntervalSinceDate(runToShow!.lastResumeDate)
            savedTime = savedTime + startDateSavedTime
            startTimer()
        }
        updateTime()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDateFromString(date: String) -> NSDate {
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let d = dateStringFormatter.dateFromString(date)
        return NSDate(timeInterval: 0, sinceDate: d!)
    }
    
      
    //Fires when location is updated and appends them to an array of locations
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        myLocations.append(locations[0] as CLLocation)
        
        let spanX = 0.01
        let spanY = 0.01
        var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
        
        if (locations[0].horizontalAccuracy < 20) {
            if (myLocations.count > 1 && running){
                if(!pauseLocation){
                    var sourceIndex = myLocations.count - 1
                    var destinationIndex = myLocations.count - 2
                    
                    let c1 = myLocations[sourceIndex].coordinate
                    let c2 = myLocations[destinationIndex].coordinate
                    let distanceChunk: CLLocationDistance = myLocations[sourceIndex].distanceFromLocation(myLocations[destinationIndex])
                    updateDistance(distanceChunk)
                    var a = [c1, c2]
                    var polyline = MKPolyline(coordinates: &a, count: a.count)
                    mapView.addOverlay(polyline)
                }
                else {
                    pauseLocation = false
                }
            }
        }
    }
    
    //Draws a polyline to display the route
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }
    
    //Updates the total distance and displays it
    func updateDistance(dist: CLLocationDistance){
        distance += dist
        if (distance < 1000){
            let distInMeter = String(Int(distance)) + "m"
            lblDistance.text = distInMeter
        }
        else if (distance > 1000){
            let distInKm = distance/1000
            lblDistance.text = String(format: "%.2f",distInKm) + "km"
        }
    }
    
    
    func startMap() {
        manager.startUpdatingLocation()
    }
    func pauseMap(){
        manager.stopUpdatingLocation()
        pauseLocation = true
    }
    
    //Stops the tracking
    func stopMap() {
        manager.stopUpdatingLocation()
        
        
        //Will zoom the map to fit the route
        var zoomRect: MKMapRect = MKMapRectNull
        
        for location in myLocations {
            let locPoint: MKMapPoint = MKMapPointForCoordinate(location.coordinate)
            let locRect: MKMapRect = MKMapRectMake(locPoint.x, locPoint.y, 0, 0)
            
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = locRect
            }
            else {
                zoomRect = MKMapRectUnion(zoomRect, locRect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(10, 10, 10, 10), animated: true)
    }
    
    
    func updateTime() {
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = (currentTime - startTime) + savedTime
        
        let hours = Int32(elapsedTime / 3600)
        elapsedTime = elapsedTime - NSTimeInterval(hours) * 3600
        let minutes = Int32(elapsedTime / 60)
        elapsedTime = elapsedTime - NSTimeInterval(minutes) * 60
        let seconds = Int32(elapsedTime)
        
        let minutesString = minutes <= 9 ? "0" + String(minutes) : String(minutes)
        let secondsString = seconds <= 9 ? "0" + String(seconds) : String(seconds)
        
        if (hours > 0) {
            lblTime.text = "\(hours):\(minutesString):\(secondsString)"
        } else {
            lblTime.text = "\(minutesString):\(secondsString)"
        }
    }
    
    @IBAction func startPauseBtnClick(sender: UIButton) {
        
        if (!running) {
            startTimer()
            startMap()
        } else {
            pauseMap()
            pauseTimer(true)
        }
    }
    
    @IBAction func stopBtnClick(sender: UIButton) {
        stopTimer()
        stopMap()
    }
    
    func saveRun() {
        
        var error: NSError?
        if !runToShow!.managedObjectContext!.save(&error) {
            println("Could not save \(error)")
        }
    }
    
    
    
    func pauseTimer(save: Bool) {
        
        btnStartPause.setTitle("Start", forState: .Normal)
        running = false
        
        timer.invalidate()
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        savedTime = (currentTime - startTime) + savedTime
        
        runToShow?.savedTime = savedTime
        runToShow?.status = RunHelper.Status.Started.rawValue
        
        
        if save {
            saveRun()
        }
    }
    
    func startTimer() {
        
        btnStartPause.setTitle("Pause", forState: .Normal)
        running = true
        
        let updateSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: updateSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        
        runToShow?.lastResumeDate = NSDate()
        runToShow?.status = RunHelper.Status.Running.rawValue
        saveRun()
    }
    
    func stopTimer() {
        
        if running {
            pauseTimer(false)
        }
        btnStartPause.enabled = false
        btnStop.enabled = false
        
        runToShow?.status = RunHelper.Status.Completed.rawValue
        RunHelper.CreateRescheduling(runToShow!)
        saveRun()
    }
    
    
    
    @IBAction func backButtonClick(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
