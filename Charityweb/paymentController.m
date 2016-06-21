//
//  paymentController.m
//  Charityweb
//
//  Created by Peter Hansen on 12/23/14.
//  Copyright (c) 2014 Peter Hansen. All rights reserved.
//

#import "paymentController.h"
#import "Stripe.h"
#import "Stripe+ApplePay.h"
#import "processingController.h"
#import "PKPayment+STPTestKeys.h"
#import "STPTestPaymentAuthorizationViewController.h"
#import "PTKView.h"
#import <PassKit/PassKit.h>
#import <QuartzCore/QuartzCore.h>
#import <math.h>
@implementation paymentController
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
{
    if (textField.frame.origin.y > 250) {
        _scrollView.contentOffset = CGPointMake( 0, textField.frame.origin.y - 250); //required offset
        //provide contentOffSet those who needed
    } else {
        _scrollView.contentOffset = CGPointMake(0, 0);
    }
    if ([_listBoxes containsObject:textField]) {
        for (int x = 0; x < _listBoxes.count; x++) {
            if ([textField isEqual: _listBoxes[x]]) {
                UIPickerView *aPickerView = _listPickers[x];
                if ([aPickerView.accessibilityLabel isEqualToString:@"Country"]) {
                    textField.text = @"United States";
                }
                if ([aPickerView.accessibilityLabel isEqualToString:@"State"]) {
                    textField.text = @"Alabama";
                }
                if ([aPickerView.accessibilityLabel isEqualToString:@"Title"]) {
                    textField.text = @"Mr.";
                }
            }
        }
    }
    return YES;
}

