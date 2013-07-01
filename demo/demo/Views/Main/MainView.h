//
//  MainView.h
//  anchor
//
//  Created by Ramy Kfoury on 6/10/13.
//  Copyright (c) 2013 Ramy Kfoury. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _MainViewState
{
    MainViewEditingState,
    MainViewDefaultState
} MainViewState;

@protocol MainViewDelegate <NSObject>
@optional
- (void) mainDidSelectItem;
- (void) mainDidTriggerRefresh;
@end

@interface MainView : UIView

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id delegate;

- (void) configureTableForMode:(MainViewState)state withState:(BOOL)stateBoolean;
@end
