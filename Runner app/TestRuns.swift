//
//  TestRuns.swift
//  Runner app
//
//  Created by Emil Lygnebrandt on 06/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import UIKit

class TestRuns: NSObject {
    var name: String
    var date: String
   
    init(newname: String, newdate: String){
        self.name = newname
        self.date = newdate
        super.init()
    }
}