-(void) hideKeyBoard:(id) sender
{
    // Do whatever such as hiding the keyboard
        [self.view endEditing:YES];
}
// A method that catches all touches made. I am currently using it to close the keyboard
// if you touch on something that doesn't need it.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    // If the touch isn't on a UITextField, close the keyboard,
    // we don't need it anymore
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
        _scrollView.contentOffset = CGPointMake(0,0); //make UIScrollView as it was before
    }
    [super touchesBegan:touches withEvent:event];
}
-(IBAction)amountSelect:(id)sender {
    if ([sender isOn]) {
        for (UISwitch *object in _defaultOptions) {
            if (object != sender) {
                [object setOn:false animated:YES];
            }
        }
        if (sender != _otherAmountSwitch) {
            [_otherAmountSwitch setOn:false animated:YES];
        }
    } else {
        [_otherAmountSwitch setOn:true animated:YES];
    }
}
-(IBAction)honoraryDonationSelect:(id)sender {
    if ([sender isOn]) {
        for (UIView *object in _honoraryDonationObjects) {
            object.hidden = false;
        }
        [self changeScreenLength:330];
    } else {
        for (UIView *object in _honoraryDonationObjects) {
            object.hidden = true;
        }
        [self changeScreenLength:-330];
    }
    [self honorarySwitchHelper:sender];
}
-(void)honorarySwitchHelper:(id)sender {
    if ([sender isOn]) {
        for (UISwitch *hSwitch in _honorarySwitches) {
            if (![hSwitch isEqual:sender] && [hSwitch isOn]) {
                [hSwitch setOn:false animated:YES];
                [self changeScreenLength:-330];
            }
        }
    }
}
-(void)changeScreenLength:(int)extraSpace {
    if (_scrollView.contentSize.height + extraSpace < self.view.frame.size.height) {
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    } else {
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height + extraSpace);
    }
}
-(int)generateAdditionalQuestions:(int)position {
    BOOL left = true;
    for (NSString *key in _json[@"additionalQuestions"]) {
        UILabel *aLabel;
        if (left) {
            aLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, position, 169, 21)];
        } else {
            aLabel = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, position, 169, 21)];
        }
        NSString *name = _json[@"additionalQuestions"][key][@"Name"];
        aLabel.text = name;
        [_scrollView addSubview:aLabel];
        NSString *type = _json[@"additionalQuestions"][key][@"Type"];
        position += 28;
        if ([type isEqual: @"text"]) {
            UITextField *aTextfield;
            if (left) {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake(16, position, 130, 30)];
            } else {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, position, 130, 30)];
                position += 35;
            }
            aTextfield.backgroundColor = [UIColor whiteColor];
            aTextfield.delegate = self;
            [_scrollView addSubview:aTextfield];
        }
        if ([type isEqual:@"list"] && [name isEqual:@"Country"]) {
            UITextField *aTextfield;
            if (left) {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake(16, position, 130, 30)];
            } else {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, position, 130, 30)];
                position += 35;
            }
            UIPickerView *aPicker = [[UIPickerView alloc] init];
            [aPicker setDataSource:self];
            [aPicker setDelegate:self];
            [aPicker setShowsSelectionIndicator:YES];
            aPicker.accessibilityLabel = @"Country";
            aTextfield.inputView = aPicker;
            aTextfield.backgroundColor = [UIColor whiteColor];
            aTextfield.delegate = self;
            [_scrollView addSubview:aTextfield];
            [_listBoxes addObject:aTextfield];
            [_listPickers addObject:aPicker];
        }
        if ([type isEqual:@"list"] && [name isEqual:@"State"]) {
            UITextField *aTextfield;
            if (left) {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake(16, position, 130, 30)];
            } else {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, position, 130, 30)];
                position += 35;
            }
            UIPickerView *aPicker = [[UIPickerView alloc] init];
            [aPicker setDataSource:self];
            [aPicker setDelegate:self];
            [aPicker setShowsSelectionIndicator:YES];
            aPicker.accessibilityLabel = @"State";
            aTextfield.inputView = aPicker;
            aTextfield.backgroundColor = [UIColor whiteColor];
            aTextfield.delegate = self;
            [_scrollView addSubview:aTextfield];
            [_listBoxes addObject:aTextfield];
            [_listPickers addObject:aPicker];
        }
        if ([type isEqual:@"list"] && [name isEqual:@"Title"]) {
            UITextField *aTextfield;
            if (left) {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake(16, position, 130, 30)];
            } else {
                aTextfield = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, position, 130, 30)];
                position += 35;
            }
            UIPickerView *aPicker = [[UIPickerView alloc] init];
            [aPicker setDataSource:self];
            [aPicker setDelegate:self];
            [aPicker setShowsSelectionIndicator:YES];
            aPicker.accessibilityLabel = @"Title";
            aTextfield.inputView = aPicker;
            aTextfield.backgroundColor = [UIColor whiteColor];
            aTextfield.delegate = self;
            [_scrollView addSubview:aTextfield];
            [_listBoxes addObject:aTextfield];
            [_listPickers addObject:aPicker];
        }
        if ([type isEqual:@"checkbox"]) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(15, position, 0, 0)];
            if (left) {
                aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(15, position, 0, 0)];
            } else {
                aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, position, 0, 0)];
                position += 41;
            }
            [aSwitch setOn:false];
            [_scrollView addSubview:aSwitch];
        }
        if (left) {
            position -= 28;
        }
        left = !left;
    }
    return position;
}
-(int)generateHonoraryDonationForm:(int)position {
    _honoraryDonationObjects = [[NSMutableArray alloc] init];
    _honorarySwitches = [[NSMutableArray alloc] init];
    UILabel *thisDonationIsMade = [[UILabel alloc] initWithFrame:CGRectMake(10, position, 169, 21)];
    thisDonationIsMade.text = @"This donation is made";
    [_scrollView addSubview:thisDonationIsMade];
    UISwitch *inHonorOfSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(15, position+29, 0, 0)];
    [_scrollView addSubview:inHonorOfSwitch];
    [_honorarySwitches addObject:inHonorOfSwitch];
    [inHonorOfSwitch addTarget:self action:@selector(honoraryDonationSelect:) forControlEvents:UIControlEventValueChanged];
    UISwitch *inMemoryOfSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(15, position+68, 0, 0)];
    [inMemoryOfSwitch setOn:false];
    [_scrollView addSubview:inMemoryOfSwitch];
    [_honorarySwitches addObject:inMemoryOfSwitch];
    [inMemoryOfSwitch addTarget:self action:@selector(honoraryDonationSelect:) forControlEvents:UIControlEventValueChanged];
    UILabel *inHonorOfLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, position+34, 83, 21)];
    inHonorOfLabel.text = @"In honor of";
    [_scrollView addSubview:inHonorOfLabel];
    UILabel *inMemoryOfLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, position+73, 101, 21)];
    inMemoryOfLabel.text = @"In memory of";
    [_scrollView addSubview:inMemoryOfLabel];
    UILabel *pleaseSendNotificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, position + 125, self.view.frame.size.width-17, 90)];
    pleaseSendNotificationLabel.text = @"Please send notification of this donation to:";
    [pleaseSendNotificationLabel setFont:[pleaseSendNotificationLabel.font fontWithSize:26]];
    pleaseSendNotificationLabel.numberOfLines = 2;
    [_scrollView addSubview:pleaseSendNotificationLabel];
    [_honoraryDonationObjects addObject:pleaseSendNotificationLabel];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, position+207, 46, 21)];
    nameLabel.text = @"Name";
    [_scrollView addSubview:nameLabel];
    [_honoraryDonationObjects addObject:nameLabel];
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(16, position+229, 97, 30)];
    nameText.backgroundColor = [UIColor whiteColor];
    nameText.delegate = self;
    [_scrollView addSubview:nameText];
    [_honoraryDonationObjects addObject:nameText];
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, position+267, 64, 21)];
    addressLabel.text = @"Address";
    [_scrollView addSubview:addressLabel];
    [_honoraryDonationObjects addObject:addressLabel];
    UITextField *addressText = [[UITextField alloc] initWithFrame:CGRectMake(16, position + 291, 140, 30)];
    addressText.backgroundColor = [UIColor whiteColor];
    addressText.delegate = self;
    [_scrollView addSubview:addressText];
    [_honoraryDonationObjects addObject:addressText];
    UILabel *address2Label = [[UILabel alloc] initWithFrame:CGRectMake(159, position + 267, 114, 21)];
    address2Label.text = @"Address, line 2";
    [_scrollView addSubview:address2Label];
    [_honoraryDonationObjects addObject:address2Label];
    UITextField *address2Text = [[UITextField alloc] initWithFrame:CGRectMake(159, position + 291, 145, 30)];
    address2Text.backgroundColor = [UIColor whiteColor];
    address2Text.delegate = self;
    [_scrollView addSubview:address2Text];
    [_honoraryDonationObjects addObject:address2Text];
    UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, position + 329, 31, 21)];
    cityLabel.text = @"City";
    [_scrollView addSubview:cityLabel];
    [_honoraryDonationObjects addObject:cityLabel];
    UITextField *cityText = [[UITextField alloc] initWithFrame:CGRectMake(16, position + 354, 97, 30)];
    cityText.backgroundColor = [UIColor whiteColor];
    cityText.delegate = self;
    [_scrollView addSubview:cityText];
    [_honoraryDonationObjects addObject:cityText];
    UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, position + 329, 113, 21)];
    stateLabel.text = @"State";
    [_scrollView addSubview:stateLabel];
    [_honoraryDonationObjects addObject:stateLabel];
    UITextField *stateText = [[UITextField alloc] initWithFrame:CGRectMake(119, position + 354, 114, 30)];
    stateText.backgroundColor = [UIColor whiteColor];
    stateText.delegate = self;
    [_scrollView addSubview:stateText];
    [_honoraryDonationObjects addObject:stateText];
    UILabel *zipLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, position + 392, 100, 21)];
    zipLabel.text = @"Zip Code";
    [_scrollView addSubview:zipLabel];
    [_honoraryDonationObjects addObject:zipLabel];
    UITextField *zipText = [[UITextField alloc] initWithFrame:CGRectMake(16, position + 414, 70, 30)];
    zipText.backgroundColor = [UIColor whiteColor];
    zipText.delegate = self;
    zipText.keyboardType = UIKeyboardTypeNumberPad;
    [_scrollView addSubview:zipText];
    [_honoraryDonationObjects addObject:zipText];
    for (UIView *object in _honoraryDonationObjects) {
        object.hidden = true;
    }
    return position + 100;
}
- (IBAction)donate:(id)sender {
    PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:_merchantID];
    // Configure your request here.
    NSString *label = @"Donation";
    NSString *donationAmount = @"";
    for (UISwitch *object in _defaultOptions) {
        if ([object isOn]) {
            donationAmount = object.accessibilityLabel;
        }
    }
    if ([donationAmount  isEqual: @"Other"]) {
        donationAmount = _otherAmount.text;
        NSDecimalNumber *testNum = [NSDecimalNumber decimalNumberWithString:donationAmount];
        if ([testNum isEqualToNumber:[NSDecimalNumber notANumber]]) {
                NSString *message = @"Please enter a donation ammount.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            return;
        }
    }
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:donationAmount];
    request.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount] ];
    
    if ([Stripe canSubmitPaymentRequest:request]) {
#if DEBUG
        STPTestPaymentAuthorizationViewController *controller = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        controller.delegate = self;
        
#else
        PKPaymentAuthorizationViewController controller = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
        controller.delegate = self;
#endif
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        // TODO: prompt user to configure apple pay
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _listPickers = [[NSMutableArray alloc] init];
    _listBoxes = [[NSMutableArray alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    
    _countries = [[NSMutableArray alloc] init];
    for (NSString *countryCode in countryArray) {
        NSString *countryName = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        if (![countryName isEqualToString:@"United States"]) {
            [_countries addObject:countryName];
        }
    }
    [_countries sortUsingSelector:@selector(localizedCompare:)];
    [_countries addObject:@"null"];
    for (int i = 248; i > 0; i--) {
        _countries[i] = _countries[i - 1];
    }
    _countries[0] = @"United States";
    _states = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Delaware", @"Florida", @"Georgia", @"Hawaii", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Kansas", @"Kentucky", @"Louisiana", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Mississippi", @"Missouri", @"Montana", @"Nebraska", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oklahoma", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Carolina", @"South Dakota", @"Tennessee", @"Texas", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming", nil]];
    _titles = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:@"Mr.", @"Mrs", @"Ms.", @"Miss", @"Dr.", @"Mr. and Mrs.", nil]];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    [_scrollView addGestureRecognizer:gestureRecognizer];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(back:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Back" forState:UIControlStateNormal];
    button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 90, 28, 74, 39);
    _backButton = button;
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [aButton addTarget:self
               action:@selector(donate:)
     forControlEvents:UIControlEventTouchUpInside];
    [aButton setTitle:@"Donate" forState:UIControlStateNormal];
    aButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 162, 33, 50, 30);
    _donateButton = aButton;
    _backButton.backgroundColor = [UIColor whiteColor];
    _donateButton.backgroundColor = [UIColor whiteColor];
    [_topView addSubview:_scrollView];
    [_scrollView addSubview:_donateButton];
    [_scrollView addSubview:_backButton];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, 98, 21)];
    [_scrollView addSubview:label];
    CALayer *btnLayer = [_backButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    btnLayer = [_donateButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    _defaultOptions = [[NSMutableArray alloc]init];
    int numSwitches = 0;
    for (NSString *key in _json[@"defaultDonations"]) {
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(15, 49 + numSwitches*34, 0, 0)];
        [mySwitch addTarget:self action:@selector(amountSelect:) forControlEvents:UIControlEventValueChanged];
        mySwitch.accessibilityLabel = _json[@"defaultDonations"][key];
        UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(69, 49 +numSwitches*34, 280, 21)];
        myLabel.text = [NSString stringWithFormat:@"$%@", _json[@"defaultDonations"][key]];
        [_defaultOptions addObject:mySwitch];
        [_scrollView addSubview:mySwitch];
        [_scrollView addSubview:myLabel];
        numSwitches++;
    }
    if ([_defaultOptions count] == 0) {
        _otherAmount = [[UITextField alloc] initWithFrame:CGRectMake(15, 49, 100, 30)];
        _otherAmount.backgroundColor = [UIColor whiteColor];
        _otherAmountSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _otherAmountSwitch.hidden = true;
        _otherAmountSwitch.on = true;
        [_otherAmountSwitch addTarget:self action:@selector(amountSelect:) forControlEvents:UIControlEventValueChanged];
        UILabel *ammountLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 49, 100, 21)];
        ammountLabel.text = @"Donation Amount";
        
    } else {
        _otherAmount = [[UITextField alloc] initWithFrame:CGRectMake(189, 49 + numSwitches*34, 100, 30)];
        _otherAmount.backgroundColor = [UIColor whiteColor];
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(69, 49 + numSwitches*34, 120, 21)];
        myLabel.text = @"Other Amount";
        _otherAmountSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(15, 49 + numSwitches*34, 0, 0)];
        [_otherAmountSwitch addTarget:self action:@selector(amountSelect:) forControlEvents:UIControlEventValueChanged];
        [_scrollView addSubview:myLabel];
        [_scrollView addSubview:_otherAmountSwitch];
        [_scrollView addSubview:_otherAmount];
    }
    _otherAmountSwitch.accessibilityLabel = @"Other";
    [_defaultOptions addObject:_otherAmountSwitch];
    int position = [self generateAdditionalQuestions:250];
    int extraSpace = [self generateHonoraryDonationForm:position] - self.view.frame.size.height + 20;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + extraSpace);
}
-(void)viewDidAppear:(BOOL)animated {
    
}
- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [Stripe createTokenWithPayment:payment
                        completion:^(STPToken *token, NSError *error) {
                            if (error) {
                                completion(PKPaymentAuthorizationStatusFailure);
                                return;
                            }
                            [self createBackendChargeWithToken:token completion:completion];
                        }];
}
- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSURL *url = [NSURL URLWithString:@"http://www.charityweb.net/"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   completion(PKPaymentAuthorizationStatusFailure);
                               } else {
                                   completion(PKPaymentAuthorizationStatusSuccess);
                               }
                           }];
   
}

