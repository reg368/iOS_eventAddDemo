//
//  EventVO.h
//  eventAddDemo
//
//  Created by t00javateam@gmail.com on 2016/6/1.
//  Copyright © 2016年 t00javateam@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface EventVO : NSManagedObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSDate *date;

@end

