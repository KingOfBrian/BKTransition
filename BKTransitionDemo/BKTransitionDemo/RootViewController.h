//
//  RootViewController.h
//  BKTransitionDemo
//
//  Created by Brian King on 4/14/11.
//  Copyright 2011 King Software Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKViewController.h"
#import "CartoonViewController.h"

@interface RootViewController : BKViewController {
    NSUInteger _selectedRow;
    UIImageView *_transtitioningImage;
    IBOutlet CartoonViewController *_cartoonController;
}

@property (nonatomic, readonly) UITableView *tableView;
@end