#pragma mark PKPaymentAuthorizationViewControllerDelegate methods
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark PickerView DataSource
// This method sets the text of each textfield to the value selected on the pickerview
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component {
//    if (pickerView == self.databasePicker) {
//        NSString *db = [self pickerView:_databasePicker titleForRow:[_databasePicker selectedRowInComponent:0] forComponent:0];
//        [databaseSelect setText:db];
//        if ([db rangeOfString:@"RNAseq"].location == NSNotFound) {
//            _GSEA.hidden = true;
//        } else {
//            _GSEA.hidden = false;
//        }
//        for (UIView *object in _activeObjects) {
//            object.hidden = true;
//        }
//        [_activeObjects removeAllObjects];
//        // Here we're going to chop up the html response to find all the databases we have access to
//        NSString *temp = [[NSMutableString alloc]init];
//        NSArray* splittedArray= [_databaseHtml componentsSeparatedByString:@"<td align=center><a href='"];
//        NSMutableArray* loopArray = [splittedArray mutableCopy];
//        [loopArray removeObjectAtIndex:0];
//        NSArray* splittedStr = [[NSArray alloc]init];
//        NSArray* splittedStrv2 = [[NSArray alloc]init];
//        NSArray* splittedStrv3 = [[NSArray alloc]init];
//        _databaseIDs = [[NSMutableDictionary alloc]init];
//        self.databases = [[NSMutableArray alloc]init];
//        // for each db_help, there has to be a db. So loopArray should hold all the db's in it
//        for (NSString *str in loopArray) {
//            // We don't want any of the html to show up for the user, so right here it's being cut out
//            splittedStr = [str componentsSeparatedByString:@">"];
//            temp = [splittedStr[1] substringToIndex:[splittedStr[1] length]-3];
//            
//            if([temp length] != 1) {
//                [_databases addObject:(temp)];
//            }
//            splittedStrv2 = [str componentsSeparatedByString:@"db="];
//            splittedStrv3 = [splittedStrv2[1] componentsSeparatedByString:@";"];
//            NSString *key = [splittedStrv3 objectAtIndex:0];
//            _databaseIDs[temp] = key;
//        }
//        NSError *error;
//        NSString *htmlPage = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?rm=query_all;db=%@;source=cdna", globalURL, _databaseIDs[db]]] encoding:NSASCIIStringEncoding error:&error];
//        // The following set of code disects the <select> objects and extracts every option. The first one puts all the samples in _samples.
//        // This one takes all the genesets and puts them in _genesets
//        NSArray *sampleFinder = [htmlPage componentsSeparatedByString:@"<select name=\"exprs\""];
//        NSArray *sampleFinder2 = [sampleFinder[1] componentsSeparatedByString:@"</select>"];
//        NSMutableArray *sampleFinder3 = [[sampleFinder2[0] componentsSeparatedByString:@"<option"] mutableCopy];
//        [sampleFinder3 removeObjectAtIndex:0];
//        _genesets = [[NSMutableDictionary alloc]init];
//        _heatmapValues = [[NSMutableArray alloc]init];
//        NSArray *sampleFinder4 = [[NSArray alloc]init];
//        NSString *key = [[NSString alloc]init];
//        NSString *url = [[NSString alloc]init];
//        // each geneset has both a display name and an address for where the file is, so each display name (the key)
//        // has to be mapped to the address (the url, or object)
//        for (NSString *object in sampleFinder3) {
//            sampleFinder4 = [object componentsSeparatedByString:@">"];
//            if([sampleFinder4 count] == 3) {
//                key = sampleFinder4[1];
//                key = [key stringByReplacingOccurrencesOfString:@"   " withString:@" "];
//                key = [key stringByReplacingOccurrencesOfString:@"</option" withString:@""];
//                sampleFinder4 = [sampleFinder4[0] componentsSeparatedByString:@"value=\""];
//                url = sampleFinder4[1];
//                url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//                url = [url stringByReplacingOccurrencesOfString:@"=" withString:@""];
//                [_genesets setObject:url forKey:key];
//                [_heatmapValues addObject:key];
//            }
//        }
//        _switches = [[NSMutableArray alloc]init];
//        _realKeys = [[NSMutableDictionary alloc]init];
//        _orderBy = [[NSMutableArray alloc]init];
//        // Getting all the preset checkboxes is a little more complicated, so here a lot of manipulation has to be done.
//        // This isn't going to make a lot of sense unless you go and look at the html that's being recieved from the server.
//        // when you see it, it will make sense why each of these manipulations are being done.
//        // componentsSeparatedByString is the exact same as javascript .split("foobar");
//        NSMutableArray *msampleFinder = [[htmlPage componentsSeparatedByString:@"<input type=\"checkbox\" name=\"annot\" value=\""] mutableCopy];
//        [msampleFinder removeObjectAtIndex:0];
//        // Put a break point here and just look at the contents of each msampleFinder and it'll make sense.
//        // The last object is just going to be a bunch of gunk html that gives us the rest of the page data, but we don't care about that
//        // because we only wanted the check boxes
//        // The following code generates the switches, the labels describing them, and the data each one will provide if turned on.
//        // These are counters, c is what row the next switch should be generated on, and s is the catagory the next switch should be placed under.
//        int c = 0;
//        NSArray *dummyArray = [[NSArray alloc]init];
//        // we need to figure out how many switches we're going to use for each catagory so we can devide them evenly between the
//        // two columns on the iPad. The way I decided to do that was to just count up all of the elements of msampleFinder_ that
//        // will eventually be turned into switches and labels. Note that int objects cannot be put into NSMutableArrays because
//        // arrays can only hold pointers, and int is a native object without a pointer, so I recast it as an NSNumber.
//        NSNumber *numberOfSwitchesNeeded = [[NSNumber alloc]initWithInt:[msampleFinder count]];
//        // count is our overall number of switches + 1. The +1 is so that when necessary the next element in the array can be accessed
//        // before it is iterated on
//        int count = 1;
//        // row should really be column, this will only ever be 0 (left) or 1 (right)
//        int row = 0;
//        // We start with the 0.___ samples that we earlier put in msampleFinder2
//        for (NSString *str in msampleFinder) {
//            dummyArray = [str componentsSeparatedByString:@"\""];        // We don't need the beginning of our array anymore because we already captured it, so we're going to throw it away
//            // Since the iPad is so much bigger, we're obviously going to put the switches in different positions, so right here
//            // before we do that we check to see if the device is an iPad or not
//            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                // Since the iPad is big enough to fit two columns, we are going to use two columns! To figure out when we need to start
//                // our new column we check to see if the number of rows in that column (c) exceeds half the number of switches in total.
//                if (c > [numberOfSwitchesNeeded floatValue]/2.0 - 0.5) {
//                    row = 1;
//                    c= 0;
//                }
//                // Making the label that goes next to the switch. The parameters are (xpos, ypos, width, height)
//                UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(54+50 +355*row, 635 +c*34, 280, 21)];
//                myLabel.text = dummyArray[0];
//                myLabel.font = [UIFont systemFontOfSize:22];
//                // Place the label in the view that is on top. Otherwise it will be invisible
//                [self.container addSubview:myLabel];
//                UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(50+355*row, 630 + c*34, 0, 0)];
//                [mySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
//                // give the switch a label corresponding to it's id
//                mySwitch.accessibilityLabel = [NSString stringWithFormat:@"%@", dummyArray[0]];
//                if ([str rangeOfString:@"checked"].location != NSNotFound) {
//                    [mySwitch setOn:YES];
//                }
//                [_orderBy addObject:dummyArray[0]];
//                [self.container addSubview:mySwitch];
//                [self.container addSubview:myLabel];
//                [_activeObjects addObject:mySwitch];
//                [_activeObjects addObject:myLabel];
//            } else {
//                // exact same thing, just different positioning to accomodate the iPhone's screen
//                UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(71, 422+c*34, 280, 21)];
//                myLabel.text = dummyArray[0];
//                myLabel.font = [UIFont systemFontOfSize:14];
//                [self.container addSubview:myLabel];
//                UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(17, 422 + c*34, 0, 0)];
//                [mySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
//                mySwitch.accessibilityLabel = [NSString stringWithFormat:@"%@", dummyArray[0]];
//                if ([str rangeOfString:@"checked"].location != NSNotFound) {
//                    [mySwitch setOn:YES];
//                }
//                [_orderBy addObject:dummyArray[0]];
//                [self.container addSubview:mySwitch];
//                [self.container addSubview:myLabel];
//                [_activeObjects addObject:mySwitch];
//                [_activeObjects addObject:myLabel];
//            }
//            c++;
//            count++;
//        }
//        heatmapValueSelect.text = _heatmapValues[0];
//        [_heatmapValuePicker reloadAllComponents];
//        orderBySelect.text = _orderBy[0];
//        [_orderByPicker reloadAllComponents];
//    }
//    else if (pickerView == self.valuePicker) {
//        [valueSelect setText:[self pickerView:_valuePicker titleForRow:[_valuePicker selectedRowInComponent:0] forComponent:0]];
//    }
//    else if (pickerView == self.chromPicker) {
//        [chromSelect setText:[self pickerView:_chromPicker titleForRow:[_chromPicker selectedRowInComponent:0] forComponent:0]];
//    }
//    else if (pickerView == self.limitPicker) {
//        [limitSelect setText:[self pickerView:_limitPicker titleForRow:[_limitPicker selectedRowInComponent:0] forComponent:0]];
//    }
//    else if (pickerView == self.heatmapValuePicker) {
//        [heatmapValueSelect setText:[self pickerView:_heatmapValuePicker titleForRow:[_heatmapValuePicker selectedRowInComponent:0] forComponent:0]];
//    }
//    else if (pickerView == self.orderByPicker) {
//        [orderBySelect setText:[self pickerView:_orderByPicker titleForRow:[_orderByPicker selectedRowInComponent:0] forComponent:0]];
//    }
    for (int x = 0; x < _listBoxes.count; x++) {
        if ([pickerView isEqual: _listPickers[x]]) {
            [_listBoxes[x] setText:[self pickerView:_listPickers[x] titleForRow:[_listPickers[x] selectedRowInComponent:0] forComponent:0]];
        }
    }
}
// If you wanted more than on column for the pickerview you would define that here
- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}
// This defines the number of selectable items in the pickerview. Right now
// it is set to however many items we have to choose from
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
//    if (pickerView == self.databasePicker) {
//        return [_databases count];
//    }
//    else if (pickerView == self.valuePicker) {
//        return [_values count];
//    }else if (pickerView == self.chromPicker) {
//        return [_chroms count];
//    }else if (pickerView == self.limitPicker) {
//        return [_limits count];
//    }else if (pickerView == self.heatmapValuePicker) {
//        return [_heatmapValues count];
//    }else if (pickerView == self.orderByPicker) {
//        return [_orderBy count];
//    }
    NSArray *pickerValues = _pickerViewValues[pickerView.accessibilityLabel];
    if (pickerValues != nil) {
        return [pickerValues count];
    } else {
        return 0;
    }
