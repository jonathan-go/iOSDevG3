//
//  ActiveRunViewController.swift
//  Runner app
//
//  Created by Jonathan Holm on 06/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import MapKit

class ActiveRunViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnStartPause: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    
    var runToShow: Run?
    
    private var timer = NSTimer()
    private var startTime = NSTimeInterval()
    private var savedTime = NSTimeInterval()
    
    private var running: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let location = CLLocationCoordinate2D(
            latitude: 57.7802479, longitude: 14.161728)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func updateTime() {
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = (currentTime - startTime) + savedTime
        
        let hours = UInt8(elapsedTime / 3600)
        elapsedTime = elapsedTime - NSTimeInterval(hours) * 3600
        let minutes = UInt8(elapsedTime / 60)
        elapsedTime = elapsedTime - NSTimeInterval(minutes) * 60
        let seconds = UInt8(elapsedTime)
        
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
            // Start
            btnStartPause.setTitle("Pause", forState: .Normal)
            running = true
            
            let updateSelector: Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: updateSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
            
        } else {
            // Pause
            btnStartPause.setTitle("Start", forState: .Normal)
            running = false
            
            timer.invalidate()
            var currentTime = NSDate.timeIntervalSinceReferenceDate()
            savedTime = (currentTime - startTime) + savedTime
        }
    }
    
    @IBAction func stopBtnClick(sender: UIButton) {
        
        btnStartPause.setTitle("Start", forState: .Normal)
        running = false
        btnStartPause.enabled = false
        btnStop.enabled = false
        
        timer.invalidate()
    }
}
