//
//  ViewController.h
//  BluetoothTest
//
//  Created by CITA on 11/6/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController : UIViewController<CBCentralManagerDelegate, UIAlertViewDelegate> {
    CBCentralManager *myCentralManager;
    __weak IBOutlet UILabel *testText;
    __weak IBOutlet UILabel *peripherals;
    NSArray *services;
    __weak IBOutlet UITextField *sendText;
    

}

@property (strong) CBPeripheral *connectingPeripheral;
- (IBAction)show:(id)sender;
- (IBAction)send:(id)sender;

@end

