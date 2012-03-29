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
	CGFloat* dash_lengths;
	size_t dash_count;
}

@property (nonatomic, retain) NSArray* points;
@property (nonatomic, retain) UIColor* polylineColor;
@property (nonatomic, assign) CGFloat polylineAlpha;
@property (nonatomic, assign) CGFloat polylineWidth;
@property (nonatomic, retain) UIColor* polylineBorderColor;
@property (nonatomic, assign) CGFloat polylineBorderWidth;
@property (nonatomic, readonly) CGFloat* dash_lengths;
@property (nonatomic, readonly) size_t dash_count;

- (id) init;
- (id) initWithPoints: (NSArray*) pts;
- (void) setDashLengths: (CGFloat*) lengths count: (size_t) count;

@end
