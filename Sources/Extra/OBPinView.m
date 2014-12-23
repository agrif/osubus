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
	self.pinShadowed = YES;
	self.pinShadowRadius = 4.0;
	self.pinShadowColor = [UIColor colorWithWhite: 0.0 alpha: 0.33];
	
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = NO;
	self.opaque = NO;
}

- (void) dealloc
{
	self.mask = nil;
	self.overlay = nil;
	self.pinColor = nil;
	self.pinShadowColor = nil;
	
	if (cacheLayer)
	{
		CGLayerRelease(cacheLayer);
		cacheLayer = NULL;
	}
	
	[super dealloc];
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
	if (!pinColor || !mask)
		return;
	
	// sanity check on image sizes
	if (overlay)
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
	// correct for shadow radius
	if (pinShadowed)
	{
		frame.size.width += 2 * pinShadowRadius;
		frame.size.height += 2 * pinShadowRadius;
	}
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
	
	// add margins for shadows
	if (pinShadowed)
	{
		layerSize.width += 2 * pinShadowRadius * scale;
		layerSize.height += 2 * pinShadowRadius * scale;
	}
	
	cacheLayer = CGLayerCreateWithContext(context, layerSize, NULL);
	CGContextRef c = CGLayerGetContext(cacheLayer);
	
	CGRect area = CGRectMake(0.0, 0.0, mask.size.width * scale, mask.size.height * scale);
	
	// set up shadowing
	if (pinShadowed)
	{
		// tell context to shadow
		CGContextSetShadowWithColor(c, CGSizeMake(0.0, 0.0), pinShadowRadius * scale, [pinShadowColor CGColor]);
		
		// modify area rect to be in center now
		area.origin.x += pinShadowRadius * scale;
		area.origin.y += pinShadowRadius * scale;
	}
	
	// put it all in a layer, so shadowing works pretty
	CGContextBeginTransparencyLayer(c, NULL);
	
	// fill in color according to mask
	CGContextSaveGState(c);
	CGContextClipToMask(c, area, [mask CGImage]);
	CGContextSetFillColorWithColor(c, [pinColor CGColor]);
	CGContextFillRect(c, area);
	CGContextRestoreGState(c);
	
	// now draw the overlay
	if (overlay)
		CGContextDrawImage(c, area, [overlay CGImage]);
	
	// end layer, let shadowing do its work
	CGContextEndTransparencyLayer(c);
	
	// flush it, make sure it's all done
	CGContextFlush(c);
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

- (BOOL) isPinShadowed
{
	return pinShadowed;
}

- (CGFloat) pinShadowRadius
{
	return pinShadowRadius;
}

- (UIColor*) pinShadowColor
{
	return pinShadowColor;
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

- (void) setPinShadowed: (BOOL) _pinShadowed
{
	pinShadowed = _pinShadowed;
	[self updateCacheLayerWithContext: NULL];
}

- (void) setPinShadowRadius: (CGFloat) _pinShadowRadius
{
	if (_pinShadowRadius < 0.0)
		return;
	pinShadowRadius = _pinShadowRadius;
	if (pinShadowed)
		[self updateCacheLayerWithContext: NULL];
}

- (void) setPinShadowColor: (UIColor*) _pinShadowColor
{
	if (_pinShadowColor != pinShadowColor)
	{
		if (pinShadowColor)
			[pinShadowColor release];
		pinShadowColor = _pinShadowColor;
		if (pinShadowColor)
			[pinShadowColor retain];
		if (pinShadowed)
			[self updateCacheLayerWithContext: NULL];
	}
}

@end
