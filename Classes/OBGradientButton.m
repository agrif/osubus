// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// this source is originally from
// http://www.cimgf.com/2010/01/28/fun-with-uibuttons-and-core-animation-layers/
// though it has been modified

#import "OBGradientButton.h"

@implementation OBGradientButton			

@synthesize _highColor;
@synthesize _lowColor;
@synthesize gradientLayer;

- (void) awakeFromNib
{
    gradientLayer = [[CAGradientLayer alloc] init];

	// layout is handled in layoutSubviews, as it should be
	
    // Insert the layer at position zero to make sure the 
    // text of the button is not obscured
    [[self layer] insertSublayer: gradientLayer atIndex: 0];
	
	// some default settings
    [[self layer] setCornerRadius: 8.0f];
    [[self layer] setMasksToBounds: YES];
    [[self layer] setBorderWidth: 1.0f];
	
	// some default colors
	[self setLowColor: [UIColor colorWithRed: 0.9 green: 0.9 blue: 0.9 alpha: 1.0]];
	[self setHighColor: [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 1.0]];
	
	[super awakeFromNib];
}

- (void) layoutSubviews
{
	[gradientLayer setBounds: [self bounds]];
    [gradientLayer setPosition: CGPointMake([self bounds].size.width / 2, [self bounds].size.height / 2)];
	
	[super layoutSubviews];
}

- (void) drawRect: (CGRect) rect
{
    [super drawRect: rect];
}

// this is called after each color update...
- (void) updateGradient
{
	if (_highColor && _lowColor)
    {
		[gradientLayer setColors: [NSArray arrayWithObjects: (id)[_highColor CGColor], (id)[_lowColor CGColor], nil]];
    }
}

- (void) setHighColor: (UIColor*) color
{
    [self set_highColor: color];
	[self updateGradient];
    [[self layer] setNeedsDisplay];
}

- (void) setLowColor: (UIColor*) color
{
    [self set_lowColor: color];
	[self updateGradient];
    [[self layer] setNeedsDisplay];
}

- (void)dealloc
{
    [gradientLayer release];
    [super dealloc];
}
@end