//    if ([pickerView.accessibilityLabel isEqual:@"Country"]) {
//        return [_countries count];
//    } else if ([pickerView.accessibilityLabel isEqual:@"State"]) {
//        return [_states count];
//    } else if ([pickerView.accessibilityLabel isEqual:@"Title"]) {
//        return [_titles count];
//    }
//    else{
//        return 0;
//    }
}

// This method defines the title of the row. In general, this is used very rarely.
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
//    if (pickerView == self.databasePicker) {
//        return _databases[row];
//    }
//    else if (pickerView == self.valuePicker) {
//        return _values[row];
//    }
//    else if (pickerView == self.chromPicker) {
//        return _chroms[row];
//    }
//    else if (pickerView == self.limitPicker) {
//        return _limits[row];
//    }
//    else if (pickerView == self.heatmapValuePicker) {
//        return _heatmapValues[row];
//    }
//    else if (pickerView == self.orderByPicker) {
//        return _orderBy[row];
    //    }
    NSArray *pickerValues = _pickerViewValues[pickerView.accessibilityLabel];
    if (pickerValues != nil) {
        return pickerValues[row];
    }
//    if ([pickerView.accessibilityLabel isEqual:@"Country"]) {
//        return _countries[row];
//    } else if ([pickerView.accessibilityLabel isEqual:@"State"]) {
//        return _states[row];
//    } else if ([pickerView.accessibilityLabel isEqual:@"Title"]) {
//        return _titles[row];
//    }
    else{
        return @"";
    }
}
// For a given row this defines what the row should display as text.
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    // using a UILabel allows us to set the size and font of what shows up in the picker wheel
    // The function expects a UIView in return, so really any subclass of UIView will work. It doesn't have to be UILabel.
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] init];
    }
