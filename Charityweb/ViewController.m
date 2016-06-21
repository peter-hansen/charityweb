//
//  ViewController.m
//  Charityweb
//
//  Created by Peter Hansen on 12/22/14.
//  Copyright (c) 2014 Peter Hansen. All rights reserved.
//

#import "ViewController.h"
#import "paymentController.h"
@interface ViewController ()
@end


@implementation ViewController
NSArray *trustedHosts;
- (BOOL)shouldAutorotate
{
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    trustedHosts = [[NSArray alloc] initWithObjects:@"172.16.12.161", nil];
    _cwsid = @"9f40654fc065ceaf9726e6126b047d0d";
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://172.16.12.161/happytrails/csongetapay"]];

    // Specify that it will be a POST request
    request.HTTPMethod = @"POST";
    
    // This is how we set header fields
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    // Convert your data and set your request's HTTPBody property
    NSString *stringData = [NSString stringWithFormat:@"CWSID=%@" , _cwsid];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    // Create url connection and fire request
    // Here we cast it as void because we don't need to do anything
    // with the return value
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)generateClients:(NSDictionary *)clients {
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    UIImageView *charityWebLogo = [[UIImageView alloc] initWithImage:([UIImage imageNamed:@"main-logo.png"])];
//    [scrollView addSubview: charityWebLogo];
//    if (self.view.frame.size.width > 500) {
//        charityWebLogo.frame = CGRectMake(0, 0, 500, 121.7105);
//    } else {
//        charityWebLogo.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 74 / 304);
//    }
//    CGFloat logoHeight = charityWebLogo.frame.size.height;
//    NSInteger numOfClients = 0;
//    for (NSString *key in clients) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        button.frame = CGRectMake(20, logoHeight + numOfClients*55, 200, 50);
//        [button setClipsToBounds:false];
////        [button setBackgroundImage:[UIImage imageWithData:clients[key][@"logo"]] forState:UIControlStateNormal];
//        [button setTitle:key forState:UIControlStateNormal];
//        [button.titleLabel setFont:[UIFont systemFontOfSize:24.f]];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
//        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 0.f, -50.f, 0.f)];
//        [button addTarget:self action:@selector(selectedClient:) forControlEvents:UIControlEventTouchUpInside];
//        [button setAccessibilityLabel:clients[key][@"merchantID"]];
//        [scrollView addSubview:button];
//        numOfClients++;
//    }
//    int extraSpace = logoHeight + 55*numOfClients - self.view.frame.size.height;
//    if (extraSpace < 0) {
//        extraSpace = 0;
//    } else {
//        extraSpace += 10;
//    }
//    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + extraSpace);
//    [[self view] addSubview:scrollView];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIImageView *charityWebLogo = [[UIImageView alloc] initWithImage:([UIImage imageNamed:@"main-logo.png"])];
    [scrollView addSubview: charityWebLogo];
    if (self.view.frame.size.width > 500) {
        charityWebLogo.frame = CGRectMake(0, 0, 500, 121.7105);
    } else {
        charityWebLogo.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * 74 / 304);
    }
    CGFloat logoHeight = charityWebLogo.frame.size.height;
    NSInteger numOfClients = 0;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20, logoHeight, 200, 50);
    [button setClipsToBounds:false];
    //        [button setBackgroundImage:[UIImage imageWithData:clients[key][@"logo"]] forState:UIControlStateNormal];
    [button setTitle:clients[@"ClientName"] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:24.f]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 0.f, -50.f, 0.f)];
    [button addTarget:self action:@selector(selectedClient:) forControlEvents:UIControlEventTouchUpInside];
    [button setAccessibilityLabel:clients[@"merchantID"]];
    [scrollView addSubview:button];
    numOfClients++;
    int extraSpace = logoHeight + 55*numOfClients - self.view.frame.size.height;
    if (extraSpace < 0) {
        extraSpace = 0;
    } else {
        extraSpace += 10;
    }
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + extraSpace);
    [[self view] addSubview:scrollView];

}
- (IBAction)selectedClient:(UIButton*)sender {
    UIStoryboard *storyboard = [[UIStoryboard alloc]init];
    paymentController *viewController = [[paymentController alloc]init];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    viewController = (paymentController *)[storyboard instantiateViewControllerWithIdentifier:@"payment"];
    viewController.json = _json;
    viewController.merchantID = sender.accessibilityLabel;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _json = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:nil];
    NSDictionary *clients = _json;
    [self generateClients:clients];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    NSString *message = @"There was an error connecting to the server.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        if ([trustedHosts containsObject:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
@end
