//
//  RunDetails.swift
//  Runner app
//
//  Created by Jonathan Holm on 26/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import MapKit

class RunDetailsViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAvgSpeed: UILabel!
    @IBOutlet weak var lblPace: UILabel!
    
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    var runToShow: Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = false
        
        // Insert values in all the labels
        lblName.text = runToShow?.name
        
        var distanceInMeters = 0
        if let distance = runToShow?.distance.doubleValue {
            distanceInMeters = Int(distance)
            if distance < 1000 {
                lblDistance.text = String(Int(distance)) + "m"
            } else {
                lblDistance.text = String(format: "%.2f", distance/1000) + "km"
            }
        } else {
            lblDistance.text = "0"
        }
        
        if let pace = runToShow?.pace {
            lblPace.text = pace
        }
        else {
            lblPace.text = "Unknown"
        }
        
        if let date = runToShow?.startDate {
            var formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            lblDate.text = formatter.stringFromDate(date)
        } else {
            lblDate.text = "Unknown"
        }
        
        if let time = runToShow?.savedTime.intValue {
            var calcTime = time
            let hours = Int(time / 3600)
            calcTime -= hours * 3600
            let minutes = Int(time / 60)
            calcTime -= minutes * 60
            
            let minutesString = minutes <= 9 ? "0" + String(minutes) : String(minutes)
            let secondsString = calcTime <= 9 ? "0" + String(calcTime) : String(calcTime)
            
            if hours > 0 {
                lblTime.text = "\(hours):\(minutesString):\(secondsString)"
            } else {
                lblTime.text = "\(minutesString):\(secondsString)"
            }
            
            if distanceInMeters != 0 && Int(time) != 0 {
                
                var first: Float = Float(distanceInMeters)
                var second: Float = Float(Int(time))
                
                var avgSpeed: Float = first/second
                
                let avgSpeedString = String(format: "%.2f", avgSpeed) + "m/s"
                lblAvgSpeed.text = avgSpeedString
            } else {
                lblAvgSpeed.text = "0m/s"
            }
        } else {
            lblAvgSpeed.text = "0m/s"
            lblTime.text = "00:00"
        }
        
        if let imageCode = runToShow?.weather {
            imageWeather.image = WeatherHelper.getWeatherImage(imageCode)
        }
        
        loadRoute()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backBtnClick(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Draws a polyline to display the route
    // CREATED BY ELIAS NILSSON
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: 62/255.0, green: 228/255.0, blue: 157/255.0, alpha: 1.0)
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return nil
    }
    
    
    // CREATED BY ELIAS NILSSON
    //Loads the coordinates and draws the route on the map
    func loadRoute() {
        var descriptor: NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let array = runToShow!.locations.sortedArrayUsingDescriptors([descriptor])
        let pauseArray = runToShow!.pauseLocations.sortedArrayUsingDescriptors([descriptor])
        
        if (array.count > 0) {
            var coordArr: [CLLocationCoordinate2D] = []
            var pauseCoordArr: [CLLocationCoordinate2D] = []
            var pause = false
            
            for location in array {
                let loc = location as Location
                let lat = Double(loc.latitude)
                let long = Double(loc.longitude)
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                coordArr.append(coord)
            }
            
            var zoomRect: MKMapRect = MKMapRectNull
            
            for index in 0...coordArr.count-1 {
                var paused = false
                
                if(index > 0){
                    let c1 = coordArr[index]
                    
                    paused = false
                    for pauseLoc in pauseArray{
                        let loc = pauseLoc as PauseLocation
                        if(c1.latitude == loc.latitude && c1.longitude == loc.longitude){
                            paused = true
                        }
                    }
                    
                    if (!paused)
                    {
                        let c2 = coordArr[index-1]
                        var a = [c1, c2]
                        var polyline = MKPolyline(coordinates: &a, count: a.count)
                        mapView.addOverlay(polyline)
                    }
                }
                
                
                
                let locPoint: MKMapPoint = MKMapPointForCoordinate(coordArr[index])
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
