//
//  ObjectiveCException.m
//  Live
//
//  Created by Denis Bohm on 10/15/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

#import "ObjectiveCException.h"

@implementation ObjectiveCException

+ (BOOL)catch:(void(^)())block error:(__autoreleasing NSError **)error {
    @try {
        block();
    } @catch (NSException *exception) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
        [userInfo setValue:exception.reason forKey:NSLocalizedDescriptionKey];
        [userInfo setValue:exception.name forKey:NSUnderlyingErrorKey];
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:userInfo];
        return NO;
    }
    return YES;
}

@end
