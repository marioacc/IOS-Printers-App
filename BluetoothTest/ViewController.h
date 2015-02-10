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
    
    NSMutableDictionary *vendingMachines;

}

//Peripheral
@property (strong, nonatomic) CBPeripheral *peripheral;

//Services
@property (strong, nonatomic) NSString *discoveredService;
@property (strong, nonatomic) NSString *discoveredCharacteristics;

//Charactersitics
@property (strong, nonatomic) CBCharacteristic *pricesCharacteristic;
@property (strong, nonatomic) CBCharacteristic *beginSessionCharacteristic;

//Values
@property (strong, nonatomic) NSString *pricesValue;
@property (strong, nonatomic) NSString *beginSessionValue;
- (IBAction)show:(id)sender;

//Button to send cash to vending machine
- (IBAction)sendCash:(id)sender;

@end

