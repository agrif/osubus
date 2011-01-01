// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

#import "OBOverlay.h"
#import <QuartzCore/CoreAnimation.h>

@implementation OBOverlay

@synthesize map;
@synthesize overlayRegion;

- (id) init
{
	if (self = [super init])
	{
		// generic setup for all overlays
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.clipsToBounds = NO;
		
		drawEnabled = YES;
	}
	
	return self;
}

- (void) dealloc
{
	self.map = nil;
	
	[super dealloc];
}

// use CATiledLayer as our layer class
+ (Class) layerClass
{
	return [CATiledLayer class];
}

- (void) stoppedZooming
{
	// let our draw function do its business
	drawEnabled = YES;
	
	// clear the tiled layer cache (makes sure ALL tiles are drawn)
	self.layer.contents = nil;
	
	// the above call will demote our nice CATiledLayer to a dumb CALayer,
	// for reasons that are well above my pay grade. For equally magick
	// reasons, a call to [layer setNeedsDisplay] will un-demote it.
	
	// also, iOS ~3.1 NEEDS this call to show ANYTHING. so there's that.
	[self.layer setNeedsDisplay];
	
	[self setNeedsDisplay];
}

- (void) startedZooming
{
	// turn off drawing, for the time being...
	drawEnabled = NO;
}

- (void) drawLayer: (CALayer*) layer inContext: (CGContextRef) context
{
	if (!drawEnabled || !map)
		return;
		
	CGRect rect = CGContextGetClipBoundingBox(context);
	[self drawOverlayRect: rect inContext: context];
}

- (void) drawOverlayRect: (CGRect) rect inContext: (CGContextRef) context
{
	// default -- do nothing
}

@end
