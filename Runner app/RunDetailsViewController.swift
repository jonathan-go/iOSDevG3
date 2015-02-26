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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backBtnClick(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
