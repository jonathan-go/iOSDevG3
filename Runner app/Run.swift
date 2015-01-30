//
//  Run.swift
//  Runner app
//
//  Created by Elias Nilsson on 30/01/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var distance: NSNumber
    @NSManaged var startDate: NSDate
    @NSManaged var stopDate: NSDate
    @NSManaged var averageSpeed: NSNumber
    @NSManaged var fromLocation: NSNumber
    @NSManaged var toLocation: NSNumber
    @NSManaged var route: NSData
    @NSManaged var status: NSNumber
    @NSManaged var run_weather: Weather

}
