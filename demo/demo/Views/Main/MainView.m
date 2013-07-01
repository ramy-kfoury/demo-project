//
//  MainView.m
//  anchor
//
//  Created by Ramy Kfoury on 6/10/13.
//  Copyright (c) 2013 Ramy Kfoury. All rights reserved.
//

#import "MainView.h"
#import "Constants.h"

@interface MainView() 
{
    ODRefreshControl *refreshControl;
    BOOL editingMode;
}
@end

@implementation MainView

- (void) dealloc
{
    [refreshControl release];
    self.view = nil; [_view release];
    self.tableView = nil; [_tableView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self configure];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];    
    [self configure];
}

- (void) configure
{    
    [[NSBundle mainBundle] loadNibNamed:@"MainView" owner:self options:nil];
    [self addSubview:self.view];
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    refreshControl.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TextCellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:FONT_NAME_REGULAR size:14.0];
    }
    
    NSString *cellText = NSLocalizedString(@"variabletext", nil);
    
    UIFont *cellFont = cell.textLabel.font;
    CGSize constraintSize = CGSizeMake(self.tableView.frame.size.width, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    labelSize.height  += 16.0;
    CGRect frame = cell.textLabel.frame;
    frame.size = labelSize;
    cell.textLabel.frame = frame;
    cell.textLabel.text = cellText;
    
    return  cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *cellText = NSLocalizedString(@"variabletext", nil);
    
    UIFont *cellFont = [UIFont fontWithName:FONT_NAME_REGULAR size:15.0];
    CGSize constraintSize = CGSizeMake(270.0, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    labelSize.height += 16.0;
    if (labelSize.height < 44.0) {
        labelSize.height = 44.0;
    }
    return labelSize.height;
}

#pragma mark - TableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    DLog(@"feeds: %i", feeds.count);
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(mainDidSelectItem)])
    {
        [_delegate mainDidSelectItem];
    }
}

- (void) refresh
{    
    if (_delegate && [_delegate respondsToSelector:@selector(mainDidTriggerRefresh)])
    {
        [_delegate mainDidTriggerRefresh];
    }
    
    // for testing only
    [refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.0];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingMode)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do something with the deleted row
}

- (void) configureTableForMode:(MainViewState)state withState:(BOOL)stateBoolean
{
    switch (state) {
        case MainViewEditingState:
        {
            editingMode = stateBoolean;
            [self.tableView setEditing:editingMode animated: YES];
            break;
        }
        case MainViewDefaultState:
        {
            editingMode = NO;
            [self.tableView setEditing:NO];
            [self.tableView reloadData];
        }
        default:
            break;
    }
}

@end
