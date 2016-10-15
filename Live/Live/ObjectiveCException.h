//
//  ObjectiveCException.h
//  Live
//
//  Created by Denis Bohm on 10/15/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectiveCException : NSObject

+ (BOOL)catch:(void(^)())block error:(__autoreleasing NSError **)error;

@end
