// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "UIImage+ScaleCompat.h"

@implementation UIImage (ScaleCompat)

+ (UIImage*) compatImageNamed: (NSString*) name
{
	UIImage* img = [UIImage imageNamed: name];
	if (img)
		return img;
	
	// fallback
	img = [UIImage imageNamed: [name stringByAppendingString: @".png"]];
	
	return img;
}

- (CGFloat) compatScale
{
	if ([self respondsToSelector: @selector(scale)])
		return [self scale];
	return 1.0;
}

@end
