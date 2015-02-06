//
//  Run.h
//  Runner app
//
//  Created by Jonathan Holm on 06/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weather;

@interface Run : NSManagedObject

@property (nonatomic, retain) NSNumber * averageSpeed;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * fromLocation;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * route;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * stopDate;
@property (nonatomic, retain) NSNumber * toLocation;
@property (nonatomic, retain) Weather *run_weather;

@end
