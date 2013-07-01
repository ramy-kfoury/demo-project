//
//  MainViewController.m
//  anchor
//
//  Created by Ramy Kfoury on 6/10/13.
//  Copyright (c) 2013 Ramy Kfoury. All rights reserved.
//

#import "MainViewController.h"
#import "ItemViewController.h"
#import "ListViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"

@interface MainViewController () <HeaderViewDelegate, NetworkingDelegate, RequestDataDelegate, LeftViewDelegate, MainViewDelegate, GridViewDelegate, RightViewDelegate, AnchorAlertDelegate, ListViewDelegate>
{
    AppDelegate *app;
    NSMutableArray *requests;
    MBProgressHUD *progressHUD;
    NSInteger selectedCategory;
    MainViewState currentState;
    NSMutableArray *playlistItems;
}
@property (nonatomic, strong) ItemViewController *itemVC;
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
    self.rightView = nil;
    self.listView = nil;
    self.centerView = nil;
    DLog(@"viewDidUnload");
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];

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
    self.leftView.delegate = self; self.leftView.hidden = YES;
    self.rightView.delegate = self; self.rightView.hidden = YES;
    self.mainView.delegate = self;
    self.listView.delegate = self;
    [self.headerView configureLeftButtonWithTitle:nil Image:@"menu-icon" BackgroundImage:nil];
    [self.headerView configureRightButtonWithTitle:nil Image:@"playlist" BackgroundImage:nil];
    currentState = MainViewDefaultState;
    requests = [[NSMutableArray alloc] initWithCapacity:0];
    playlistItems = [[NSMutableArray alloc] initWithCapacity:0];
    [self createProgressHUD];
    
    [self createLeftViewMenuItems];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeFirstResponderAudio) name:AUDIO_DID_START_PLAYING_NOTIFICATION object:nil];
}

- (void)createLeftViewMenuItems
{
    NSDictionary *settingsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"accountsettings", @"title", @"settings-icon", @"icon", MENU_SETTINGS, @"action", @"account_settings_back", @"background", nil];
    NSDictionary *homeDict = [NSDictionary dictionaryWithObjectsAndKeys:@"home", @"title", @"home_icon", @"icon", MENU_HOME, @"action", nil];
    NSDictionary *editDict = [NSDictionary dictionaryWithObjectsAndKeys:@"editcontent", @"title", MENU_EDIT_CONTENT, @"action", @"edit_content_back", @"background", nil];
    NSDictionary *addCategoryDict = [NSDictionary dictionaryWithObjectsAndKeys:@"addcategory", @"title", @"add-icon", @"icon", MENU_ADD_CATEGORY, @"action", @"edit_content_back", @"background", nil];
    NSArray *menuItems = [NSArray arrayWithObjects:settingsDict, homeDict, editDict, addCategoryDict, nil];
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
    User *defaultUser = [User defaultUser];
    [self.rightView configurePlaylists];
    if (defaultUser.userID.length > 0)
    {
        // User available
        if (defaultUser.categories.count > 0)
        {
            [self.leftView configureCategories];
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    DLog(@"disappear");
}


- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) becomeFirstResponderAudio
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated
{
    DLog(@"appear");
    [super viewDidAppear:animated];

    
    // Check if a user is available, else register new user
    User *defaultUser = [User defaultUser];
    if (defaultUser.userID.length > 0)
    {
        // User available
        if (defaultUser.categories.count == 0)
        {            
            [requests addObject:[[Networking sharedManager] sendGetCategoriesRequestWithDelegate:self]];
        }
        else
        {
            [self refreshMainViewForced:NO];
        }
    }
    else
    {
        [requests addObject:[[Networking sharedManager] sendRegisterUserRequestWithDelegate:self]];
    }
}

