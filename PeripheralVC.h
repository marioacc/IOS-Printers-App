//
//  PeripheralVC.h
//  BluetoothTest
//
//  Created by CITA on 11/13/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import "ViewController.h"

@interface PeripheralVC : ViewController {
    
 
    __weak IBOutlet UITextField *sendText;
    __weak IBOutlet UILabel *pricesLabel;
    __weak IBOutlet UILabel *peripheralNameLabel;
    CBPeripheral *newPeripheral;
    CBCharacteristic *newCharacteristic;
}




//Peripheral
@property (strong, nonatomic) CBPeripheral *peripheral;

//Values
@property (strong, nonatomic) NSString *pricesValue;
@property (strong, nonatomic) NSString *beginSessionValue;

//Characteristics
@property (strong, nonatomic) CBCharacteristic *characteristic;
@property (strong, nonatomic) CBCharacteristic *pricesCharacteristic;
@property (strong, nonatomic) CBCharacteristic *beginSessionCharacteristic;

@end
