//
//  ViewController.h
//  BluetoothTest
//
//  Created by CITA on 11/6/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MBProgressHUD.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>





@interface ViewController : UIViewController<CBCentralManagerDelegate, UITableViewDataSource, UITableViewDelegate> {
    CBCentralManager *myCentralManager;

    __weak IBOutlet UIButton *sendCashButton;
    __weak IBOutlet UILabel *statusLabel;
    __weak IBOutlet UITableView *tableView;
    NSArray *services;
    NSMutableArray *devices;
    NSArray *characteristics;
    NSMutableDictionary *vendingMachines;
    __weak IBOutlet UITextField *sendCashTextField;
    __weak IBOutlet UILabel *cashTextLabel;
    MBProgressHUD *HUD;
    GCDAsyncUdpSocket *udpSocket ;
    __weak IBOutlet UIButton *statusButton;

}

//Peripheral
@property (strong, nonatomic) CBPeripheral *peripheral;

//Services
@property (strong, nonatomic) NSString *discoveredService;
@property (strong, nonatomic) NSString *discoveredCharacteristics;

//Charactersitics
@property (strong, nonatomic) CBCharacteristic *pricesCharacteristic;
@property (strong, nonatomic) CBCharacteristic *beginSessionCharacteristic;
@property (strong, nonatomic) CBCharacteristic *endSessionCharacteristic;

//Values
@property (strong, nonatomic) NSString *pricesValue;
@property (strong, nonatomic) NSString *beginSessionValue;
@property (strong, nonatomic) NSString *endSessionValue;
- (IBAction)show:(id)sender;

/*!
 * @discussion Send the cash to the Vending Machine and open a new View in the app
 */
- (IBAction)sendCash:(id)sender;

/*!
 * @discussion Converts an hexadecimal NSString to decimal NSString
 * @param String of hexadecimal characters
 * @return String of decimal characters
 */
-(NSString *) convertHexToDecimalString:(NSString *) hexString;

/*!
 * @discussion Converts a decimal NSString to hexadecimal  NSString
 * @param String of decimal characters
 * @return String of hex characters
 */
-(NSString *) convertDecimalToHexString:(NSString *) decimalString;

/*!
 * @discussion Method to close the keyboard on click out
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

/*!
 * @discussion Method that resets everything related to bluetooth and related propertys
 */
-(void)resetAppStatus;

/*!
 * @discussion Method to enable or disable button and text field to send cash to vending machine
 */
-(void)enableSendCash:(BOOL) enable;

/*!
 * @discussion Method to verify what type of buy it is and show the respective HUB
 */
-(void) succesfulHUDBuy:(BOOL) isSuccesful;
@end

