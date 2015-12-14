//
//  ViewController.m
//  Map_Navigation
//
//  Created by mac on 15-11-17.
//  Copyright (c) 2015年 Lispeng. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "HMAnnotation.h"
@interface ViewController ()<MKMapViewDelegate>
//@property (weak, nonatomic) IBOutlet UITextField *startTextField;
//@property (weak, nonatomic) IBOutlet UITextField *endTextField;
//- (IBAction)startNavitaion;
@property (strong,nonatomic) CLGeocoder *geocode;
- (IBAction)startNavigationClick;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation ViewController

- (CLGeocoder *)geocode
{
    if (!_geocode) {
        _geocode = [[CLGeocoder alloc] init];
    }
    return _geocode;
}

- (IBAction)startNavigationClick {
    
    NSString *startPositions = @"上海";
     NSString *endPositions = @"北京";
    [self.geocode geocodeAddressString:startPositions completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *startPlacemark = [placemarks firstObject];
        
        
        
        [self.geocode geocodeAddressString:endPositions completionHandler:^(NSArray *placemarks, NSError *error) {
            
            CLPlacemark *endPlacemark = [placemarks firstObject];
            
            
            [self startNavigationWithstartPlacemark:startPlacemark endPlacemark:endPlacemark];
            
        }];
        
        
    }];

    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (IBAction)startNavitaion {
 
    if(self.startTextField.text == nil){
        NSLog(@"请输入导航的起点");
        return;
    }
 
    NSString *startPositions = @"上海";

    if (self.endTextField.text == nil) {
        NSLog(@"请输入导航的目的地");
        return;
    }
      
    NSString *endPositions = @"北京";
    
    [self.geocode geocodeAddressString:startPositions completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *startPlacemark = [placemarks firstObject];
        
        
        
         [self.geocode geocodeAddressString:endPositions completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *endPlacemark = [placemarks firstObject];
             
             
             [self startNavigationWithstartPlacemark:startPlacemark endPlacemark:endPlacemark];
             
    }];
        
        
    }];
    
   
}
*/
- (void)startNavigationWithstartPlacemark:(CLPlacemark *)startPlacemark endPlacemark:(CLPlacemark *)endPlacemark
{
    
    MKPlacemark *startMark = [[MKPlacemark alloc] initWithPlacemark:startPlacemark];
    
    MKMapItem *startItem = [[MKMapItem alloc] initWithPlacemark:startMark];
    //在开始位置添加大头针
    HMAnnotation *startAnnotation = [[HMAnnotation alloc] init];
    startAnnotation.title = startPlacemark.locality;
    startAnnotation.subtitle = startPlacemark.name;
    startAnnotation.coordinate = startPlacemark.location.coordinate;
    [self.mapView addAnnotation:startAnnotation];
    
    MKPlacemark *endMark = [[MKPlacemark alloc] initWithPlacemark:endPlacemark];
    MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:endMark];
 //设置地理位置请求(起始点和终点的位置确定)
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = startItem;
    request.destination = endItem;
    //在重点位置添加大头针
    HMAnnotation *endAnnotation = [[HMAnnotation alloc] init];
    endAnnotation.title = endPlacemark.locality;
    endAnnotation.subtitle = endPlacemark.name;
    endAnnotation.coordinate = endPlacemark.location.coordinate;
    [self.mapView addAnnotation:endAnnotation];
    //开始请求
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        //获取所有路线
        NSArray *routes = response.routes;
        
        for (MKRoute *route in routes) {
            NSLog(@"distance = %f,expectedTravel = %f,name = %@",route.distance,route.expectedTravelTime,route.name);
            [self.mapView addOverlay:route.polyline];
            //获取路线中的所有具体步骤操作
            NSArray *steps = route.steps;
            for (MKRouteStep *step in steps) {
                NSLog(@"instruction = %@,notice = %@,distance = %f",step.instructions,step.notice,step.distance);
            }
        }
    }];
    
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *polylineRander = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    polylineRander.lineWidth = 5;
    polylineRander.strokeColor = [UIColor redColor];
    return polylineRander;
}

@end
