// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// may seem to be related to the OBGradientView at
// http://oleb.net/blog/2010/04/obgradientview-a-simple-uiview-wrapper-for-cagradientlayer/
// but this is just a happy coincidence -- OB just happens to be my namespace for this
// little project, while this other class was written by Ole Begemann *shrug*

#import <UIKit/UIKit.h>

#import <CoreGraphics/CoreGraphics.h>

@interface OBGradientView : UIView
{
	CGGradientRef gradient;
	CGColorSpaceRef rgbColorspace;
	CGColorRef bgColor;
}

@end
