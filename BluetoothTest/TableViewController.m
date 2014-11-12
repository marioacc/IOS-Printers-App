//
//  TableViewController.m
//  BluetoothTest
//
//  Created by CITA on 11/11/14.
//  Copyright (c) 2014 itesm. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (IBAction)show:(id)sender {
    myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    testText.text = [NSString stringWithFormat:@"%@", central];
    if(central.state == CBCentralManagerStatePoweredOn) {
        testText.text = [NSString stringWithFormat:@"Start scanning"];
        [myCentralManager scanForPeripheralsWithServices:(NSArray *)UUID options:nil];
    }
    else {
        testText.text = [NSString stringWithFormat:@"Not supported"];
    }
}

-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"%@",peripheral.name);
    if(peripheral.name != nil) {
        [central connectPeripheral:peripheral options:nil];
        self.connectingPeripheral = peripheral;
        peripherals.text = self.connectingPeripheral.name;
        [myCentralManager connectPeripheral:peripheral options:nil];
    }
}
-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to %@", peripheral.name);
    [myCentralManager stopScan];
}
@end
