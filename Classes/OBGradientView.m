// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBGradientView.h"

@implementation OBGradientView

- (id) initWithFrame: (CGRect) frame
{
    if (self = [super initWithFrame: frame])
	{
		[self init];
    }
    return self;
}

- (id) initWithCoder: (NSCoder*) decoder
{
	if (self = [super initWithCoder: decoder])
	{
		[self init];
	}
	return self;
}

- (id) init
{
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = {
		1.0, 1.0, 1.0, 0.45, // start color
		1.0, 1.0, 1.0, 0.00, // end color
	};
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	bgColor = [self.backgroundColor CGColor];
	CGColorRetain(bgColor);
	
	return self;
}

- (void) setBackgroundColor: (UIColor*) color
{
	[super setBackgroundColor: color];
	CGColorRelease(bgColor);
	bgColor = [color CGColor];
	CGColorRetain(bgColor);
}

- (void) drawRect: (CGRect) rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorSpace(c, CGColorGetColorSpace(bgColor));
	//CGContextSetRGBFillColor(c, 1.0, 0.0, 0.0, 1.0);
	CGContextSetFillColorWithColor(c, bgColor);
	CGContextFillRect(c, rect);
	
	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
	CGContextDrawLinearGradient(c, gradient, topCenter, midCenter, 0);
}


- (void) dealloc
{
	CGGradientRelease(gradient);
	CGColorSpaceRelease(rgbColorspace);
	CGColorRelease(bgColor);
    [super dealloc];
}

@end
