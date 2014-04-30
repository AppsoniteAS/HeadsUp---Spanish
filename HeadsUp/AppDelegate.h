//
//  AppDelegate.h
//  HeadsUp
//
//  Created by Zeeshan Ahmed on 2/4/14.
//  Copyright (c) 2014 RobinGronvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKStoreManager.h"

enum ResultType
{
    typePass = 0,
    typeAnswer,
    typeTimeUp
};

@class ShelfViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}

@property (nonatomic , retain)NSMutableArray *arryAnswers;
@property (nonatomic , retain)NSMutableArray *arryCardsAnswered;
@property (nonatomic , retain)NSURL *videoUrl;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) ShelfViewController *shlfVw;

@end
