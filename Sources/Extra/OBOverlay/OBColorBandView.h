// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// this displays bands of color using OBGradientView

#import <UIKit/UIKit.h>

@interface OBColorBandView : UIView
{
	NSArray* colors;
	CGFloat bandWidth;
	
	BOOL autoResizing;
	BOOL colorsHaveChanged;
	NSMutableArray* bandViews;
}

@property (nonatomic, retain) NSArray* colors;
@property (nonatomic, assign) CGFloat bandWidth;
@property (nonatomic, assign, getter=isAutoResizing) BOOL autoResizing;

- (id) initWithFrame: (CGRect) frame;
- (id) initWithFrame: (CGRect) frame colors: (NSArray*) _colors;

@end
