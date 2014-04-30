//
//  ShelfCell.h
//  HeadsUp
//
//  Created by Zeeshan Ahmed on 2/4/14.
//  Copyright (c) 2014 RobinGronvold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UICollectionViewCell
{
    IBOutlet UIImageView *imgVwShelf;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnPlay;
}

@property(nonatomic,retain)UIImageView *imgVwShelf;
@property(nonatomic,retain)UIButton *btnBack;
@property(nonatomic,retain)UIButton *btnPlay;

@end
