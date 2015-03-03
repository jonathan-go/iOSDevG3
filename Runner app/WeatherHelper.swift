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

protocol WeatherHelperDelegate{
    func updateWeatherImage(imagecode: String)
}

class WeatherHelper {
    
    var delegate: WeatherHelperDelegate! = nil
    
    class func getWeatherImage(imagecode: String) -> UIImage {
        
        var image = UIImage(named: imagecode + ".png")
        if image == nil {
            image = UIImage(named: "no_weather")
        }
        return image!
    }
    
    class func getImagecodeFromApi(requestedDate: NSDate, longitude: String, latitude: String, delegate: WeatherHelperDelegate) {
        let todaysDate = NSDate()
        let daysBetween = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: todaysDate, toDate: requestedDate, options: NSCalendarOptions(0))

        if daysBetween.day == 0{
            daysBetween.day = 1
        }
        if daysBetween.day < 16 && daysBetween.day > 0
        {
            let url: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&cnt=\(daysBetween.day)&mode=json")!
            println(url)
            
            let session = NSURLSession.sharedSession()
            let datatask = session.dataTaskWithURL(url, completionHandler:{
                data, response, error -> Void in
                
                var errorForJson: NSError?
                let jsonData: NSData = data
                if let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &errorForJson) as? NSDictionary{
                
                var info: NSArray = jsonDict.valueForKey("list") as NSArray
                
                var weatherInfo: NSArray = info.valueForKey("weather") as NSArray
                
                if let weatherArr = weatherInfo.objectAtIndex(weatherInfo.count - 1) as? NSArray{
                    if let dict = weatherArr.objectAtIndex(weatherArr.count - 1) as? NSDictionary{
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