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

-(BOOL) verifyIdentity{
    NSString *name=nameTextField.text;
    NSString *password=passwordTextField.text;
    if ( [name isEqual:@""] || [password isEqual:@""] ){
        UIAlertView *dataNotFilled = [[UIAlertView alloc] initWithTitle:@"Incorrect Name/Password "
                                                          message:@"Please verify your data"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [dataNotFilled show];
        return NO;
    }else if ([password isEqual:[name substringToIndex:4]]){
        return YES;
    }
    return NO;
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return [self verifyIdentity];
}
@end

