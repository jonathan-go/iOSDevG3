//
//  WeatherHelper.swift
//  Runner app
//
//  Created by Emil Lygnebrandt on 20/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class WeatherHelper {
    
//    enum Weather: String {
//        case Clear_sky = "01d.png", Few_clouds = "02d.png", Scattered_clouds = "03d.png", Broken_clouds = "04d.png",
//        Shower_rain = "09d.png", Rain = "10d.png", Thunderstorm = "11d.png", Snow = "13d.png", Mist = "50d.png"
    
    class func getWeatherImage(imagecode: String) -> UIImage {
        
        var image = UIImage()
        image = UIImage(named: imagecode + ".png")!
        return image
    }
    
    class func getImagecodeFromApi(requestedDate: NSDate, location: String) -> String {
        let todaysDate = NSDate()
        let daysBetween = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: todaysDate, toDate: requestedDate, options: NSCalendarOptions(0))
        //daysBetween.day dagar emellan
        return ""
    }
    
}