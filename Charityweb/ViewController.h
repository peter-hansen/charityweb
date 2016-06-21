//
//  ViewController.h
//  Charityweb
//
//  Created by Peter Hansen on 12/22/14.
//  Copyright (c) 2014 Peter Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    NSMutableData *_responseData;
}
@property (strong, nonatomic) NSDictionary *json;
@property (strong, nonatomic) NSString *cwsid;
@end