- (void) leftButtonClicked
{
    switch (currentState)
    {
        case MainViewSelectionState:
        {
            // Cancel button clicked            
            self.rightView.hidden = YES;
            self.leftView.hidden = YES;
            self.headerView.rightButton.enabled = YES;
            NSDictionary *categoryDict = [[User defaultUser].categories objectAtIndex:selectedCategory];
            NSString *name = [categoryDict valueForKey:@"name"];
            [self.headerView configureHeaderWithTitle:name];
            [self.headerView configureRightButtonWithTitle:nil Image:@"playlist" BackgroundImage:nil];
            [self.headerView configureLeftButtonWithTitle:nil Image:@"menu-icon" BackgroundImage:nil];
            [self.mainView configureTableForMode:MainViewDefaultState withState:NO];
            currentState = MainViewDefaultState;
                        
            break;
        }
        case MainViewEditingState:
        {            
            currentState = MainViewDefaultState;
            break;
        }
        case MainViewDefaultState:
        {
            self.headerView.rightButton.enabled = YES;
            {
                self.rightView.hidden = YES;
                self.leftView.hidden = NO;
                
                CGFloat mainX = self.centerView.frame.origin.x == 0.0 ? 264.0 : 0.0;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.centerView.frame = CGRectMake(mainX, self.centerView.frame.origin.y, 320.0, self.centerView.frame.size.height);
                self.headerView.frame = CGRectMake(mainX, self.headerView.frame.origin.y, 320.0, self.headerView.frame.size.height);
                [UIView commitAnimations];
            }
            break;
        }
        default:
            break;
    }
}

- (void) rightButtonClicked
{
    switch (currentState)
    {
        case MainViewSelectionState:
        {
            // Done button clicked // ask playlist name
            if (playlistItems.count > 0)
            {
                [app displayAlertView:nil WithTitle:NSLocalizedString(@"enterplaylist", nil) AndCancelTitle:NSLocalizedString(@"cancel", nil) OtherButtonTitle:NSLocalizedString(@"done", nil) Textfield:NSLocalizedString(@"playlistname", nil) fromDelegate:self];
            }
            break;
        }
        case MainViewEditingState:
        {
            [playlistItems removeAllObjects];
            currentState = MainViewDefaultState;
            break;
        }
        case MainViewDefaultState:
        {
            {                
                CGFloat mainX = self.centerView.frame.origin.x == 0.0 ? -264.0 : 0.0;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView setAnimationDelegate:self];
                self.centerView.frame = CGRectMake(mainX, self.centerView.frame.origin.y, 320.0, self.centerView.frame.size.height);
                self.headerView.frame = CGRectMake(mainX, self.headerView.frame.origin.y, 320.0, self.headerView.frame.size.height);
                self.rightView.hidden = NO;
                self.leftView.hidden = YES;
                [UIView commitAnimations];
            }
            break;
        }
        default:
            break;
    }
}

- (void) receivedResponseSuccess:(BOOL)success responseDict:(NSDictionary *)responseDict RequestType:(NetworkRequestType)type
{
    NSString *requestID = [responseDict valueForKey:@"requestid"];
    [requests removeObject:requestID];
    
    switch (type) {
        case RegisterUser:
        {            
            [requests addObject:[[Networking sharedManager] sendGetCategoriesRequestWithDelegate:self]];
            break;
        }
        case GetCategories:
        {
            [self.leftView configureCategories];
            break;
        }
        case GetCategoryFeeds:
        {
            [progressHUD hide:YES];
//            DLog(@"feeds: %@", [User defaultUser].categoryFeeds);
            [self.mainView configureFeedsForCategory:selectedCategory Reload:YES];
        }
        case Playlist:
        {
            [progressHUD hide:YES];
            
            NSDictionary *categoryDict = [[User defaultUser].categories objectAtIndex:selectedCategory];
            NSString *name = [categoryDict valueForKey:@"name"];
            [self.headerView configureHeaderWithTitle:name];
            [self.headerView configureRightButtonWithTitle:nil Image:@"playlist" BackgroundImage:nil];
            [self.headerView configureLeftButtonWithTitle:nil Image:@"menu-icon" BackgroundImage:nil];
            [self.mainView configureTableForMode:MainViewDefaultState withState:NO];
            
            currentState = MainViewDefaultState;
            [self.mainView configureTableForMode:currentState withState:NO];
            [self.rightView configurePlaylists];
            break;
        }
        default:
            break;
    }
}

