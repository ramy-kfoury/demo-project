//
//  MainViewController.m
//  anchor
//
//  Created by Ramy Kfoury on 6/10/13.
//  Copyright (c) 2013 Ramy Kfoury. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"

@interface MainViewController () <NetworkingDelegate, RequestDataDelegate, HeaderViewDelegate, LeftViewDelegate, MainViewDelegate>
{
    AppDelegate *app;
    NSMutableArray *requests;
    MBProgressHUD *progressHUD;
    BOOL closeMenu;
}
@end

@implementation MainViewController

- (void) dealloc
{
    [requests release];
    [progressHUD release];
    [super dealloc];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    self.mainView = nil;
    self.leftView = nil;
    self.headerView = nil;
    self.centerView = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.headerView.delegate = self;
    self.leftView.delegate = self;
    self.mainView.delegate = self;
    [self.headerView configureHeaderWithTitle:NSLocalizedString(@"main", nil)];
    [self.headerView configureLeftButtonWithTitle:NSLocalizedString(@"menu", nil) Image:@"menu-icon" BackgroundImage:nil];
    [self.headerView configureRightButtonWithTitle:nil Image:@"playlist" BackgroundImage:nil];
    requests = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self createProgressHUD];    
    [self createLeftViewMenuItems];
    
    closeMenu = YES;
}

- (void)createLeftViewMenuItems
{
    NSDictionary *option1Dict = [NSDictionary dictionaryWithObjectsAndKeys:@"option1-title", @"title", @"option1-icon", @"icon", MENU_OPTION1, @"action", @"option1-bg", @"background", nil];
    NSDictionary *option2Dict = [NSDictionary dictionaryWithObjectsAndKeys:@"option2-title", @"title", @"option2-icon", @"icon", MENU_OPTION2, @"action", @"option2-bg", @"background", nil];
    NSArray *menuItems = [NSArray arrayWithObjects:option1Dict, option2Dict, nil];
    [self.leftView configureWithItems:menuItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check if a user is available, else register new user
    [progressHUD show:YES];
    [requests addObject:[[Networking sharedManager] sendNetworkRequestWithDelegate:self]];
}

- (void) leftButtonClicked
{    
    CGFloat mainX = self.centerView.frame.origin.x == 0.0 ? 264.0 : 0.0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    self.centerView.frame = CGRectMake(mainX, self.centerView.frame.origin.y, 320.0, self.centerView.frame.size.height);
    self.headerView.frame = CGRectMake(mainX, self.headerView.frame.origin.y, 320.0, self.headerView.frame.size.height);
    [UIView commitAnimations];
}
- (void) receivedResponseSuccess:(BOOL)success responseDict:(NSDictionary *)responseDict RequestType:(NetworkRequestType)type
{
    NSString *requestID = [responseDict valueForKey:@"requestid"];
    [requests removeObject:requestID];
    
    switch (type) {
        case NetworkSampleRequest:
        {
            // Request was successful, do something next
            [progressHUD hide:YES];
            break;
        }        
        default:
            [progressHUD hide:YES];
            break;
    }
}

- (void) handleError:(NSError *)error fromRequest:(RKRequestData *)request
{
    [requests removeObject:request.requestid];
    
    switch (request.type)
    {
        case NetworkSampleRequest:
            // Request failed, do something
            [progressHUD hide:YES];
            break;
            
        default:
            [progressHUD hide:YES];
            break;
    }
}

- (void) leftViewDidSelectAction:(NSString *)action
{
    if ([action isEqualToString:MENU_OPTION1])
    {
        // open option 1
        DLog(@"open option 1");
    }
    else if ([action isEqualToString:MENU_OPTION2])
    {
        // open option 2
        DLog(@"open option 2");
    }
    // close menu
    if (closeMenu)
    {
        [self leftButtonClicked];
    }
}

- (void) createProgressHUD
{
    if  (!progressHUD)
    {
        progressHUD = [[MBProgressHUD alloc] initWithView:self.centerView];
        [self.centerView addSubview:progressHUD];
        [progressHUD setMode:(MBProgressHUDMode)MBProgressHUDAnimationFade];
        progressHUD.labelText = NSLocalizedString(@"pleasewait", nil);
        [progressHUD sizeToFit];
    }
}

@end
