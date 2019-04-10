//
//  PiPPlayerView.m
//  PiPhone
//
//  Created by KY1VSTAR on 02.04.2019.
//  Copyright © 2019 KY1VSTAR. All rights reserved.
//

#import "PiPPlayerView.h"

@implementation PiPPlayerView

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
