//
//  PiPWindow.h
//  PiPhone
//
//  Created by KY1VSTAR on 01.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PiPWindow : UIWindow

@property (class, nonatomic, readonly) PiPWindow *shared;

- (void)startAnimating;
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
