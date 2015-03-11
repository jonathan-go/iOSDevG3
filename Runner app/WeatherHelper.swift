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
protocol UpdateWeatherIconsDelegate{
    func updateWeatherIcons(iconArray: [String])
}

class WeatherHelper {
    
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

        println(daysBetween.day)
        if daysBetween.day == 0 {
            daysBetween.day = 1
        }
        else {
            daysBetween.day = daysBetween.day + 1
        }
        if daysBetween.day < 16 && daysBetween.day > 0
        {
            let url: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&cnt=\(daysBetween.day)&mode=json")!
            println(url)
            
            let session = NSURLSession.sharedSession()
            let datatask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error -> Void in
                
                var errorForJson: NSError?
                let jsonData: NSData = data
                if let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &errorForJson) as? NSDictionary {
                
                var info: NSArray = jsonDict.valueForKey("list") as NSArray
                
                var weatherInfo: NSArray = info.valueForKey("weather") as NSArray
                
                if let weatherArr = weatherInfo.objectAtIndex(weatherInfo.count - 1) as? NSArray {
                    if let dict = weatherArr.objectAtIndex(weatherArr.count - 1) as? NSDictionary {
                        var imageCodeFromJson = dict.valueForKey("icon") as String
                        //println(imageCodeFromJson)
                        let findString = (imageCodeFromJson as NSString).containsString("n")
                        
                        if findString {
                            imageCodeFromJson = dropLast(imageCodeFromJson)
                            imageCodeFromJson = imageCodeFromJson + "d"
                        }
                        //println(imageCodeFromJson)
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            delegate.updateWeatherImage(imageCodeFromJson)
                        }
                    }
                }
                }
                if let error = error {
                    println("fel")
                }
            })
            datatask.resume()
        }
        else{
            delegate.updateWeatherImage("no_weather")
        }
    }
    
    class func updateWeatherIcons(longitude: String, latitude: String, delegate: UpdateWeatherIconsDelegate) {
    
        let todaysDate = NSDate()
        
        let url: NSURL = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&cnt=16&mode=json")!
        //println(url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
            
            var errorForJson: NSError?
            let jsonData: NSData = data
            var iconArray: [String] = [String]()
            if let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &errorForJson) as? NSDictionary {
                
                var info: NSArray = jsonDict.valueForKey("list") as NSArray
                //println(info)
                var weatherInfo: NSArray = info.valueForKey("weather") as NSArray
                
                for var i = 0 ; i < weatherInfo.count ; i++ {
                    if let weatherArr = weatherInfo.objectAtIndex(i) as? NSArray {
                        if let dict = weatherArr.objectAtIndex(0) as? NSDictionary {
                            var imageCodeFromJson = dict.valueForKey("icon") as String
                            let findString = (imageCodeFromJson as NSString).containsString("n")
                            
                            if findString{
                                imageCodeFromJson = dropLast(imageCodeFromJson)
                                imageCodeFromJson = imageCodeFromJson + "d"
                            }
                            iconArray.append(imageCodeFromJson)
                        }
                    }
                }
            }
            //println(iconArray)
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                delegate.updateWeatherIcons(iconArray)
            }
        })
        task.resume()

    }
}