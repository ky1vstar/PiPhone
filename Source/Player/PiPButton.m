//
//  PiPButton.m
//  PiPhone
//
//  Created by KY1VSTAR on 03.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPButton.h"

#define kMaxDiameter 44.f
#define kMinDiameter 34.f
#define kBackgroundImageAlpha 0.5f
#define kHighlightedBackgroundImageAlpha 0.85f

@interface PiPButton ()

@property (nonatomic) UIVisualEffectView *visualEffectView;
@property (nonatomic) UIImageView *backgroundImageView;
@property (nonatomic) UIImageView *imageView;

@end

@implementation PiPButton

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    // Button
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
//    [self.widthAnchor constraintGreaterThanOrEqualToConstant:kMinDiameter].active = YES;
    [self.heightAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _visualEffectView.frame = CGRectZero;
    _visualEffectView.clipsToBounds = YES;
    _visualEffectView.userInteractionEnabled = NO;
    _visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_visualEffectView];
    
    // backgroundImageView
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _backgroundImageView.alpha = kBackgroundImageAlpha;
    _backgroundImageView.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_backgroundImageView];
    
    //imageView
    _imageView = [[UIImageView alloc] init];
    _imageView.alpha = 0.65;
    _imageView.tintColor = UIColor.blackColor;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _visualEffectView.layer.cornerRadius = self.frame.size.width / 2;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    _backgroundImageView.alpha = highlighted ? kHighlightedBackgroundImageAlpha : kBackgroundImageAlpha;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        _backgroundImageView.image = _selectedBackgroundImage ?: _backgroundImage;
        _imageView.image = _selectedImage ?: _image;
    } else {
        _backgroundImageView.image = _backgroundImage;
        _imageView.image = _image;
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(kMaxDiameter, kMaxDiameter);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    
    if (!self.isSelected) {
        _backgroundImageView.image = backgroundImage;
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    
    if (!self.isSelected) {
        _imageView.image = image;
    }
}

- (void)setSelectedBackgroundImage:(UIImage *)selectedBackgroundImage {
    _selectedBackgroundImage = selectedBackgroundImage;
    
    if (self.isSelected) {
        _backgroundImageView.image = selectedBackgroundImage ?: _backgroundImage;
    }
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    
    if (self.isSelected) {
        _imageView.image = selectedImage ?: _image;
    }
}

@end
