//
//  loginVC.m
//  BluetoothTest
//
//  Created by Mario Contreras on 2/23/15.
//  Copyright (c) 2015 itesm. All rights reserved.
//

#import "loginVC.h"

@interface loginVC ()

@end

@implementation loginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqual:@"toVendingViewSegue"]){
    }
}


-(void) runLoginSocket:(NSString *)message{

    NSData *data = [
                    [NSString stringWithFormat:message]
                    dataUsingEncoding:NSUTF8StringEncoding
                    ];
    [udpSocket sendData:data toHost:@"10.32.70.126" port:4582 withTimeout:-1 tag:0];
}

- (IBAction)loginButton:(id)sender {
    [self setupSocket];
    [self runLoginSocket:@"getUser"];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
    NSArray *userData=[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@";"];
    NSString *userName=nameTextField.text;
    NSString *userPassword=passwordTextField.text;
    if ([nameTextField.text isEqualToString:userData[0]] && [passwordTextField.text isEqualToString:userData[1]]){
        [self performSegueWithIdentifier:@"toVendingViewSegue" sender:self];
    }else {
        UIAlertView *dataNotFilled = [[UIAlertView alloc] initWithTitle:@"Incorrect Name/Password "
                                                                message:@"Please verify your data"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
        [dataNotFilled show];
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


@end

