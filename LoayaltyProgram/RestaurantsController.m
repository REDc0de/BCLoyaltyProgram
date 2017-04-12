//
//  Restaurants.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "RestaurantsController.h"
#import "Restaurant.h"
#import <MapKit/MapKit.h>

@interface RestaurantsController () <CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, UIToolbarDelegate>


@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSegmentControle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *userLocationButton;
@property (weak, nonatomic) MKUserLocation *lastUserlocation;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) Restaurant *currentRestaurant;
@property (strong, nonatomic) NSArray *restaurants;

@end


@implementation RestaurantsController

@synthesize locationManager, lastUserlocation;

MKMapView *standartMapView;
MKMapView *hybridMapView;
MKMapView *sputnikMapView;

MKPlacemark *selectedPin;
char locationButtonState; // u - folowUserLocation c - noneFollowUserLocation d - followUserLocationWithHeading
UIImageView *navBarHairlineImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationCoordinatsIsInvalid" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertMessage:) name:@"locationCoordinatsIsInvalid" object:nil];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined) {
        
        [locationManager requestLocation];
        // [locationManager startUpdatingLocation]; //find difference with request
        // [locationManager startUpdatingHeading];
    } else {
        [locationManager requestWhenInUseAuthorization];
    }
    
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    
    Restaurant *restaurant1 =[[Restaurant alloc] initWithName:@"test1" imageURL:@"someurl" info:@"test info1" address:@"test addres1" telNumber:@"+375291110011" latitude:53.903643 longitude:27.553020];
    
    
    Restaurant *restaurant2 =[[Restaurant alloc] initWithName:@"test2" imageURL:@"someur2" info:@"test info2" address:@"test addres2" telNumber:@"+3752911100112" latitude:53.894875 longitude:27.546196];
    
    self.restaurants = [NSArray arrayWithObjects:restaurant1, restaurant2, nil];
    for (Restaurant *restaurant in self.restaurants){
        [self addPointAnnotationWithTitle:restaurant.name
                                 subTitle:restaurant.info
                                 latitude:restaurant.latitude
                                longitude:restaurant.longitude
                                onMapView:self.mapView];
    }
    [self noneFollowUserLocationMode];
    [self zoomToFitMapAnnotations:self.mapView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    panGesture.delegate = self;
    [self.mapView addGestureRecognizer:panGesture];
    
    /* TODO
     0) view for annotation info
     1) zoom and pinch recognizer for centered zooming
     2) after compas button tuchUpInside launch u - mode and exit from d - mode
     3) save camera position after compas, but make it default after u - mode enabled
     */
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mapView setLayoutMargins:UIEdgeInsetsMake(50,0,0,0)]; // trick for show compas (now compas not covered by navigation bar and toolbar)
    self.toolBar.delegate = self;
    navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden = YES;
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self noneFollowUserLocationMode];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [locationManager requestLocation];
    } else{
        [locationManager requestWhenInUseAuthorization];
        NSLog(@"NO GEO!!!!");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // we do not need to know when locations was updated, we just need to know when user location was updated
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    lastUserlocation =  userLocation;
    if(locationButtonState == 'u'){
        [self focusUserLocationOnMapView:self.mapView];
    }
}

- (IBAction)segmentControllAction:(id)sender {
    switch (self.mapSegmentControle.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
    }
}

- (IBAction)showCurrentLocationAction:(id)sender {
    switch (locationButtonState) {
        case 'u':
            [self followUserLocationWithHeading];
            break;
        case 'd':
            [self noneFollowUserLocationMode];
            break;
        case 'c':
            [self followUserLocationMode];
            break;
    }
}

- (IBAction)showAllRestaurantsAction:(id)sender {
    [self noneFollowUserLocationMode];
    [self zoomToFitMapAnnotations:self.mapView];
}

- (void)followUserLocationMode{
    locationButtonState = 'u';
    [locationManager requestLocation];
    [locationManager stopUpdatingHeading];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self focusUserLocationOnMapView:self.mapView];
    self.userLocationButton.tintColor = [UIColor colorWithRed:225.0/255 green:22.0/255 blue:47.0/255 alpha:1.0];
    self.userLocationButton.image = [UIImage imageNamed:@"Compass-Filled"];
}

