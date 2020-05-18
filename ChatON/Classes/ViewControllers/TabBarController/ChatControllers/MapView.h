//
//  MapView.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapView : MKMapView

/**
 *  Basic manipulations with map: zoom, scroll, rotate (if existent) and pitch (if existent).
 *
 *  @param enabled whether user iteractions with map enabled.
 */
- (void)setManipulationsEnabled:(BOOL)enabled;

/**
 *  Mark coordinate and set region.
 *
 *  @param coordinate coordinate to set and mark
 */
- (void)markCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  Mark coordinate and set region.
 *
 *  @param coordinate coordinate to set and mark
 *  @param animated   whether region set should be performed with animation
 */
- (void)markCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

@end
