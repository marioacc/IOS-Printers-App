//
//  loginVC.h
//  BluetoothTest
//
//  Created by Mario Contreras on 2/23/15.
//  Copyright (c) 2015 itesm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface loginVC : UIViewController<UITextInputDelegate>{

    __weak IBOutlet UITextField *nameTextField;

    __weak IBOutlet UITextField *passwordTextField;
    

}
/*!
 * @discussion This method verify the identity of the user.
 */

-(BOOL) verifyIdentity;
@end
