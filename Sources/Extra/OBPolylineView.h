// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import <MapKit/MapKit.h>

@interface OBPolylineView : MKPolylineView
{
	UIColor* polylineColor;
	CGFloat polylineAlpha;
	CGFloat polylineWidth;
	UIColor* polylineBorderColor;
	CGFloat polylineBorderWidth;
}

@property (nonatomic, retain) UIColor* polylineColor;
@property (nonatomic, assign) CGFloat polylineAlpha;
@property (nonatomic, assign) CGFloat polylineWidth;
@property (nonatomic, retain) UIColor* polylineBorderColor;
@property (nonatomic, assign) CGFloat polylineBorderWidth;

@end
