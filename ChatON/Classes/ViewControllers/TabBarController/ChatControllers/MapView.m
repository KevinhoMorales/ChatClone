//
//  MapView.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "MapView.h"


@interface MapView ()
{
    MKPlacemark *_pin;
}

@end
static const CLLocationDegrees MKCoordinateSpanDefaultValue = 250;

@implementation MapView

- (void)setManipulationsEnabled:(BOOL)enabled {
    
    self.zoomEnabled = enabled;
    self.scrollEnabled = enabled;
    
    if ([self respondsToSelector:@selector(setRotateEnabled:)]) {
        
        self.rotateEnabled = enabled;
    }
    
    if ([self respondsToSelector:@selector(setPitchEnabled:)]) {
        
        self.pitchEnabled = enabled;
    }
}

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate {
    
    [self markCoordinate:coordinate animated:NO];
}

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, MKCoordinateSpanDefaultValue, MKCoordinateSpanDefaultValue);
    [self setRegion:region animated:animated];
    
    // remove previous marker
    [self removeAnnotation:_pin];
    
    // create a new marker in the middle
    _pin = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    [self addAnnotation:_pin];
    [self selectAnnotation:_pin animated:NO];

}

@end
