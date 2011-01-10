// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "MKMapView+ZoomLevel.h"
#import <math.h>

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation MKMapView (ZoomLevel)

// this is basically a MKMapRect implementation for non-4.0 iOS

- (double) longitudeToPixelSpaceX: (double) longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double) latitudeToPixelSpaceY: (double) latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double) pixelSpaceXToLongitude: (double) pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double) pixelSpaceYToLatitude: (double) pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

- (CGSize) pixelSpaceSizeFromRegion: (MKCoordinateRegion) region
{
	CGSize ret;
	
	CLLocationDegrees minLng = region.center.longitude - (region.span.longitudeDelta / 2);
	ret.width = fabsf([self longitudeToPixelSpaceX: minLng] - [self longitudeToPixelSpaceX: minLng + region.span.longitudeDelta]);
	
	CLLocationDegrees minLat = region.center.latitude - (region.span.latitudeDelta / 2);
	ret.height = fabsf([self latitudeToPixelSpaceY: minLat] - [self latitudeToPixelSpaceY: minLat + region.span.latitudeDelta]);
	
	return ret;
}

- (MKCoordinateSpan) coordinateSpanWithCenterCoordinate: (CLLocationCoordinate2D) centerCoordinate andZoomLevel: (NSUInteger) zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX: centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY: centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = self.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude: topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude: topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude: topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude: topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

// zoom-level getting is *very* approximate
- (NSUInteger) zoomLevel
{
	const NSUInteger padding = 20;
	NSUInteger zoomLevel = 20;
	CGSize regionSize = [self pixelSpaceSizeFromRegion: self.region];
	
	while (regionSize.width > self.bounds.size.width + padding || regionSize.height > self.bounds.size.height + padding)
	{
		zoomLevel--;
		if (zoomLevel == 0)
			break;
		
		regionSize.width /= 2;
		regionSize.height /= 2;
	}
	
	return zoomLevel + 1;
}

- (void) setZoomLevel: (NSUInteger) zoomLevel
{
	[self setZoomLevel: zoomLevel animated: NO];
}

- (void) setZoomLevel: (NSUInteger) zoomLevel animated: (BOOL) animated
{
	[self setCenterCoordinate: self.centerCoordinate zoomLevel: zoomLevel animated: animated];
}

- (void) setCenterCoordinate: (CLLocationCoordinate2D) centerCoordinate zoomLevel: (NSUInteger) zoomLevel animated: (BOOL) animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithCenterCoordinate: centerCoordinate andZoomLevel: zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion: region animated: animated];
}

@end
