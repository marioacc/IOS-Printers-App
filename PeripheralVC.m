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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    peripheralNameLabel.text = self.peripheral.name;
    pricesLabel.text = [self convertHexToIntString:self.pricesValue];
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
    //NSString *str = sendText.text;
    NSString *str= @"0x0000001";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [newPeripheral writeValue:data forCharacteristic:self.beginSessionCharacteristic type:CBCharacteristicWriteWithResponse];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(NSString *) convertHexToIntString:(NSString *) hexString{
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&outVal];
    return [NSString stringWithFormat:@"%u",outVal];
}

-(NSString *) convertIntToHexString:(NSString *) hexString{
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&outVal];
    return [NSString stringWithFormat:@"%u",outVal];
}

@end
