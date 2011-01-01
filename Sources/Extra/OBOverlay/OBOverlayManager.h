// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// OBOverlayManager based on <https://github.com/wlach/nvpolyline>,
// but was written from scratch to be more versatile

// As of iOS 4.0, most of this functionality is available in MapKit,
// but I would hate to keep late-adopters out just because I was
// too lazy to write a small compatibility layer

#include <UIKit/UIKit.h>
#include <MapKit/MapKit.h>

// FIXME -- move in CATiledLayer code from OBPolyline, and turn this into a proper class
@protocol OBOverlay
// DO NOT retain map!!
- (void) setMap: (MKMapView*) map;
- (MKCoordinateRegion) overlayRegion;
@end

@interface OBOverlayManager : MKAnnotationView <MKAnnotation>
{
	MKMapView* map;
	NSMutableArray* overlays;
	
	NSMutableArray* redrawOverlays;
}

@property (nonatomic, readonly) NSArray* overlays;

- (id) initWithMapView: (MKMapView*) mapView;
// should be called whenever map touches end
- (void) redrawOverlays;
- (void) addOverlay: (UIView<OBOverlay>*) overlay;
- (void) removeOverlay: (UIView<OBOverlay>*) overlay;

@end
