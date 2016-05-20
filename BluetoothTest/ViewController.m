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
    services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"8b8f8d60-6b64-11e4-a552-0002a5d5c51b"], nil];
    characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"c77fca60-6b64-11e4-a9b1-0002a5d5c51b"],[CBUUID UUIDWithString:@"32742960-6b65-11e4-a8ca-0002a5d5c51b"],[CBUUID UUIDWithString:@"b30e7bac-abcf-11e4-89d3-123b93f75cba"], nil];
    
    vendingMachines = [NSMutableDictionary dictionary];
    
    /*Caracteristicas de prueba con el IPAD*/
    //services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1813"], nil];
    //characteristics = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"2A31"],[CBUUID UUIDWithString:@"CABE"] , nil];
    
        myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    [self enableSendCash:NO];
    [self setupSocket];
    [self runSocket:@"getMoney"];
    [self waitingHUD:@"Searching Vendings"];
    
    cashTextLabel.layer.masksToBounds = YES;
    totalCashLabel.layer.masksToBounds=YES;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


/****************
 
    BUTTONS RELATED METHODS
 
  ****************/

- (IBAction)show:(id)sender {
    if (self.peripheral != nil){
        [self resetAppStatus];
        [myCentralManager scanForPeripheralsWithServices:services options:nil];
        
    }
    
}


- (IBAction)sendCash:(id)sender {
    //moneyInVending=[sendCashTextField.text doubleValue];
    NSString *moneyString=[NSString stringWithFormat:@"%.2f",([sendCashTextField.text doubleValue]*100)];
    moneyString=[self convertDecimalToHexString:moneyString];
    while([moneyString length] < 4){
        moneyString=[NSString stringWithFormat:@"0%@",moneyString];
    }
    //moneyString=[NSString stringWithFormat:@"0x%@",moneyString];
    
    NSData *data = [self convertHexStringToNSData:moneyString];
    NSLog(@"%@",data);
    [self.peripheral writeValue:data forCharacteristic:self.beginSessionCharacteristic type:CBCharacteristicWriteWithResponse];
    
    // The hud will disable all input on the view
    
    // Add HUD to screen
    
    
    
    // Register for HUD callbacks so we can remove it from the window at the right time
    
    waitingHUD.labelText = @"Choose your product";
    
    // Show the HUD while the provided method executes in a new thread
    
    [waitingHUD show:YES];
    [self.view endEditing:YES];
}



/****************
 
 BLUETOOTH RELATED METHODS
 
 ****************/
-(void) centralManagerDidUpdateState:(CBCentralManager *)central {

    if(central.state == CBCentralManagerStatePoweredOn) {
        waitingHUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view addSubview:waitingHUD];
//        waitingHUD.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading boton-01.png"]];
//        waitingHUD.mode=MBProgressHUDModeAnnularDeterminate;
        //[self waitingHUD:@"Searching vending machine"];
        //statusLabel.text = [NSString stringWithFormat:@"Searching vending machine"];
        [myCentralManager scanForPeripheralsWithServices:services options:nil];
    }
    else {
        statusLabel.text = [NSString stringWithFormat:@"Sorry, your smarthphone does not support this technology."];
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
    [myCentralManager stopScan];
    NSLog(@"Stopped scan");
    peripheral.delegate=self;
    self.peripheral=peripheral;
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
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"b30e7bac-abcf-11e4-89d3-123b93f75cba"]]){
            self.endSessionCharacteristic=characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        self.discoveredCharacteristics = [NSString stringWithFormat:@"%@",characteristic.value];
        [peripheral readValueForCharacteristic:characteristic];
    }
}

