// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBPinView.h"

#import "UIImage+ScaleCompat.h"

@implementation OBPinView

- (void) _init
{
	self.pinColor = [UIColor redColor];
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
}

- (id) init
{
	if (self = [super init])
	{
		[self _init];
	}
	
	return self;
}

- (id) initWithAnnotation: (id<MKAnnotation>) annotation reuseIdentifier: (NSString*) reuseIdentifier
{
	if (self = [super initWithAnnotation: annotation reuseIdentifier: reuseIdentifier])
	{
		[self _init];
	}
	
	return self;
}

// called whenever cacheLayer is not setup
- (void) updateCacheLayerWithContext: (CGContextRef) context
{
	// see if we even need to update
	if (!pinColor || !mask || !overlay)
		return;
	
	// sanity check on image sizes
	if (!CGSizeEqualToSize(mask.size, overlay.size) || mask.scale != overlay.scale)
		return;
	
	// clear out old layer
	if (cacheLayer)
	{
		CGLayerRelease(cacheLayer);
		cacheLayer = NULL;
	}
	
	// setup the frame
	CGRect frame = self.frame;
	frame.size = mask.size;
	self.frame = frame;
	
	// now, on to generating the layer
	// (bail now if we're not doing that)
	if (!context)
		return;
	
	// make sure to handle @2x properly
	CGFloat scale = mask.scale;
	CGSize layerSize = mask.size;
	layerSize.width *= scale;
	layerSize.height *= scale;
	
	cacheLayer = CGLayerCreateWithContext(context, layerSize, NULL);
	CGContextRef c = CGLayerGetContext(cacheLayer);
	
	CGRect area = CGRectMake(0.0, 0.0, frame.size.width * scale, frame.size.height * scale);
	
	// fill in color according to mask
	CGContextSaveGState(c);
	CGContextClipToMask(c, area, [mask CGImage]);
	CGContextSetFillColorWithColor(c, [pinColor CGColor]);
	CGContextFillRect(c, area);
	CGContextRestoreGState(c);
	
	// now draw the overlay
	CGContextDrawImage(c, area, [overlay CGImage]);
}

- (void) drawRect: (CGRect) rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (!cacheLayer)
	{
		// regenerate cache layer
		[self updateCacheLayerWithContext: context];
		
		// make sure it worked
		if (!cacheLayer)
			return;
	}
	
	// draw the layer
	CGFloat scale = mask.scale;
	CGContextScaleCTM(context, 1.0/scale, -1.0/scale);
	CGContextDrawLayerAtPoint(context, CGPointMake(0.0, -self.frame.size.height * scale), cacheLayer);
}

#pragma mark properties

// reads

- (UIImage*) mask
{
	return mask;
}

- (UIImage*) overlay
{
	return overlay;
}

- (UIColor*) pinColor
{
	return pinColor;
}

// writes

- (void) setMask: (UIImage*) _mask
{
	if (_mask != mask)
	{
		if (mask)
			[mask release];
		mask = _mask;
		if (mask)
			[mask retain];
		[self updateCacheLayerWithContext: NULL];
	}
}

- (void) setOverlay: (UIImage*) _overlay
{
	if (_overlay != overlay)
	{
		if (overlay)
			[overlay release];
		overlay = _overlay;
		if (overlay)
			[overlay retain];
		[self updateCacheLayerWithContext: NULL];
	}
}

- (void) setPinColor: (UIColor*) _pinColor
{
	if (_pinColor != pinColor)
	{
		if (pinColor)
			[pinColor release];
		pinColor = _pinColor;
		if (pinColor)
			[pinColor retain];
		[self updateCacheLayerWithContext: NULL];
	}
}

@end
