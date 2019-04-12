//
//  NSObject+PiPhone.m
//  PiPhone
//
//  Created by KY1VSTAR on 12.04.2019.
//

#import "NSObject+PiPhone.h"

@implementation NSObject (PiPhone)

- (id)ifNullThenNil {
    return self;
}

@end

@interface NSNull (PiPhone)
@end

@implementation NSNull (PiPhone)

- (instancetype)ifNullThenNil {
    return nil;
}

@end