- (void)noneFollowUserLocationMode{
    locationButtonState = 'c';
    [locationManager stopUpdatingHeading];
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
    self.userLocationButton.tintColor = [UIColor colorWithRed:225.0/255 green:22.0/255 blue:47.0/255 alpha:1.0];
    self.userLocationButton.image = [UIImage imageNamed:@"Compass-Line"];
    // self.mapView.camera.heading = lastHeading.trueHeading;
}

- (void)followUserLocationWithHeading{
    locationButtonState = 'd';
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [self focusUserLocationOnMapView:self.mapView];
    //  [locationManager startUpdatingHeading];
    self.userLocationButton.tintColor = [UIColor greenColor];
}

- (void)focusUserLocationOnMapView:(MKMapView*)mapView{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.04;
    span.longitudeDelta = 0.04;
    if(mapView.region.span.latitudeDelta<=0.22){
        span = mapView.region.span;
    }
    CLLocationCoordinate2D location;
    location.latitude = lastUserlocation.coordinate.latitude;
    location.longitude = lastUserlocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    
    if(CLLocationCoordinate2DIsValid(location)){
        [mapView setRegion:region animated:YES];
    } else{
        NSString *errorMessage = @"Now it is impossible to determine your geo location.";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationCoordinatsIsInvalid" object:errorMessage];
    }
}

- (void)addPointAnnotationWithTitle:(NSString *)title subTitle:(NSString *)subtitle latitude:(float)latitude longitude:(float)longitude onMapView:(MKMapView*)mapView {
    MKPointAnnotation *newAnnotation = [[MKPointAnnotation alloc] init];
    newAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    newAnnotation.title = title;
    newAnnotation.subtitle = subtitle;
    [mapView addAnnotation:newAnnotation];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // if it's the user location, just return nil
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    // handle any custom annotations
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
        
        unsigned long index = [self.restaurants indexOfObject:self.currentRestaurant];
        
        annotationView.canShowCallout = YES;
        UIButton *infoButton =  [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        infoButton.tag = index;
        [infoButton addTarget:self
                       action:@selector(annotationInfoAction:)forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = infoButton;
        UIImageView *iconView;
        annotationView.leftCalloutAccessoryView = iconView;
        
        return annotationView;
    }
    return nil;
}

- (void)annotationInfoAction:(UIButton*)sender {
    Restaurant *currentRestaurant = [self.restaurants objectAtIndex:sender.tag];
    
    CLLocationCoordinate2D start = { lastUserlocation.coordinate.latitude, lastUserlocation.coordinate.longitude };
    CLLocationCoordinate2D destination = { currentRestaurant.latitude, currentRestaurant.longitude };
    [self openGoogleMapRouteFrom:start toDestination:destination];
}

- (void)zoomToFitMapAnnotations:(MKMapView*)mapView {
    //    CLLocation *demoLocation  = [[CLLocation alloc] initWithLatitude:lastUserlocation.coordinate.latitude longitude:lastUserlocation.coordinate.longitude];
    //       CLLocation *destinationLocation;
    //        NSArray *restaurants = [Restaurant MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    //        for (Restaurant *restaurant in restaurants){
    //            destinationLocation  = [[CLLocation alloc] initWithLatitude:restaurant.latitude longitude:restaurant.longitude];
    //            NSLog(@"Distance from our position to %@ restaurant is %.2fkm",restaurant.name, [self calculateDistancerFromLocation:demoLocation toLocation:destinationLocation]/1000);
    //        }
    NSMutableArray *annotationMutableArray = [[NSMutableArray alloc] init];
    for(MKPointAnnotation *annotation in mapView.annotations) {
        [annotationMutableArray addObject:annotation];
    }
    NSArray *annotationArray = [NSArray arrayWithArray:annotationMutableArray];
    
    [mapView showAnnotations:annotationArray animated:YES];
}

//- (CLLocationDistance)calculateDistancerFromLocation:(CLLocation*)myLocation toLocation:(CLLocation*)destinationLocation{
//    CLLocationDistance distance = [myLocation distanceFromLocation:destinationLocation];
//    return distance;
//}

- (void)openGoogleMapRouteFrom:(CLLocationCoordinate2D)start toDestination:(CLLocationCoordinate2D)destination{
    // building route and open in maps.google.com
    NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                     start.latitude, start.longitude, destination.latitude, destination.longitude];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
}

- (void)showAlertMessage:(NSNotification*)notification{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error"
                                 message:[notification object]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //Handle "Ok" button
                                                     }];
    
    [alert addAction:okButton];
    [super presentViewController:alert animated:YES completion:nil];
    
}

@end