//
//  PiPChevronView.m
//  PiPhone
//
//  Created by KY1VSTAR on 05.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPChevronView.h"

#define kRotationAngle 13.f
#define kAnimationDuration 0.2f

@interface PiPChevronView ()

@property (nonatomic) UIView *topView;
@property (nonatomic) UIView *bottomView;

@end

@implementation PiPChevronView

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 14, 37)]) {
        _state = PiPChevronViewStateNormal;
        [self setup];
    }
    
    return self;
}

- (void)setup {
    // topView
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = UIColor.blackColor;
    _topView.clipsToBounds = YES;
    _topView.layer.cornerRadius = 3.5;
    _topView.layer.anchorPoint = CGPointMake(0.5, 1 - 3.5 / 22);
    _topView.frame = CGRectMake(3.5, 0, 7, 22);
    [self addSubview:_topView];
    
    // bottomView
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = UIColor.blackColor;
    _bottomView.clipsToBounds = YES;
    _bottomView.layer.cornerRadius = 3.5;
    _bottomView.layer.anchorPoint = CGPointMake(0.5, 3.5 / 22);
    _bottomView.frame = CGRectMake(3.5, 15, 7, 22);
    [self addSubview:_bottomView];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(14, 37);
}

- (void)setState:(PiPChevronViewState)state {
    _state = state;
    
    CGFloat topRotation = kRotationAngle * M_PI / 180;
    CGFloat bottomRotation = topRotation;
    
    switch (state) {
        case PiPChevronViewStateNormal:
            _topView.transform = CGAffineTransformIdentity;
            _bottomView.transform = CGAffineTransformIdentity;
            return;
            
        case PiPChevronViewStateLeft:
            bottomRotation = -bottomRotation;
            break;
            
        case PiPChevronViewStateRight:
            topRotation = -topRotation;
            break;
    }
    
    _topView.transform = CGAffineTransformMakeRotation(topRotation);
    _bottomView.transform = CGAffineTransformMakeRotation(bottomRotation);
}

- (void)setState:(PiPChevronViewState)state animated:(BOOL)flag {
    if (self.state == state) {
        return;
    }
    
    if (!flag) {
        self.state = state;
        return;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.state = state;
    }];
}

@end
