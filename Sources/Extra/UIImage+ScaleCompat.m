// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "UIImage+ScaleCompat.h"

#import "NSObject+Swizzle.h"

static BOOL swizzled = NO;
static BOOL scale_available = NO;

@implementation UIImage (ScaleCompat)

+ (void) load
{
	if (!swizzled)
	{
		[[self class] swizzleClassMethod: @selector(imageNamed:) withClassMethod: @selector(ScaleCompat_imageNamed:)];
		scale_available = [[self class] swizzleMethod: @selector(scale) withMethod: @selector(ScaleCompat_scale)];
		swizzled = YES;
	}
}

+ (UIImage*) ScaleCompat_imageNamed: (NSString*) name
{
	UIImage* img = [UIImage ScaleCompat_imageNamed: name];
	if (img)
		return img;
	
	// fallback
	img = [UIImage ScaleCompat_imageNamed: [name stringByAppendingString: @".png"]];
	
	return img;
}

- (CGFloat) ScaleCompat_scale
{
	if (scale_available)
		return [self ScaleCompat_scale];
	return 1.0;
}

@end
