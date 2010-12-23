// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBPolylineManager based on <https://github.com/wlach/nvpolyline>,
// with small differences

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <MapKit/MapKit.h>

@protocol OBOverlay
- (MKCoordinateRegion) overlayRegion;
@end

@interface OBPolyline : UIView <OBOverlay>
{
	MKMapView* map;
	NSArray* points;
	MKCoordinateRegion overlayRegion;
	
	UIColor* polylineColor;
	CGFloat polylineAlpha;
}

@property (nonatomic, retain) NSArray* points;
@property (nonatomic, readonly) MKCoordinateRegion overlayRegion;
@property (nonatomic, retain) UIColor* polylineColor;
@property (nonatomic, assign) CGFloat polylineAlpha;

- (id) initWithMapView: (MKMapView*) mapView;
- (id) initWithMapView: (MKMapView*) mapView points: (NSArray*) pts;

@end

@interface OBPolylineManager : MKAnnotationView <MKAnnotation>
{
	MKMapView* map;
	NSMutableArray* overlays;
}

@property (nonatomic, readonly) NSArray* overlays;

- (id) initWithMapView: (MKMapView*) mapView;
- (void) addOverlay: (UIView<OBOverlay>*) overlay;
- (void) removeOverlay: (UIView<OBOverlay>*) overlay;

@end
