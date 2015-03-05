//
//  PauseLocation.swift
//  Runner app
//
//  Created by Elias Nilsson on 05/03/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation
import CoreData

class PauseLocation: NSManagedObject {

    @NSManaged var timestamp: NSDate
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var run: Runner_app.Run

}
