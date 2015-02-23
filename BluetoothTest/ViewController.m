//
//  ViewController.m
//  BluetoothTest
//
//  Created by CITA on 11/6/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import "ViewController.h"
#import "buyingVC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    devices = [NSMutableArray arrayWithObjects: nil];
    
    /*Cacracteristicas para el modulo bluetooth*/
//    services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"8b8f8d60-6b64-11e4-a552-0002a5d5c51b"], nil];
//    characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"c77fca60-6b64-11e4-a9b1-0002a5d5c51b"],[CBUUID UUIDWithString:@"32742960-6b65-11e4-a8ca-0002a5d5c51b"], nil];
    
    vendingMachines = [NSMutableDictionary dictionary];
    
    /*Caracteristicas de prueba con el IPAD*/
    services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1813"], nil];
    characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"2A31"],[CBUUID UUIDWithString:@"CABE"] , nil];
    
        myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    testText.text = [NSString stringWithFormat:@"%@", central];
    if(central.state == CBCentralManagerStatePoweredOn) {
        testText.text = [NSString stringWithFormat:@"Buscando Vending Machines"];
        [myCentralManager scanForPeripheralsWithServices:services options:nil];
    }
    else {
        testText.text = [NSString stringWithFormat:@"Lo sentimos, el telefono no soporta esta tecnologia."];
    }
}

-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"%@",peripheral.name);
    if(peripheral.name != nil) {
        
        if(![devices containsObject:peripheral.name]) {
            [vendingMachines setObject:peripheral forKey:peripheral.name];
            [devices addObject:[NSString stringWithFormat:@"%@",peripheral.name]];
            [tableView reloadData];
        }
    }
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to %@", peripheral.name);
    testText.text = [NSString stringWithFormat:@"Conectado a la Vending 1"];
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
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *peripheralName=cell.textLabel.text;
    if (peripheralName == self.peripheral.name ) {
        self.peripheral=[vendingMachines objectForKey:peripheralName];
        [myCentralManager connectPeripheral:self.peripheral options:nil];
        self.peripheral.delegate=self;
    }
    
    else if (peripheralName != self.peripheral.name && self.peripheral.name != nil) {
        CBPeripheral *newVending=[vendingMachines objectForKey:peripheralName];
        [myCentralManager cancelPeripheralConnection:self.peripheral];
        [myCentralManager connectPeripheral:newVending options:nil];
    }
   
        
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
    if ([[segue identifier] isEqualToString:@"butyingvc"])
    {
        
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(NSString *) convertHexToDecimalString:(NSString *) hexString{
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&outVal];
    return [NSString stringWithFormat:@"%u",outVal];
}

-(NSString *) convertDecimalToHexString:(NSString *)decimalString{
    NSString *hexString = [NSString stringWithFormat:@"0x%lX",
                     (unsigned long)[decimalString integerValue]];
    return hexString;
    
}

//Buttons methods
- (IBAction)show:(id)sender {
    myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}


- (IBAction)sendCash:(id)sender {
    NSString *hexString= @"0x000000000";
    NSString *moneyString=sendCashTextLabel.text;
    [hexString stringByAppendingString:moneyString];
    NSData *data = [hexString dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.beginSessionCharacteristic type:CBCharacteristicWriteWithResponse];
    [self performSegueWithIdentifier:@"buyingvc" sender:self];
    
}


@end
