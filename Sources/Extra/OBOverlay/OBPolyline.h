// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import "OBOverlay.h"

#import <CoreGraphics/CoreGraphics.h>

@interface OBPolyline : OBOverlay
{
	NSArray* points;
	CGMutablePathRef path;
	
	UIColor* polylineColor;
	CGFloat polylineAlpha;
	CGFloat polylineWidth;
	UIColor* polylineBorderColor;
	CGFloat polylineBorderWidth;
}

@property (nonatomic, retain) NSArray* points;
@property (nonatomic, retain) UIColor* polylineColor;
@property (nonatomic, assign) CGFloat polylineAlpha;
@property (nonatomic, assign) CGFloat polylineWidth;
@property (nonatomic, retain) UIColor* polylineBorderColor;
@property (nonatomic, assign) CGFloat polylineBorderWidth;

- (id) init;
- (id) initWithPoints: (NSArray*) pts;

@end
