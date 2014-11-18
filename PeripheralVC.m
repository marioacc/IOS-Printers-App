//
//  PeripheralVC.m
//  BluetoothTest
//
//  Created by CITA on 11/13/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import "PeripheralVC.h"

@interface PeripheralVC ()

@end

@implementation PeripheralVC
@synthesize infoPeripheral;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    textPeripheral.text = self.infoPeripheral;
    textservice.text = self.infoServices;
    textCharacteristics.text = self.infoCharacteristics;
    newPeripheral = self.peripheral;
    newCharacteristic = self.characteristic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)send:(id)sender {
    NSString *str = sendText.text;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [newPeripheral writeValue:data forCharacteristic:newCharacteristic type:CBCharacteristicWriteWithResponse];
}
- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
    }
    else {
        NSLog(@"Success!");
    }
}
@end
