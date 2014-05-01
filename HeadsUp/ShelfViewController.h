//
//  ShelfViewController.h
//  HeadsUp
//
//  Created by Zeeshan Ahmed on 2/4/14.
//  Copyright (c) 2014 RobinGronvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UICollectionView+Draggable.h"
#import "Cell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "CustomNavViewController.h"
#import "PlayViewController.h"
#import "ButtonsHeader.h"
#import "AboutViewController.h"
#import "moreViewController.h"

@interface ShelfViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource_Draggable, UICollectionViewDelegate,UIActionSheetDelegate>
{
    __weak IBOutlet UICollectionView *gridCards;
    NSMutableArray *arrayItemsList;
    __weak IBOutlet UITableView *tblVwDetail;
    IBOutlet UIView *viewResult;
    
    int currentCardDeckIndex;
    
    NSArray *arrAnswersData;
    NSArray *arrAnswersAction;
    NSMutableArray *purchasedItemIDs;
    
    __weak IBOutlet UIView *viewVideo;
    __weak IBOutlet UIButton *btnShareSave;
    
    Cell *currentCellInZoom;
    CGRect cellFrameOriginal;
    CGRect cellBtnPlayFrame;
    CGRect cellBtnBackFrame;
    
    BOOL isZoomIn;
    BOOL isAnimating;
    
    UIImage *imgDisplayCurrent;
    UIImage *imgDetailCurrent;
    
    BOOL isPlayClick;
    int indexOfDeckInZoom;
    
    AppDelegate *delegate;
    __weak IBOutlet UIScrollView *scrllVwResult;
    
    NSDictionary *dictProductsIDs;
    
    BOOL isProductsFetched;
    IBOutlet UIActivityIndicatorView *spinner;
    
    BOOL isProductsReturnNull;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic)CustomNavViewController* navController;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) NSString *slService;
@property (nonatomic,retain)NSData *dataRenderVideo;
@property(nonatomic,retain)MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic) NSArray *arrayProducts;
@property (strong, nonatomic) NSArray *arrayFetched;


- (IBAction)watchVideo:(id)sender;
- (IBAction)pickAnotherDeck:(id)sender;
- (IBAction)playThisDeckAgain:(id)sender;
- (IBAction)shareOrSaveVideo:(id)sender;
- (IBAction)openAboutScreen:(id)sender;
- (IBAction)openMoreScreen:(id)sender;


@end
