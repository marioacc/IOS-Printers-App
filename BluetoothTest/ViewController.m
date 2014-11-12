//
//  ViewController.m
//  BluetoothTest
//
//  Created by CITA on 11/6/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)show:(id)sender {
    myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (IBAction)send:(id)sender {
}
-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    testText.text = [NSString stringWithFormat:@"%@", central];
    if(central.state == CBCentralManagerStatePoweredOn) {
        testText.text = [NSString stringWithFormat:@"Start scanning..."];
        [myCentralManager scanForPeripheralsWithServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1804"], nil] options:nil];
    }
    else {
        testText.text = [NSString stringWithFormat:@"Not supported"];
    }
}

-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"%@",peripheral.name);
    if(peripheral.name != nil) {
        [myCentralManager connectPeripheral:peripheral options:nil];
        self.connectingPeripheral = peripheral;
        peripheral.delegate = self;
        peripherals.text = [NSString stringWithFormat:@"Connected to %@" ,self.connectingPeripheral.name];
    }
    }
-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to %@", peripheral.name);
    [myCentralManager stopScan];
    [peripheral discoverServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1810"], nil]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for(CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
-(void) peripheral:(CBPeripheral *) peripheral didModifyServices:(NSArray *)invalidatedServices {
    
}

-(void) peripheral:(CBPeripheral *) peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for(CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
}
-(void) peripheral:(CBPeripheral *) peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSData *info = characteristic.value;
    sendText.text = [NSString stringWithFormat:@"%@", info];
}
@end
