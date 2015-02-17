//
//  RunHelper.swift
//  Runner app
//
//  Created by Jonathan Holm on 17/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation

class RunHelper {
    
    enum Status: Int {
        case Scheduled = 0, Started, Completed, Running
    }
    
    enum RepeatingStatus: Int {
        case None = 0, Daily, Weekly, Monthly
    }
    
    class func CreateRescheduling(completedRun: Run) {
        
        //TODO: Create schedule run if the incoming run has RepeatingStatus != None.
    }
}