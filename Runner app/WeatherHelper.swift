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

protocol ScheduleArunDelegate{
    func updateWeatherImage(imagecode: String)
}
class WeatherHelper {
    
    var delegate: ScheduleArunDelegate! = nil
//    enum Weather: String {
//        case Clear_sky = "01d.png", Few_clouds = "02d.png", Scattered_clouds = "03d.png", Broken_clouds = "04d.png",
//        Shower_rain = "09d.png", Rain = "10d.png", Thunderstorm = "11d.png", Snow = "13d.png", Mist = "50d.png"
    
    class func getWeatherImage(imagecode: String) -> UIImage {
        
        var image = UIImage()
        image = UIImage(named: imagecode + ".png")!
        return image
    }
    
    class func getImagecodeFromApi(requestedDate: NSDate, longitude: String, latitude: String, delegate: ScheduleArunDelegate) {
        let todaysDate = NSDate()
        let daysBetween = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: todaysDate, toDate: requestedDate, options: NSCalendarOptions(0))
        if daysBetween.day < 16
        {
            let url: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&cnt=\(daysBetween.day)&mode=json")!
            println(url)
            let session = NSURLSession.sharedSession()
            let datatask = session.dataTaskWithURL(url, completionHandler:{
                data, response, error -> Void in
                
                var errorForJson: NSError?
                let jsonData: NSData = data
                let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &errorForJson) as NSDictionary
                
                var info: NSArray = jsonDict.valueForKey("list") as NSArray
                
                var weatherInfo: NSArray = info.valueForKey("weather") as NSArray
                
                if let weatherArr = weatherInfo.objectAtIndex(0) as? NSArray{
                    if let dict = weatherArr.objectAtIndex(0) as? NSDictionary{
                        var imageCodeFromJson = dict.valueForKey("icon") as String
                        println(imageCodeFromJson)
                        let findString = (imageCodeFromJson as NSString).containsString("n")
                        
                        if findString{
                            imageCodeFromJson = dropLast(imageCodeFromJson)
                            imageCodeFromJson = imageCodeFromJson + "d"
                        }
                        println(imageCodeFromJson)
                        dispatch_async(dispatch_get_main_queue()){ () -> Void in
                            delegate.updateWeatherImage(imageCodeFromJson)
                        }
                        
                    }
                }
                
                if let error = error{
                    println("fel")
                }
            })
            datatask.resume()
        }
        else{
            delegate.updateWeatherImage("no_weather")
        }
    }
    
}