-(void) peripheral:(CBPeripheral *) peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *value = [NSString stringWithFormat:@"%@", characteristic.value];
    value = [value stringByReplacingOccurrencesOfString:@"<" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@">" withString:@""];
    value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([characteristic isEqual:self.endSessionCharacteristic]) {
        if (self.endSessionValue) {
            [self  verifyBuy:[[value substringFromIndex:8] substringToIndex:8]];
        }
        else{
            self.endSessionValue=value;
            NSLog(@"End Session Value : %@",value);
            
        }
        
    }else if ([characteristic isEqual:self.pricesCharacteristic]){
        self.pricesValue=value;
    }
    //NSLog(@" Valor de la caracteristica:%@", value);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
    }
    else {
        NSLog(@"Writing Succesful");
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error changing notification state to %@: %@", characteristic.description,
              [error localizedDescription]);
    }
    
    if (self.endSessionCharacteristic.isNotifying){
        NSLog(@"Subscribe succesfull!");
        [self enableSendCash:YES];
        statusLabel.text=[NSString stringWithFormat:@"Connected to %@",peripheral.name ];
        [statusButton setTitle:@"Close conection"  forState:UIControlStateNormal];
        [waitingHUD hide:YES];
    }
}

/****************
 
 TABLE VIEW RELATED METHODS
 
 ****************/

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
        [statusButton setTitle:[NSString stringWithFormat:@"Desconect from vending machine"]  forState:UIControlStateNormal];
        self.peripheral.delegate=self;
        [self waitingHUD:@"Connecting to Vending Machine"];
    }
    
    else if (peripheralName != self.peripheral.name && self.peripheral != nil) {
        CBPeripheral *newVending=[vendingMachines objectForKey:peripheralName];
        [self resetAppStatus];
        [myCentralManager connectPeripheral:newVending options:nil];
        [self waitingHUD:@"Connecting to Vending Machine"];
    }
    
    else if (peripheralName != self.peripheral.name && self.peripheral == nil) {
        CBPeripheral *newVending=[vendingMachines objectForKey:peripheralName];
        //[statusButton setTitle:[NSString stringWithFormat:@"Conectando a vending"]  forState:UIControlStateNormal];
        [myCentralManager connectPeripheral:newVending options:nil];
        [self waitingHUD:@"Connecting to Vending Machine"];
    }
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.textLabel.text = [devices objectAtIndex:indexPath.row];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Vendings available";
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] ;
//    [headerView setBackgroundColor:[UIColor colorWithRed:53.0 green:93.0 blue:133.0 alpha:1]];
//    return headerView;
//}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView * headerview = (UITableViewHeaderFooterView *)view;
    headerview.contentView.backgroundColor = self->totalCashLabel.backgroundColor ;
    headerview.textLabel.textColor = [UIColor whiteColor];
}

/****************
 
 GCDAsyncSocket RELATED METHODS
 
 ****************/

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"Message in the way");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"Problem sending message %@",error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *serverRespone=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([serverRespone isEqualToString:@"ok"]) {
        NSLog(@"Cargo añadido");
    }
    else if ([serverRespone intValue]){
        NSLog(serverRespone);
        cashTextLabel.text=[NSString stringWithFormat:@"$%@",serverRespone];
    }
}

