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
    @IBOutlet weak var lblPace: UILabel!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    var runToShow: Run?
    var runStartDate: NSDate?
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var myPauseLocations: [CLLocation] = []
    
    var delegate: ScheduleRunsViewControllerDelegate! = nil
    
    private var timer = NSTimer()
    private var startTime = NSTimeInterval()
    private var savedTime = NSTimeInterval()
    private var distance = 0.0
    
    private var running: Bool = false
    private var paused: Bool = false
    
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
        // Do any additional setup after loading the view
        
        btnStop.enabled = false
        
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
        
//        if(delegate != nil){
//            delegate.updateScheduleRunsTable()
//        }
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
    
    
    /////////
    //  Fires when location is updated and appends them to an array of locations. Creates a polyline of the travelled distance and adds it to the map.
    //  - Elias Nilsson
    /////////
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        myLocations.append(locations[0] as CLLocation)
        
        let spanX = 0.01
        let spanY = 0.01
        var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
        
        if (locations[0].horizontalAccuracy < 20) {
            if (myLocations.count > 1 && running){
                if(!paused){
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
                    paused = false
                }
                }
            }
    }
    
    
    
    /////////
    //  Renders the polyline to the map overlay.
    //  - Elias Nilsson
    /////////
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: 62/255.0, green: 228/255.0, blue: 157/255.0, alpha: 1.0)
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
    
    /////////
    //  Takes a distance between to locations and adds it to the total distance.
    //  - Elias Nilsson
    /////////
    func updateDistance(dist: CLLocationDistance){
        distance += dist
        if (distance < 1000){
            updateDistanceLabel(distance, meter: true)
        }
        else if (distance > 1000){
            updateDistanceLabel(distance, meter: false)
        }
    }
    
    /////////
    //  Updates the distance label. Depending on the distance it will be displayed in either meter or km.
    //  - Elias Nilsson
    /////////
    func updateDistanceLabel(dist: Double, meter: Bool) {
        if(meter){
            lblDistance.text = String(Int(dist)) + "m"
        }
        else {
            lblDistance.text = String(format: "%.2f", dist/1000) + "km"
        }
        
        updatePace(dist)
    }
    
    /////////
    //  Calculates and updates the pace label (minutes per kilometer)
    //  - Elias Nilsson
    /////////
    func updatePace(dist: Double) {
        if (dist > 50){
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            let elapsedTime: NSTimeInterval = (currentTime - startTime) + savedTime
            let mps = dist/elapsedTime
            let minpkm = 16.6667 * (16.6667/(mps*16.6667))
            
            let tot = Int(minpkm*100)
            let min = tot/100
            let sec = Int(Double(tot - (min*100))/100 * 60)

            lblPace.text = String(format: "%02d:%02d", min, sec) + "/km"
        }
        
    }
    
    /////////
    //  Starts the tracking and disables the back button to prevent the user from stopping the tracking.
    //  - Elias Nilsson
    /////////
    func startMap() {
        manager.startUpdatingLocation()
        btnBack.enabled = false
    }
    
    /////////
    //  Stops the tracking and appends the last location to a seperate array to keep track of the "pause locations".
    //  - Elias Nilsson
    /////////
    func pauseMap(){
        manager.stopUpdatingLocation()
        paused = true
        let loc = myLocations[myLocations.endIndex-1]
        myPauseLocations.append(loc as CLLocation)
    }
    
    /////////
    //  Stops the tracking and zooms the map to fit the plotted route.
    //  - Elias Nilsson
    /////////
    func stopMap() {
        manager.stopUpdatingLocation()
        btnBack.enabled = true
        
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
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: true)
        
        var startPin = MKPointAnnotation()
        startPin.coordinate = myLocations[0].coordinate
        startPin.title = "Start"
            
        var finishPin = MKPointAnnotation()
        finishPin.coordinate = myLocations[myLocations.endIndex-1].coordinate
        finishPin.title = "Finish"
            
        mapView.addAnnotation(startPin)
        mapView.addAnnotation(finishPin)
        
        saveRoute()
    }
    
    
    /////////
    //  Saves an array or locations (latitude, longitude and timestamp) to coreData.
    //  - Elias Nilsson
    /////////
    func saveRoute(){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var locArr: NSMutableArray = []
        for location in myLocations{
            let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedContext)
            let locationObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as Location
            
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            locationObject.timestamp = location.timestamp
            locArr.addObject(locationObject)
        }
        
        var pauseLocArr: NSMutableArray = []
        for pauseLoc in myPauseLocations {
            let entity = NSEntityDescription.entityForName("PauseLocation", inManagedObjectContext: managedContext)
            let locationObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as PauseLocation
            
            locationObject.latitude = pauseLoc.coordinate.latitude
            locationObject.longitude = pauseLoc.coordinate.longitude
            locationObject.timestamp = pauseLoc.timestamp
            pauseLocArr.addObject(locationObject)
        }
        
        runToShow?.pace = lblPace.text!
        runToShow?.distance = distance
        let locSet = NSSet(array: locArr)
        let pauSet = NSSet(array: pauseLocArr)
        runToShow?.locations = locSet
        runToShow?.pauseLocations = pauSet
        
        saveRun()
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
            btnStop.enabled = true
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
        
        //Creates a Copy of the current run and saves it to CoreData, whilst changing some values
        if (runToShow?.status == RunHelper.Status.Completed.rawValue)
        {
            var copyRun = runToShow
            copyRun?.startDate = runStartDate!
            copyRun?.repeatingStatus = RunHelper.RepeatingStatus.None.rawValue
            
            var error: NSError?
            if !copyRun!.managedObjectContext!.save(&error) {
                println("Could not save \(error)")
            }
            
        }
        else{
            var error: NSError?
            if !runToShow!.managedObjectContext!.save(&error) {
                println("Could not save \(error)")
            }
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
        
        //Sets the date when the run started, Assuming that lastResumeDate is nil when a run is about to start
        if( runToShow?.lastResumeDate == nil)
        {
            runStartDate = NSDate()
        }
        
        btnStartPause.setTitle("Pause", forState: .Normal)
        running = true
        
        let updateSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: updateSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        
        runToShow?.savedTime = savedTime
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
        if delegate != nil {
            delegate.updateScheduleRunsTable()
        }
    }
}
