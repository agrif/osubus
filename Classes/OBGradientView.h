// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <UIKit/UIKit.h>

#import <CoreGraphics/CoreGraphics.h>

@interface OBGradientView : UIView
{
	CGGradientRef gradient;
	CGColorSpaceRef rgbColorspace;
	CGColorRef bgColor;
}

@end