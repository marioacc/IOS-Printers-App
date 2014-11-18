//
//  PeripheralVC.h
//  BluetoothTest
//
//  Created by CITA on 11/13/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import "ViewController.h"

@interface PeripheralVC : ViewController {
    
    __weak IBOutlet UILabel *textPeripheral;
    __weak IBOutlet UILabel *textservice;
    __weak IBOutlet UILabel *textCharacteristics;
    __weak IBOutlet UITextField *sendText;
    CBPeripheral *newPeripheral;
    CBCharacteristic *newCharacteristic;

}
- (IBAction)send:(id)sender;
@property (strong, nonatomic) NSString *infoPeripheral;
@property (strong, nonatomic) NSString *infoServices;
@property (strong, nonatomic) NSString *infoCharacteristics;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *characteristic;
@end
