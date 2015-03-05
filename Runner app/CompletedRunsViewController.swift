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
    
    var runs = [Run]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTable()
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
        updateTable()
        self.tableView.reloadData()
    }
    
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
    
    func updateTable(){
        runs.removeAll(keepCapacity: false)
        runs = RunHelper.GetCompletedRuns()
    }
}