- (void) handleError:(NSError *)error fromRequest:(RKRequestData *)request
{
    DLog(@"handleError");
    [requests removeObject:request.requestid];
    [progressHUD hide:YES];
    
    switch (request.type) {
        case GetCategoryFeeds:
            DLog(@"GetCategoryFeeds");
            [self.mainView configureFeedsForCategory:selectedCategory Reload:NO];
            break;
            
        default:
            break;
    }
}

- (void) leftViewDidSelectAction:(NSString *)action
{
    if ([action isEqualToString:MENU_SETTINGS])
    {
        // open Settings controller
        SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
        [self.navigationController pushViewController:settingsVC animated:YES];
        [settingsVC release];
    }
    else if ([action isEqualToString:MENU_HOME])
    {
        // open home
        currentState = MainViewDefaultState;  
        self.listView.hidden = YES;
        self.mainView.hidden = NO;
        [self.mainView configureTableForMode:MainViewDefaultState withState:NO];
    }
    else if ([action isEqualToString:MENU_ADD_CATEGORY])
    {
        // add category
    }
    else if ([action isEqualToString:MENU_EDIT_CONTENT])
    {
        // edit content
        [self.mainView configureTableForMode:MainViewEditingState withState:YES];
    }
    [self leftButtonClicked];
}

- (void) leftViewDidSelectItem:(NSInteger)index
{
    selectedCategory = index;
    [UIView animateWithDuration:0.3 animations:^{
        self.listView.hidden = YES;
    } completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.1 animations:^{
             self.mainView.hidden = NO;
         } completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3 animations:^{                  
                  [self refreshMainViewForced:NO];
              }completion:^(BOOL finished)
               {
                   [self leftButtonClicked];
               }];
          }];
     }];
}

- (void) refreshMainViewForced:(BOOL)forced
{
    if (!self.mainView.hidden)
    {
        
        User *user = [User defaultUser];
        DLog(@"refreshMainView");
        NSDictionary *categoryDict = [user.categories objectAtIndex:selectedCategory];
        NSString *name = [categoryDict valueForKey:@"name"];
        [self.headerView configureHeaderWithTitle:name];
        
        NSString *categoryid = [categoryDict valueForKey:@"id"];
        BOOL refresh = YES;
        DLog(@"categoryID: %@", categoryid);
        if (categoryid.length > 0)
        {
            NSArray *feedsArray = [user.categoryFeeds objectForKey:categoryid];
            DLog(@"feedsArray count: %i", feedsArray.count);
            if (feedsArray.count > 0)
            {
                for (NSDictionary *feedDict in feedsArray)
                {
                    NSString *rssID = [feedDict valueForKey:@"rssID"];
                    if (rssID.length > 0)
                    {
                        if ([user.rssFeeds.allKeys containsObject:rssID])
                        {
                            refresh = NO;
                            break;
                        }
                    }
                }
            }
            else
            {
                refresh = YES;
            }
        }
        if (refresh || forced)
        {
            DLog(@"refresh");
            // empty rss feeds downloaded
            [self.mainView clearRssFeedsForCategory:selectedCategory];
            
            [progressHUD show:YES];
            [requests addObject:[[Networking sharedManager] sendGetFeedsRequestWithDelegate:self forCategory:categoryid]];
        }
        else
        {
            DLog(@"dont refresh");
            [self.mainView configureFeedsForCategory:selectedCategory Reload:NO];
        }
    }
}

