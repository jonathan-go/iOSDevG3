//
//  MenuViewController.swift
//  Runner app
//
//  Created by Emil Lygnebrandt on 19/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit
protocol ScheduleRunsFirstViewControllerDelegate{
    func updateScheduleRunsTable()
}
class MenuViewController: UIViewController, ScheduleRunsViewControllerDelegate {
    
    var delegate: ScheduleRunsViewControllerDelegate! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let popup = segue.destinationViewController as ScheduleARunViewController
        popup.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateScheduleRunsTable() {
        delegate.updateScheduleRunsTable()
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
