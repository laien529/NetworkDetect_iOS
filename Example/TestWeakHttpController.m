//
//  TestWeakHttpController.m
//  TestConroutine
//
//  Created by chengsc on 2021/3/15.
//  Copyright © 2021 chengsc. All rights reserved.
//

#import "TestWeakHttpController.h"
#import "NetworkModel.h"

@interface TestWeakHttpController ()
@property (weak, nonatomic) IBOutlet UILabel *lbHttpRtt;
@property (weak, nonatomic) IBOutlet UILabel *lbThroughput;
@property (weak, nonatomic) IBOutlet UILabel *lbNetStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbWeakHttpThreshold;
@property (weak, nonatomic) IBOutlet UILabel *lbGreatHttpThreshold;
@property (weak, nonatomic) IBOutlet UILabel *lbWeakThroughputThreshold;
@property (weak, nonatomic) IBOutlet UILabel *lbGreatThroughputThreshold;
@property (weak, nonatomic) IBOutlet UILabel *lbTimerHeartbeat;
@property (weak, nonatomic) IBOutlet UISlider *sliderWeakHttprtt;
@property (weak, nonatomic) IBOutlet UISlider *sliderGreatHttprtt;
@property (weak, nonatomic) IBOutlet UISlider *sliderWeakThroughput;
@property (weak, nonatomic) IBOutlet UISlider *sliderGreatThroughput;

@end

@implementation TestWeakHttpController


- (IBAction)requestOnce:(id)sender {
    [self requestOnce];
    [self setupThreshold];
}

- (IBAction)requestBatch:(id)sender {
    [self requestBatch];
    [self setupThreshold];
}

- (IBAction)weak_http:(id)sender {
    UISlider *slider = sender;
    _lbWeakHttpThreshold.text = [NSString stringWithFormat:@"%.0f", slider.value];
}

- (IBAction)great_http:(id)sender {
    UISlider *slider = sender;
    _lbGreatHttpThreshold.text = [NSString stringWithFormat:@"%.0f", slider.value];
}

- (IBAction)weak_throughput:(id)sender {
    UISlider *slider = sender;
    _lbWeakThroughputThreshold.text = [NSString stringWithFormat:@"%.2f", slider.value];
}

- (IBAction)greate_throughput:(id)sender {
    UISlider *slider = sender;
    _lbGreatThroughputThreshold.text = [NSString stringWithFormat:@"%.2f", slider.value];
}

- (void)setupThreshold {
    [[NSUserDefaults standardUserDefaults] setObject:_lbWeakHttpThreshold.text forKey:@"WeakHttpThreshold"];
    [[NSUserDefaults standardUserDefaults] setObject:_lbGreatHttpThreshold.text forKey:@"GreatHttpThreshold"];
    [[NSUserDefaults standardUserDefaults] setObject:_lbWeakThroughputThreshold.text forKey:@"WeakThroughputThreshold"];
    [[NSUserDefaults standardUserDefaults] setObject:_lbGreatThroughputThreshold.text forKey:@"GreatThroughputThreshold"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    // Do any additional setup after loading the view from its nib.
    [[NetDetector sharedDetector] registService:self];
    _sliderWeakHttprtt.value = _lbWeakHttpThreshold.text.floatValue;
    _sliderGreatHttprtt.value = _lbGreatHttpThreshold.text.floatValue;
    _sliderWeakThroughput.value = _lbWeakThroughputThreshold.text.floatValue;
    _sliderGreatThroughput.value = _lbGreatThroughputThreshold.text.floatValue;

}

- (void)viewDidAppear:(BOOL)animated {
    //@"https://img.alicdn.com/tfs/TB148AkSFXXXXa3apXXXXXXXXXX-1130-500.jpg_q100.jpg_.webp"
    //http://172.28.125.111:8888/json/startConfig.json?r=%f
    //@"http://192.168.50.93:8080/startConfig.json?r=%f"
    //@"http://172.28.214.56:8088/startConfig.json?r=%f"

}

- (void)requestOnce {
    [[NetworkModel sharedModel] requestWithMethod:@"GET" url:[NSString stringWithFormat:@"http://172.28.219.9:8888/json/startConfig.json?r=%f", [NSDate timeIntervalSinceReferenceDate]] params:@{}];
}

- (void)requestBatch {
    dispatch_queue_t queue = dispatch_queue_create("detect ", DISPATCH_QUEUE_CONCURRENT);
    NSInteger times = 10;
    for (int i = 0; i < times; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), queue, ^{
            [self requestOnce];
        });
    }
}

#pragma - --mark NetDetectDelegate

- (void)statusDidChanged:(NetStatus *)status {
    _lbThroughput.text = [NSString stringWithFormat:@"%.3f MB/s", status.throughput.floatValue];
    _lbHttpRtt.text = [NSString stringWithFormat:@"%.1f ms", status.httpRtt.floatValue * 1000];
    _lbNetStatus.text = [self stringWithNetStatus:status.netStatus];
    switch (status.netStatus) {
        case NetDetectStatusWeak:{
            self.view.backgroundColor = UIColor.redColor;
            break;
        }
        case NetDetectStatusGreat:{
            self.view.backgroundColor = UIColor.greenColor;

            break;
        }
        case NetDetectStatusNormal:{
            self.view.backgroundColor = UIColor.whiteColor;
            break;
        }
        case NetDetectStatusUnknown:{
            self.view.backgroundColor = UIColor.lightGrayColor;
            break;
        }
        default:
            break;
    }
}

- (void)detectTimerHeartBeat:(NSTimeInterval)interval {
    NSLog(@"Heartbeat: %f", interval);
    _lbTimerHeartbeat.text = [NSString stringWithFormat:@"%.f seconds", 10 - interval];
}

- (NSString*)stringWithNetStatus:(NetDetectStatus)detectStatus {
    
    NSString *statusString;
    switch (detectStatus) {
        case NetDetectStatusGreat:{
            statusString = @"Great";
            break;
        }
        case NetDetectStatusWeak:{
            statusString = @"Weak";
            break;
        }
        case NetDetectStatusNormal:{
            statusString = @"Normal";
            break;
        }
        case NetDetectStatusUnknown:{
            statusString = @"Unknown";
            break;
        }
        default:{
            statusString = @"Unknown";
            break;
        }
    }
    return statusString;
}

- (void)dealloc {
    [[DetectorPolicy sharedPolicy] stopDetectTrigger];
}
@end
