//
//  PiPButton.h
//  PiPhone
//
//  Created by KY1VSTAR on 03.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PiPButton : UIControl

@property (nonatomic, nullable) UIImage *backgroundImage;
@property (nonatomic, nullable) UIImage *image;

@property (nonatomic, nullable) UIImage *selectedBackgroundImage;
@property (nonatomic, nullable) UIImage *selectedImage;

@end

NS_ASSUME_NONNULL_END
