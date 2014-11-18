//
//  ViewController.h
//  BluetoothTest
//
//  Created by CITA on 11/6/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController : UIViewController<CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
    CBCentralManager *myCentralManager;
    __weak IBOutlet UILabel *testText;
    __weak IBOutlet UITableView *tableView;
    NSArray *services;
    NSMutableArray *devices;
    NSArray *characteristics;

}

@property (strong, nonatomic) CBPeripheral *connectingPeripheral;
@property (strong, nonatomic) NSString *discoveredService;
@property (strong, nonatomic) NSString *discoveredCharacteristics;
@property (strong, nonatomic) CBCharacteristic *defaultCharacteristic;
- (IBAction)show:(id)sender;


@end

