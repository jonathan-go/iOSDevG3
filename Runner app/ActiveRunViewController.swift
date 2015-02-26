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
    
    var delegate: ScheduleRunsViewControllerDelegate! = nil
    
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
        // Do any additional setup after loading the view
        
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
        
        if(delegate != nil){
            delegate.updateScheduleRunsTable()
        }
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
    
    //Updates the total distance
    func updateDistance(dist: CLLocationDistance){
        distance += dist
        if (distance < 1000){
            updateDistanceLabel(distance, meter: true)
        }
        else if (distance > 1000){
            updateDistanceLabel(distance, meter: false)
        }
    }
    
    //Displays the distance, format depends on whether the distance is more or less than a km
    func updateDistanceLabel(dist: Double, meter: Bool) {
        if(meter){
            lblDistance.text = String(Int(dist)) + "m"
        }
        else {
            lblDistance.text = String(format: "%.2f", dist/1000) + "km"
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
        
        saveRoute()
    }
    
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
        
        runToShow?.distance = distance
        let set = NSSet(array: locArr)
        runToShow?.locations = set
        
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
    }
    
    
    
    
    
    
    //%%%%%%%%%%%%%%%%SKA VARA I COMPLETED RUNS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //Loads the coordinates and draws the route on the map
    func loadRoute() {
        var descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let array = runToShow!.locations.sortedArrayUsingDescriptors([descriptor])
        
        if (array.count > 0) {
            var coordArr: [CLLocationCoordinate2D] = []
            
            for location in array {
                let loc = location as Location
                let lat = Double(loc.latitude)
                let long = Double(loc.longitude)
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                coordArr.append(coord)
            }
            
            var zoomRect: MKMapRect = MKMapRectNull
            
            for index in 0...coordArr.count-1 {
                var i = coordArr.count-1 - index
                
                if(i > 0){
                    let c1 = coordArr[i]
                    let c2 = coordArr[i-1]
                    var a = [c1, c2]
                    var polyline = MKPolyline(coordinates: &a, count: a.count)
                    mapView.addOverlay(polyline)
                }
                
                
                
                let locPoint: MKMapPoint = MKMapPointForCoordinate(coordArr[i])
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
        
    }

}
