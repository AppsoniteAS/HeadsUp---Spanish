//
//  SimpleTableCell.h
//
//
//  Created by Robin Grønvold on 3/28/13.
//  Copyright (c) 2013 appsonite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface moreTableCell : UITableViewCell{
    // BOOL *checkboxSelected;
    IBOutlet UIView *view1;
    
}
@property (strong, nonatomic) IBOutlet UILabel *appName;

@property (strong, nonatomic) IBOutlet UILabel *appDescription;

@property (strong, nonatomic) IBOutlet UIImageView *appImage;


@end
