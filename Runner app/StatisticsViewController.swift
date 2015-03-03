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
    
    func getDateFromString(date: String) -> NSDate {
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let d = dateStringFormatter.dateFromString(date)
        return NSDate(timeInterval: 0, sinceDate: d!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func gatherStatistics() {
        
        var runs = RunHelper.GetCompletedRuns()
        
        // Gather the statistics from the runs
        var tDistance: Int = 0
        var avgSpeed: Float = 0.0
        var tTime: Int = 0
        var timePerWeek: Int = 0
        var completedRuns: Int = runs.count
        
        var weekTime: [String : (Int, Int)] = [String : (Int, Int)]()
        
        for item in runs {
            // Distance
            let dDistance = Float(item.distance.intValue)
            let dTime = Float(item.savedTime.intValue / 60) // saved in minutes
            avgSpeed += dDistance/dTime
            
            let calendar = NSCalendar.currentCalendar()
            let year = calendar.component(NSCalendarUnit.CalendarUnitYear, fromDate: item.startDate)
            let week = calendar.component(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: item.startDate)
            if let index = weekTime.indexForKey("\(year)\(week)") {
                // CONTINUE
            } else {
                // CONTINUE
            }
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
