// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "UIViewController+PresentingCompat.h"

#import "NSObject+Swizzle.h"

static BOOL swizzled = NO;
static BOOL presenting_available = NO;

@implementation UIViewController (PresentingCompat)

+ (void) load
{
	if (!swizzled)
	{
		presenting_available = [[self class] swizzleMethod: @selector(presentingViewController) withMethod: @selector(PresentingCompat_presentingViewController)];
		swizzled = YES;
	}
}

- (UIViewController*) PresentingCompat_presentingViewController
{
	if (presenting_available)
		return [self PresentingCompat_presentingViewController];
	// in earlier iOS versions, this is stored in parentViewController
	return [self parentViewController];
}

@end
