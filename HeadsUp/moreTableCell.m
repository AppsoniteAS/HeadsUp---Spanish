//
//  SimpleTableCell.m
//  jobbintervju
//
//  Created by Robin Grønvold on 3/28/13.
//  Copyright (c) 2013 appsonite. All rights reserved.
//

#import "moreTableCell.h"

@implementation moreTableCell
@synthesize appName;
@synthesize appDescription, appImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end