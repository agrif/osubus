// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "OBColorBandView.h"

#import "OBGradientView.h"

@implementation OBColorBandView

- (void) _initWithColors: (NSArray*) _colors
{
	colorsHaveChanged = NO;
	self.colors = _colors;
	self.bandWidth = 8.0;
	self.autoResizing = NO;
	
	// standard setup that we REALLY WANT on all of these views;
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
}

- (id) initWithFrame: (CGRect) frame
{
	return [self initWithFrame: frame colors: nil];
}

- (id) initWithFrame: (CGRect) frame colors: (NSArray*) _colors
{
	if (self = [super initWithFrame: frame])
		[self _initWithColors: _colors];
	return self;
}

- (id) initWithCoder: (NSCoder*) aDecoder
{
	if (self = [super initWithCoder: aDecoder])
		[self _initWithColors: nil];
	return self;
}

- (void) dealloc
{
	self.colors = nil;
	if (bandViews)
		[bandViews release];
	
	[super dealloc];
}

- (void) setColors: (NSArray*) _colors
{
	if (_colors != colors)
	{
		if (colors)
			[colors release];
		
		colors = _colors;
		
		if (colors)
			[colors retain];
		
		colorsHaveChanged = YES;
		[self setNeedsLayout];
	}
}

- (NSArray*) colors
{
	return colors;
}

- (void) setBandWidth: (CGFloat) _bandWidth
{
	if (_bandWidth != bandWidth)
	{
		bandWidth = _bandWidth;
		[self setNeedsLayout];
	}
}

- (CGFloat) bandWidth
{
	return bandWidth;
}

- (void) setAutoResizing: (BOOL) _autoResizing
{
	if (_autoResizing != autoResizing)
	{
		autoResizing = _autoResizing;
		[self layoutSubviews];
	}
}

- (BOOL) isAutoResizing
{
	return autoResizing;
}

// helper to get a reasonable subview frame, given an index
// returns CGRectZero when out of room

- (CGRect) createSubviewRect: (NSUInteger) i
{
	if (bandWidth * (i + 1) > self.bounds.size.width)
		return CGRectZero;
	
	return CGRectMake(self.bounds.size.width - (bandWidth * (i + 1)),
					  0.0,
					  bandWidth,
					  self.bounds.size.height);
}

- (void) layoutSubviews
{
	if (autoResizing)
	{
		CGRect bounds = self.bounds;
		bounds.size.width = colors.count * bandWidth;
		self.bounds = bounds;
	}
	
	NSUInteger i = 0;
	if (colorsHaveChanged)
	{
		if (bandViews)
		{
			for (UIView* view in bandViews)
			{
				[view removeFromSuperview];
			}
			
			[bandViews release];
			bandViews = nil;
		}
		
		if (!colors)
			return;
		
		bandViews = [[NSMutableArray alloc] initWithCapacity: colors.count];
		
		for (UIColor* color in colors)
		{
			UIView* newView;
			// use gradient views only for old UI
			if (OSU_BUS_NEW_UI)
			{
				newView = [[UIView alloc] initWithFrame: [self createSubviewRect: i]];
			} else {
				newView = [[OBGradientView alloc] initWithFrame: [self createSubviewRect: i]];
			}
			newView.backgroundColor = color;
			[self addSubview: newView];
			
			[bandViews addObject: newView];
			
			i++;
		}
		
		colorsHaveChanged = NO;
	} else {
		for (UIView* view in bandViews)
		{
			view.frame = [self createSubviewRect: i];
			i++;
		}
	}
}

@end
