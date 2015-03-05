//
//  StatisticsViewController.swift
//  Runner app
//
//  Created by Jonathan Holm on 17/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var diagramView: UIView!
    @IBOutlet weak var lblTDistance: UILabel!
    @IBOutlet weak var lblAvgSpeed: UILabel!
    @IBOutlet weak var lblTTime: UILabel!
    @IBOutlet weak var lblTimePerWeek: UILabel!
    @IBOutlet weak var lblCompRuns: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gatherStatistics()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        gatherStatistics()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func gatherStatistics() {
        
        var runs: [Run] = RunHelper.GetCompletedRuns()
        // Gather the statistics from the runs
        var tDistance: Int = 0
        var avgSpeed: Float = 0.0
        var tTime: Int = 0
        var timePerWeek: Int = 0
        var completedRuns: Int = runs.count
        
        var weekTime: [String : Int] = [String : Int]()
        
        println(runs.count)
        for item in runs {
            // Distance
            let dDistance = Float(item.distance.intValue)
            let dTime = Float(item.savedTime.intValue / 60) // saved in minutes
            avgSpeed += dDistance/item.savedTime.floatValue
            
            let calendar = NSCalendar.currentCalendar()
            let year = calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: item.startDate)
            let week = calendar.component(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: item.startDate)
            if let value = weekTime["\(year)\(week)"] {
                weekTime["\(year)\(week)"] = value + Int(dTime)
            } else {
                weekTime["\(year)\(week)"] = Int(dTime)
            }
            
            tDistance += Int(dDistance)
            tTime += Int(dTime)
        }
        
        if tDistance > 1000 {
            lblTDistance.text = String(format: "%.2f", Float(tDistance)/1000.0) + "km"
        } else {
            lblTDistance.text = String(tDistance) + "m"
        }
        
        if completedRuns > 0 {
            lblAvgSpeed.text = String(format: "%.2f", avgSpeed/Float(completedRuns)) + "m/s"
        } else {
            lblAvgSpeed.text = "0m/s"
        }
        
        let hours = tTime/60
        if hours > 0 {
            lblTTime.text = "\(hours) hours and \(tTime - (hours * 60)) minutes"
        } else {
            lblTTime.text = "\(tTime) minutes"
        }
        lblCompRuns.text = "\(completedRuns) runs"
        
        for item in weekTime {
            timePerWeek += item.1
        }
        if weekTime.count > 0 {
            lblTimePerWeek.text = "\(timePerWeek/weekTime.count) minutes/week"
        } else {
            lblTimePerWeek.text = "0 minutes/week"
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
