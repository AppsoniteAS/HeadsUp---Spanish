//
//  moreViewController.h
//  Valutakalkulator
//
//  Created by Robin Grønvold on 7/24/13.
//  Copyright (c) 2013 Appsonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface moreViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate>
{
    
}

@property (strong, nonatomic) NSArray *appList;
@property (strong, nonatomic) NSArray *descriptionList;
@property (strong, nonatomic) NSArray *imageList;
@property (strong, nonatomic) NSArray *urlList;
@property (strong, nonatomic) IBOutlet UITableView *moreTableView;

- (IBAction)goBack:(id)sender;
- (IBAction)openFeedback:(id)sender;

@end
