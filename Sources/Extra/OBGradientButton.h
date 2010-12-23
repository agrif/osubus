// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// this source is originally from
// http://www.cimgf.com/2010/01/28/fun-with-uibuttons-and-core-animation-layers/
// though it has been modified

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>

@interface OBGradientButton : UIButton
{
	UIColor* _highColor;
	UIColor* _lowColor;
	CAGradientLayer* gradientLayer;
}

@property (nonatomic, retain) UIColor* _highColor;
@property (nonatomic, retain) UIColor* _lowColor;
@property (nonatomic, retain) CAGradientLayer* gradientLayer;

- (void) setLowColor: (UIColor*) color;
- (void) setHighColor: (UIColor*) color;

@end
