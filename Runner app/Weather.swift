//
//  Weather.swift
//  Runner app
//
//  Created by Elias Nilsson on 30/01/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation
import CoreData

class Weather: NSManagedObject {

    @NSManaged var icon: NSData
    @NSManaged var temperature: NSNumber

}
