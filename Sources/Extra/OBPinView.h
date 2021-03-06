// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// this is a *very* generic (but less animated) version of
// MKPinAnnotationView that lets *you* specify a custom color mask
// and overlay image

#import <MapKit/MapKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface OBPinView : MKAnnotationView
{
	UIImage* mask;
	UIImage* overlay;
	UIColor* pinColor;
	BOOL pinShadowed;
	CGFloat pinShadowRadius;
	UIColor* pinShadowColor;
	
	CGLayerRef cacheLayer;
}

@property (nonatomic, retain) UIImage* mask;
@property (nonatomic, retain) UIImage* overlay;
@property (nonatomic, retain) UIColor* pinColor;
@property (nonatomic, assign, getter=isPinShadowed) BOOL pinShadowed;
@property (nonatomic, assign) CGFloat pinShadowRadius;
@property (nonatomic, retain) UIColor* pinShadowColor;

- (id) init;

@end
