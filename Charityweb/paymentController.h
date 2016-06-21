//
//  paymentController.h
//  Charityweb
//
//  Created by Peter Hansen on 12/23/14.
//  Copyright (c) 2014 Peter Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
@import PassKit;
@interface paymentController : UIViewController<PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableData *_responseData;
}
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UISwitch *otherAmountSwitch;
@property (strong, nonatomic) IBOutlet UITextField *otherAmount;
@property (strong, nonatomic) IBOutlet UIView *backButton;
@property (weak, nonatomic) IBOutlet UIButton *donateButton;
@property (strong, nonatomic) NSString *merchantID;
@property (strong, nonatomic) NSDictionary *json;
@property (strong, nonatomic) NSMutableArray *defaultOptions;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *activeObjects;
@property (strong, nonatomic) NSMutableArray *honorarySwitches;
@property (strong, nonatomic) NSMutableArray *honoraryDonationObjects;
@property (strong, nonatomic) NSMutableArray *listBoxes;
@property (strong, nonatomic) NSMutableArray *listPickers;
@property (strong, nonatomic) NSLocale *currentLocale;
@property (strong, nonatomic) NSMutableArray *countries;
@property (strong, nonatomic) NSArray *states;
@property (strong, nonatomic) NSArray *titles;
@property (strong ,nonatomic) NSMutableDictionary *pickerViewValues;
@end