//    if (pickerView == self.databasePicker) {
//        tView.text=_databases[row];
//        // these tend to be longer, so we need to make the font smaller to fit in the screen
//        tView.font = [UIFont systemFontOfSize:18];
//    }
//    else if (pickerView == self.valuePicker) {
//        tView.text=_values[row];
//    }
//    else if (pickerView == self.chromPicker) {
//        tView.text=_chroms[row];
//    } else if (pickerView == self.limitPicker) {
//        tView.text=_limits[row];
//    }
//    else if (pickerView == self.heatmapValuePicker) {
//        tView.text=_heatmapValues[row];
//        // these tend to be longer, so we need to make the font somaller to fit in the screen
//        tView.font = [UIFont systemFontOfSize:18];
//    }
//    else if (pickerView == self.orderByPicker) {
//        tView.text=_orderBy[row];
//    }
    NSArray *pickerValues = _pickerViewValues[pickerView.accessibilityLabel];
    if (pickerView != nil) {
        tView.text = pickerValues[row];
    }
//    if ([pickerView.accessibilityLabel isEqual:@"Country"]) {
//        tView.text = _countries[row];
//    } else if ([pickerView.accessibilityLabel isEqual:@"State"]) {
//        tView.text = _states[row];
//    } else if ([pickerView.accessibilityLabel isEqual:@"Title"]) {
//        tView.text = _titles[row];
//    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        tView.font = [UIFont systemFontOfSize:30];
    }
    return tView;
}

@end
