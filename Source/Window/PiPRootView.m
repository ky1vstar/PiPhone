//
//  PiPRootView.m
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPRootView.h"

@implementation PiPRootView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    return hitView == self ? nil : hitView;
}

@end