- (void)setupSocket{
    NSError *error = nil;
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    if (![udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    NSLog(@"UDPSocket is ready");
}

-(void) runSocket:(NSString *)message{
    
    NSData *data = [
                    [NSString stringWithFormat:@"%@",message]
                    dataUsingEncoding:NSUTF8StringEncoding
                    ];
    [udpSocket sendData:data toHost:@"10.32.70.126" port:4582 withTimeout:-1 tag:0];
}
/****************
 
CONVERSION RELATED METHODS
 
 ****************/

-(void) verifyBuy: (NSString *) endSessionString{
    NSString *itemPriceHex=[endSessionString  substringToIndex:4];
    //NSString *vendItem=[endSessionString substringFromIndex:4];
    BOOL isVendUnsuccesful=[itemPriceHex isEqualToString:@"0000"];
    //BOOL isItemUnknown=[[endSessionString substringFromIndex:4] isEqualToString:@"ffff"];
    if (!isVendUnsuccesful) {
        float itemPriceDecimalUnstructured=[[self convertHexToDecimalString:itemPriceHex] floatValue]/100;
        NSString *itemPriceDecimal=[NSString stringWithFormat:@" %.2f",itemPriceDecimalUnstructured];
//        NSString *moneyInVending=sendCashTextField.text;
//        float chargueToPayFloat=([moneyInVending floatValue]-[itemPriceDecimal floatValue]);
//        NSString *chargueToPay=[NSString stringWithFormat:@"%.2f",itemPriceDecimal];
        [self runSocket:[NSString stringWithFormat:@"%@",itemPriceDecimal]];
        [waitingHUD hide:YES];
        [self succesfulHUDBuy:YES];
    }else if (isVendUnsuccesful){
        [waitingHUD hide:YES];
        [self succesfulHUDBuy:NO];
    }
    [self resetAppStatus];
}

-(NSString *) convertHexToDecimalString:(NSString *) hexString{
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&outVal];
    return [NSString stringWithFormat:@"%u",outVal];
}

-(NSString *) convertDecimalToHexString:(NSString *)decimalString{
    NSString *hexString = [NSString stringWithFormat:@"%lX",
                           (unsigned long)[decimalString integerValue]];
    return hexString;
    
}

-(NSData *) convertHexStringToNSData: (NSString *) hexString{
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[2];
    int i;
    for (i=0; i < hexString.length/2; i++) {
        
        byte_chars[0] = [hexString characterAtIndex:i*2];
        byte_chars[1] = [hexString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    
    return [NSData dataWithData:commandToSend];
    
}


/****************
 
RESET RELATED METHODS
 
 ****************/
-(void) resetAppStatus{
    [myCentralManager cancelPeripheralConnection:self.peripheral];
    [self enableSendCash:NO];
    [self runSocket:@"getMoney"];
    self.peripheral=nil;
    self.discoveredCharacteristics=nil;
    self.discoveredService=nil;
    self.pricesCharacteristic=nil;
    self.beginSessionCharacteristic=nil;
    self.endSessionCharacteristic=nil;
    self.pricesValue=nil;
    self.beginSessionValue=nil;
    self.endSessionValue=nil;
    [statusButton setTitle:@"Search vending machine" forState:UIControlStateNormal];
    statusLabel.text=@"";
    [self->tableView deselectRowAtIndexPath:[self->tableView indexPathForSelectedRow] animated:YES];
    
    
}

-(void) enableSendCash:(BOOL) enable{
    if (enable) {
        sendCashButton.enabled=YES;
        sendCashTextField.enabled=YES;
    }else{
        sendCashButton.enabled=NO;
        sendCashTextField.enabled=NO;
    }
    
}

-(void) succesfulHUDBuy:(BOOL)isSuccesful{
    MBProgressHUD *buyHUD=[[MBProgressHUD alloc] initWithView:self.view.window];
    [self.view addSubview:buyHUD];
    
    buyHUD.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success boton-03.png"]];
    buyHUD.mode=MBProgressHUDModeCustomView;
    buyHUD.delegate=self;
    //[self resetAppStatus];
    if (isSuccesful) {
        buyHUD.labelText=@"Succesful buy!";
        [buyHUD show:YES];
        [buyHUD hide:YES afterDelay:3];
    }else if (!isSuccesful){
        buyHUD.customView=nil;
        buyHUD.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verify boton-02.png"]];
        buyHUD.labelText=@"Verify your buy";
        [buyHUD show:YES];
        [buyHUD hide:YES afterDelay:3];
        
    }
    
}

-(void) waitingHUD:(NSString *) string{

    
    // Register for HUD callbacks so we can remove it from the window at the right time
    
    waitingHUD.labelText = string;
    
    // Show the HUD while the provided method executes in a new thread
    
    [waitingHUD show:YES];
    [self.view endEditing:YES];
}


@end
