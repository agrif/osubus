// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "UILabel+SetTextAnimated.h"

#define ANIMATIONID @"UILabel+SetTextAnimated"
#define ANIMATIONDURATION 0.3

@implementation UILabel (SetTextAnimated)

- (void) setText: (NSString*) text animated: (BOOL) animated
{
	if ([text isEqual: [self text]])
		return;
	if (animated == NO)
	{
		[self setText: text];
		return;
	}
	
	[UIView beginAnimations: ANIMATIONID context: [text copy]];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(setTextAnimatedAnimationDidStop:finished:context:)];
	[UIView setAnimationDuration: ANIMATIONDURATION];
	[UIView setAnimationCurve: UIViewAnimationCurveLinear];
	[self setAlpha: 0.0];
	[UIView commitAnimations];
}

- (void) setTextAnimatedAnimationDidStop: (NSString*) animationID finished: (NSNumber*) finished context: (void*) context
{
	if (!([animationID isEqual: ANIMATIONID] && [finished boolValue]))
		return;
	NSString* animatedNewText = (NSString*)context;
	[self setText: animatedNewText];
	[animatedNewText release];
	
	[UIView beginAnimations: ANIMATIONID context: nil];
	[UIView setAnimationDuration: ANIMATIONDURATION];
	[UIView setAnimationCurve: UIViewAnimationCurveLinear];
	[self setAlpha: 1.0];
	[UIView commitAnimations];
}

@end
