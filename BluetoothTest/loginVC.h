//
//  loginVC.h
//  BluetoothTest
//
//  Created by Mario Contreras on 2/23/15.
//  Copyright (c) 2015 itesm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface loginVC : UIViewController<UITextInputDelegate>{

    __weak IBOutlet UITextField *nameTextField;

    __weak IBOutlet UITextField *passwordTextField;
    GCDAsyncUdpSocket *udpSocket ;
    BOOL *shouldPerformSegue;
    

}
/*!
 * @discussion This method verify the identity of the user.
 */
-(void) verifyIdentity;


/*!
 * @discussion This methods creates a socket and send a message to the server
 */
-(void) runLoginSocket: (NSString *) message;
- (IBAction)loginButton:(id)sender;
@end
