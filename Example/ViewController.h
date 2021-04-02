//
//  ViewController.h
//  TestConroutine
//
//  Created by chengsc on 2019/8/23.
//  Copyright © 2019 chengsc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