- (void) mainDidTriggerRefresh
{
    [self.mainView clearRssFeedsForCategory:selectedCategory];
    [self refreshMainViewForced:YES];
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

- (void) gridViewDidOpenItem:(NSDictionary *)itemDict atIndex:(NSInteger)index withFeeds:(NSArray *)itemsArray
{
    switch (currentState)
    {
        case MainViewDefaultState:            
        {
            if (itemDict == nil)
            {
                NSDictionary *playlistDict = [[NSDictionary alloc] initWithObjectsAndKeys:itemsArray, @"items", nil];
                [self configureListViewWithSource:playlistDict];
            }
            else
            {
                if (!self.itemVC)
                {
                    self.itemVC = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
                }
                self.itemVC.items = itemsArray;
                self.itemVC.currentItemIndex = index;
                //            NSLog(@"itemsArray: %i", itemsArray.count);
                [self.navigationController pushViewController:self.itemVC animated:YES];
                if (![progressHUD isHidden]) {
                    [progressHUD hide:YES];
                }
            }
            break;
        }
        case MainViewSelectionState:
        {
            if ([playlistItems containsObject:itemDict])
            {
                [playlistItems removeObject:itemDict];
            }
            else
            {
                [playlistItems addObject:itemDict];                
            }
//            DLog(@"playlistItems: %i", playlistItems.count);
            self.headerView.rightButton.enabled = (playlistItems.count > 0);
            break;
        }
        default:
            break;
    }
}

- (void) rightViewDidAddNewPlaylist
{
    DLog(@"rightViewDidAddNewPlaylist");
    
    [playlistItems removeAllObjects];
    [UIView animateWithDuration:0.3 animations:^{
        self.listView.hidden = YES;
    } completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.1 animations:^{
             self.mainView.hidden = NO;
         } completion:^(BOOL finished)
          {
              [self rightButtonClicked];
              [UIView animateWithDuration:0.3 animations:^{
              }completion:^(BOOL finished)
               {
                   currentState = MainViewSelectionState;
                   [self.mainView configureTableForMode:currentState withState:YES];
                   [self.headerView configureHeaderForMode:currentState];
                   self.headerView.rightButton.enabled = NO;
               }];
          }];
     }];
    
}

- (void) anchorAlert:(AnchorAlert*)alert didDismissWithButtonIndex:(NSInteger)index
{
//    DLog(@"alert :%@ dismissIndex: %i", alert ? @"not nil": @"nil", index);
    switch (index) {
        case 1:
        {
            // check  if number of selected items > 0
            
            NSString *playlistTitle = alert.textField.text;
            DLog(@"Create playlist: %@", playlistTitle);
            
            if (playlistItems.count > 0 && playlistTitle.length > 0)
            {
                // add playlist to user playlists
                NSMutableDictionary *playlistDict = [[NSMutableDictionary alloc] initWithCapacity:2];
                [playlistDict setValue:@"-1" forKey:@"id"];
                if (playlistItems) {
                    [playlistDict setObject:playlistItems forKey:@"items"];
                }
                if (playlistTitle) {
                    [playlistDict setObject:playlistTitle forKey:@"title"];
                }
                
                if ([[User defaultUser] addToPlaylistDictionary:playlistDict])
                {
                    [playlistDict release];
                    [progressHUD show:YES];
                    [[Networking sharedManager] sendUpdatePlaylistRequestWithDelegate:self forPlaylist:[[User defaultUser].playlists lastObject] Delete:NO];
                }
            }
            
            break;
        }
            
        default:
            break;
    }
    [alert dismissAnimated:YES];
}

- (void) rightViewDidSelectPlaylist:(NSInteger)index
{
    NSDictionary *playlistDict = [[User defaultUser].playlists objectAtIndex:index];
    
    [self configureListViewWithSource:playlistDict];
    [self rightButtonClicked];
}

- (void) configureListViewWithSource:(NSDictionary *)source
{    
    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.hidden = YES;
    } completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.3 animations:^{
             self.listView.hidden = NO;
         } completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.3 animations:^{
                  NSString *playlistID = [source valueForKey:@"id"];
                  NSString *playlistName = [source valueForKey:@"title"];
                  NSArray *playlistArray = [source objectForKey:@"items"];
                  DLog(@"%@ %@ %i", playlistID, playlistName, playlistArray.count);
                  
                  [self.listView configureWithSource:source];
                  [self.headerView configureHeaderWithTitle:playlistName];
              }completion:^(BOOL finished)
               {                
               }];
          }];
     }];       
}



- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent
{
    DLog(@"remoteControlReceivedWithEvent");
    //if it is a remote control event handle it correctly
    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        if (receivedEvent.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            DLog(@"toggle");
            [self.itemVC.itemView speech];
        }
        else if (receivedEvent.subtype == UIEventSubtypeRemoteControlNextTrack)
        {
            DLog(@"next track");
            [self.itemVC skipToNextItem];
        }
        else if (receivedEvent.subtype == UIEventSubtypeRemoteControlPreviousTrack)
        {
            DLog(@"previous track");
            [self.itemVC skipToPreviousItem];
        }
    }
}

@end
