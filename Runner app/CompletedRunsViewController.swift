//
//  SecondViewController.swift
//  Runner app
//
//  Created by Jonathan Holm on 29/01/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
import CoreData

class CompletedRunsViewController: UITableViewController {
    
    @IBOutlet weak var lbl_searchDate: UILabel!
    
    @IBAction func btn_IncMonth(sender: AnyObject) {
        if(currIncDecVal < 0)
        {
            currIncDecVal += 1
            updateSelectedDate()
        }
        
    }
    @IBAction func btn_DecMonth(sender: AnyObject) {
        currIncDecVal -= 1
        updateSelectedDate()
    }
    
    var runs = [Run]()
    var currIncDecVal = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedDate()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("RunDetailsViewController") as RunDetailsViewController
        viewController.runToShow = runs[indexPath.row]
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedDate()
        self.tableView.reloadData()
    }
    
    //  assing data to the cells
    // - Emil Lygnebrandt
    //
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CompletedRunCell") as UITableViewCell
        
        let run = runs[indexPath.row] as Run
        if let namelbl = cell.viewWithTag(100) as? UILabel{
            namelbl.text = run.name
        }
        if let datelbl = cell.viewWithTag(101) as? UILabel{
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = ("yyyy-MM-dd")
            let stringDate: String = formatter.stringFromDate(run.startDate)
            datelbl.text = stringDate
        }
        // Jonathan fixed
        if let distancelbl = cell.viewWithTag(102) as? UILabel{
            if run.distance.intValue < 1000 {
                distancelbl.text = "\(run.distance.intValue)m"
            } else {
                distancelbl.text = String(format: "%.2f", run.distance.floatValue/1000.0) + "km"
            }
        }
        if let weatherBox = cell.viewWithTag(103) as? UIImageView{
            //weatherBox.image = UIImage(named: "chance_of_storm")
//            var image = WeatherHelper.getWeatherImage("02d")
//            weatherBox.image = image
            if let iconForWeather = run.weather {
                weatherBox.image = WeatherHelper.getWeatherImage(iconForWeather)
            }
        }
        
        return cell
    }
    
    //Handles the dateSelection
    //Alexander Lagerqvist
    func updateSelectedDate() {
        
        //Creates a string that shows month and year for the selectedDate
        let date = NSDate()
        let dateComp = NSDateComponents()
        dateComp.month = currIncDecVal
        let calendar = NSCalendar.currentCalendar()
        let selectedDate = calendar.dateByAddingComponents(dateComp, toDate: date, options: NSCalendarOptions(0) )
        
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = ("MMMM yyyy")
        let stringDate: String = formatter.stringFromDate(selectedDate!)
        
        //Change the date label to the current date using year-month format
        lbl_searchDate.text = stringDate
        
        //Sets the end of the month by using NSDateComponents, By setting zero'th day of the next month gives you the last day of the selected month
        let dateCompEnd = calendar.components( NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit, fromDate: selectedDate!)
        dateCompEnd.month += 1
        dateCompEnd.day = 0
        dateCompEnd.hour = 23
        dateCompEnd.minute = 59
        dateCompEnd.second = 59
        
        //Sets the start of the month using NSDateComponents
        let dateCompStart = calendar.components( NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: selectedDate!)
        dateCompStart.day = 1
        dateCompStart.hour = 0
        dateCompStart.minute = 0
        dateCompStart.second = 0
        
        //Turns the date components into NSDates
        let endOfMonthDate = calendar.dateFromComponents(dateCompEnd)
        let startOfMonthDate = calendar.dateFromComponents(dateCompStart)
        
        //Removes everything inside the array to prevent duplicates
        runs.removeAll(keepCapacity: false)
        
        //Gets the completed runs between the two dates
        runs = RunHelper.GetCompletedRunsBetweenDates(startOfMonthDate!, secondDate: endOfMonthDate!)
        
        //Refreshes the table to show the new data
        self.tableView.reloadData()
        
    }
}

