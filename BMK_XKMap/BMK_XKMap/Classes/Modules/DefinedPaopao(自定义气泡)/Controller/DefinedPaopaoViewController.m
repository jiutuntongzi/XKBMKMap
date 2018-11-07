//
//  DefinedPaopaoViewController.m
//  BMK_XKMap
//
//  Created by 董向坤 on 2018/11/7.
//  Copyright © 2018 晓坤. All rights reserved.
//

#import "DefinedPaopaoViewController.h"
#import "XKAnnotationView.h"

@interface DefinedPaopaoViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) BMKMapView *mapView;  //地图
@property (nonatomic, strong) BMKLocationService *locService;  //定位
@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch; //地理反编码
@property (nonatomic, strong) BMKUserLocation  *userLocation;  //当前位置对象


@property (nonatomic, strong) BMKPointAnnotation *locationPointAnnotation; //定位大头针
@property (nonatomic, strong) BMKPointAnnotation *pointAnnotation; //

@property (nonatomic, strong) NSArray *pointArray;
@end

@implementation DefinedPaopaoViewController{
    
    NSString *latitudeStr;  //定位得到的地址
    NSString *longitudeStr; //定位得到的地址
    NSString *addrStr;      //定位得到的地址
    NSInteger paopaoIndex;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地图助手";
    
    [self.view addSubview:self.mapView];
    [self startLocation];
   
}

//定位的点
- (void)locationPoint{
    
    _locationPointAnnotation = [[BMKPointAnnotation alloc] init];
    [_mapView addAnnotation:_locationPointAnnotation];
    CLLocationCoordinate2D coor;
    coor.latitude  = [latitudeStr doubleValue];
    coor.longitude = [longitudeStr doubleValue];
    _locationPointAnnotation.coordinate = coor;
    [self.mapView setCenterCoordinate:coor animated:YES];
}

//初始化描点数据
- (void)plotPoint{

    self.pointArray = @[
                            @[@"36.060961", @"103.890357", @"addr1"],
                            @[@"36.061869", @"103.906412", @"addr2"],
                            @[@"36.069396", @"103.877977", @"addr3"],
                            @[@"36.061382", @"103.891639", @"addr4"],
                            @[@"36.060926", @"103.89065",  @"addr5"]
                            ];
    for (NSInteger i = 0; i < [self.pointArray count]; i++) {
    
        self.pointAnnotation = [[BMKPointAnnotation alloc] init];
         [_mapView addAnnotation:self.pointAnnotation];
        NSString *latitudeStr  = _pointArray[i][0];
        NSString *longitudeStr = _pointArray[i][1];
        NSString *addrStr      = _pointArray[i][2];
        CLLocationCoordinate2D coor;
        coor.latitude  = [latitudeStr doubleValue];
        coor.longitude = [longitudeStr doubleValue];
        self.pointAnnotation.title = addrStr;
        self.pointAnnotation.coordinate = coor;
    }
}




//地图
- (BMKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
        _mapView.mapType = BMKMapTypeStandard;
        _mapView.zoomLevel = 18;
        _mapView.showsUserLocation = YES;
        
        
        _geocodesearch = [[BMKGeoCodeSearch alloc] init];
        _geocodesearch.delegate = self;
    }
    return _mapView;
}

//当前位置
- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}


#pragma mark ----- 开始定位
- (void)startLocation{
    
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locService startUserLocationService];
}


#pragma mark ---  BMKLocationServiceDelegate
#pragma mark -方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    
    _userLocation.title = userLocation.title;
    [_mapView updateLocationData:_userLocation];
}


#pragma mark -当前定位位置
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    
    
    _userLocation = userLocation;
    [_mapView updateLocationData:_userLocation];
    _mapView.centerCoordinate = _userLocation.location.coordinate;
    
    //地理反编码
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    reverseGeocodeSearchOption.location = userLocation.location.coordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag){
        [_locService stopUserLocationService];
    }
    
    //获取经纬度
    latitudeStr = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    longitudeStr = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    
    
    //定位的大头针
    [self locationPoint];
    //经纬度描点(该方法要放在定位的大头针后面，否则定位成功后会覆盖掉)
     [self plotPoint];
}

#pragma mark -定位失败
- (void)didFailToLocateUserWithError:(NSError *)error{
    
    NSLog(@"error:%@",error);
}

#pragma mark ---  BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[self.pointAnnotation class]]) {
        //数组对应大头针
        paopaoIndex++;
        UIView *paopaoView = [UIView new];
        static NSString *identifier = @"XKAnnotationView";
        XKAnnotationView *annotationView = [[XKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier customView:paopaoView WithData: self.pointArray[paopaoIndex - 1] WithTag:1000 + paopaoIndex];
        return annotationView;
    }else{
        //定位大头针


    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    
    //    [mapView deselectAnnotation:view.annotation animated:NO];
    
    
}


- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    
    UIView *paopaoView = [[view subviews] firstObject];
    NSInteger index = paopaoView.tag;
    if (index > 999) {
        [self paoPaoClicked:index-1001];
    }
}



#pragma mark -----BMKGeoCodeSearchDelegate
#pragma mark -地理反编码
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error{
    
    addrStr = result.address;
    _locationPointAnnotation.title =  addrStr;
}





- (void)paoPaoClicked:(NSInteger)index{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:self.pointArray[index][2] message:[NSString stringWithFormat:@"当前点击的是第%ld条数组", index+1] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}


@end
