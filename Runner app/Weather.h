//
//  Weather.h
//  Runner app
//
//  Created by Jonathan Holm on 06/02/15.
//  Copyright (c) 2015 iOSGroup3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Run;

@interface Weather : NSManagedObject

@property (nonatomic, retain) NSData * icon;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) Run *weather_run;

@end
