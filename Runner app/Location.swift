//
//  Location.swift
//  Runner app
//
//  Created by Elias Nilsson on 20/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var timestamp: NSDate

}
