//
//  ViewController.m
//  BluetoothTest
//
//  Created by CITA on 11/6/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import "ViewController.h"
#import "PeripheralVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    devices = [NSMutableArray arrayWithObjects: nil];
    /*Cacracteristicas para el modulo bluetooth*/
    services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"8b8f8d60-6b64-11e4-a552-0002a5d5c51b"], nil];
    characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"c77fca60-6b64-11e4-a9b1-0002a5d5c51b"],[CBUUID UUIDWithString:@"32742960-6b65-11e4-a8ca-0002a5d5c51b"], nil];
    
    
    /*Caracteristicas de prueba con el IPAD*/
//    services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1813"], nil];
//    characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"2A31"],[CBUUID UUIDWithString:@"CABE"] , nil];
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
        [myCentralManager scanForPeripheralsWithServices:services options:nil];
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
        if(![devices containsObject:_connectingPeripheral.name]) {
            [devices addObject:self.connectingPeripheral.name];
            [tableView reloadData];
        }
    }
}
-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to %@", peripheral.name);
    testText.text = [NSString stringWithFormat:@"Connected"];
    [myCentralManager stopScan];
    NSLog(@"Stopped scan");
    [peripheral discoverServices:services];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for(CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service.UUID);
        self.discoveredService = [NSString stringWithFormat:@"%@",service.UUID];
        [peripheral discoverCharacteristics:characteristics forService:service];
    }
}


-(void) peripheral:(CBPeripheral *) peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for(CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic.UUID);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"c77fca60-6b64-11e4-a9b1-0002a5d5c51b"]]){
            self.beginSessionCharacteristic=characteristic;
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"32742960-6b65-11e4-a8ca-0002a5d5c51b"]]){
            self.pricesCharacteristic=characteristic;
        }
        self.discoveredCharacteristics = [NSString stringWithFormat:@"%@",characteristic.value];
        [peripheral readValueForCharacteristic:characteristic];
    }
}
-(void) peripheral:(CBPeripheral *) peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *value = [NSString stringWithFormat:@"%@", characteristic.value];
    value = [value stringByReplacingOccurrencesOfString:@"<" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
    if ([characteristic isEqual:self.beginSessionCharacteristic]) {
        self.beginSessionValue=value;
    }else if ([characteristic isEqual:self.pricesCharacteristic]){
        self.pricesValue=value;
    }
     NSLog(@" Valor de la caracteristica:%@", value);
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [devices count];
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"infovc" sender:nil];
    
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.textLabel.text = [devices objectAtIndex:indexPath.row];
    return cell;
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
       if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
    }
    else {
        NSLog(@"Success!");
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"infovc"])
    {
        // Get reference to the destination view controller
        PeripheralVC *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        
        vc.pricesCharacteristic=self.pricesCharacteristic;
        vc.beginSessionCharacteristic=self.beginSessionCharacteristic;
        
        vc.pricesValue=self.pricesValue;
        vc.beginSessionValue=self.beginSessionValue;
        
        vc.peripheral = self.connectingPeripheral;
        
    }
}
@end
