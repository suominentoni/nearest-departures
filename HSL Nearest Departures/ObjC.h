//
//  ObjC.h
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 04/10/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

#ifndef ObjC_h
#define ObjC_h

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end

#endif /* ObjC_h */
