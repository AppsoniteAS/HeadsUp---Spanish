//
//  ShelfViewController.m
//  HeadsUp
//
//  Created by Zeeshan Ahmed on 2/4/14.
//  Copyright (c) 2014 RobinGronvold. All rights reserved.
//

#import "ShelfViewController.h"
#import "KxMenu.h"
#import "MKStoreManager.h"

@interface ShelfViewController ()

@end

@implementation ShelfViewController
@synthesize videoPlayer;
@synthesize facebookAccount;
@synthesize accountStore;
@synthesize slService;
@synthesize dataRenderVideo;
@synthesize navController;
@synthesize arrayProducts;
@synthesize arrayFetched;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (IBAction)restorePurchase:(id)sender {
    [self checkPurchasedItems];
}

- (void) checkPurchasedItems
{
    NSLog(@"CheckingPurchasedItems");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}// Call This Function

//Then this delegate Function Will be fired
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    purchasedItemIDs = [[NSMutableArray alloc] init];
    
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    arrayProducts =  [[NSArray alloc] initWithArray:[[self storeKitItems] objectForKey:@"Non-Consumables"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inAppProductsFetched:)
                                                 name:kProductFetchedNotification object:nil];
    
    NSString *filePathProducts = [[NSBundle mainBundle] pathForResource:@"PruchaseProductMapping" ofType:@"plist"];
    dictProductsIDs = [[NSDictionary alloc] initWithContentsOfFile:filePathProducts];
    
    delegate = [UIApplication sharedApplication].delegate;
    
    self.navController =[[CustomNavViewController alloc] init];

    
    [scrllVwResult setContentSize:CGSizeMake(320, viewResult.frame.size.height)];
    
    self.accountStore = [[ACAccountStore alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:)
                                                 name:@"ProduceResult" object:nil];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"MainDecks" ofType:@"plist"];
    arrayItemsList = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    
    UINib *cellNib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [gridCards registerNib:cellNib forCellWithReuseIdentifier:@"Cell"];
    
    [gridCards registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewCell"];
}

-(NSDictionary*)storeKitItems
{
    return [NSDictionary dictionaryWithContentsOfFile:
            [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
             @"MKStoreKitConfigs.plist"]];
}

-(void)notificationReceived:(NSNotification *)notify
{
    
//	CATransition *animation = [CATransition animation];
//	[animation setDuration:0.50];
//	[animation setType:kCATransitionPush];
//	[animation setSubtype:kCATransitionFromTop];
//	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//	[[self.view layer] addAnimation:animation forKey:@"SlideView"];
    
    [self performSelectorOnMainThread:@selector(afterFinish) withObject:nil waitUntilDone:NO];
}

-(void)inAppProductsFetched:(NSNotification *)notification
{
    NSLog(@"Fetched ");
    isProductsFetched = YES;
    self.arrayFetched = [[NSArray alloc] initWithArray:[notification object]];
    
    if (isZoomIn)
    {
        NSIndexPath *indexOfCurrentCell = [gridCards indexPathForCell:currentCellInZoom];
        [self setPriceForPurchases:currentCellInZoom _indexRow:indexOfCurrentCell.row];
        
        [spinner stopAnimating];
        [spinner removeFromSuperview];
    }
}

-(SKProduct *)getProductInfo:(NSString *)productId
{
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"productIdentifier == %@", productId];
    NSArray *filtered  = [self.arrayFetched filteredArrayUsingPredicate:predicate];
    SKProduct *product = [filtered objectAtIndex:0];
    
    return product;
}

- (NSString *)priceAsString:(NSLocale *)priceLocale _price:(NSDecimalNumber *)price
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:priceLocale];
    
    NSString *str = [formatter stringFromNumber:price];
    
    return str;
}

-(void)afterFinish
{
    [scrllVwResult setHidden:NO];
    self.dataRenderVideo = [NSData dataWithContentsOfURL:delegate.videoUrl];
    [self initializeVideoSetting:delegate.videoUrl];
    
    arrAnswersData = [[NSMutableArray alloc] initWithArray:delegate.arryCardsAnswered];
    arrAnswersAction = [[NSMutableArray alloc] initWithArray:delegate.arryAnswers];
    
    tblVwDetail.backgroundColor = [UIColor clearColor];
    [tblVwDetail reloadData];
}

-(void)initializeVideoSetting:(NSURL *)urlVideo
{
    self.videoPlayer =[[MPMoviePlayerController alloc] initWithContentURL:urlVideo];
    [self.videoPlayer.view setFrame:CGRectMake(0,0,viewVideo.frame.size.width,viewVideo.frame.size.height)];
    [self.videoPlayer prepareToPlay];
    self.videoPlayer.movieSourceType = MPMovieSourceTypeFile;
    self.videoPlayer.scalingMode = MPMovieScalingModeAspectFill;
    self.videoPlayer.controlStyle = MPMovieControlStyleNone;
 
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.videoPlayer setShouldAutoplay:NO]; // And other options you can look through the documentation.
    [viewVideo addSubview:self.videoPlayer.view];
}

//- (void)playbackFinished:(NSNotification*)notification
//{
//    NSNumber* reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
//    switch ([reason intValue])
//    {
//        case MPMovieFinishReasonPlaybackEnded:
//        {
//            NSLog(@"playbackFinished. Reason: Playback Ended");
//            [self.videoPlayer play];
//            break;
//        }
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        ButtonsHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewCell" forIndexPath:indexPath];
        [headerView addSubview:self.viewHeader];
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        return nil;
    }
    
    return reusableview;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
     return arrayItemsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    Cell *cell = (Cell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (cell==nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"Cell" owner:self options:nil] objectAtIndex:0];
    }
    cell.btnPlay.tag = indexPath.row;
    
    [cell.btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnPlay addTarget:self action:@selector(playGame:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *data = [arrayItemsList objectAtIndex:indexPath.row];
    NSString *fileName = [data objectForKey:@"fileName"];
    NSDictionary *dictProduct = [dictProductsIDs objectForKey:fileName];
    NSString *productId = [dictProduct objectForKey:@"id"];
    
    if (![MKStoreManager isFeaturePurchased:productId] && dictProduct != nil && [arrayProducts containsObject:productId])
    {
        [cell.btnPlay setBackgroundImage:[UIImage imageNamed:@"play-price.png"] forState:UIControlStateNormal];
    }
    else{
        [cell.btnPlay setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    
    NSString *imgName = nil;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        imgName = @"displayImage_iPhone";
    }
    else
    {
        imgName = @"displayImage_iPad";
    }
    
    [cell.imgVwShelf setImage:[UIImage imageNamed:[data objectForKey:imgName]]];
    
    return cell;
}

-(void)goBack:(UIButton *)sender
{
    [self ZoomOutAnimation];
}

-(void)playGame:(UIButton *)sender
{
    indexOfDeckInZoom = (int)sender.tag;
    
    NSDictionary *data = [arrayItemsList objectAtIndex:indexOfDeckInZoom];
    NSString *fileName = [data objectForKey:@"fileName"];
    NSDictionary *dictProduct = [dictProductsIDs objectForKey:fileName];
    NSString *productID = [dictProduct objectForKey:@"id"];
    
    if (![spinner isAnimating])
    {
        if(![MKStoreManager isFeaturePurchased:productID] && dictProduct != nil)
        {
            [[MKStoreManager sharedManager] buyFeature:[dictProduct objectForKey:@"id"]
                                            onComplete:^(NSString* purchasedFeature,
                                                         NSData* purchasedReceipt,
                                                         NSArray* availableDownloads)
             {
                 [currentCellInZoom.btnPlay setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
                 [currentCellInZoom.btnPlay setTitle:@"" forState:UIControlStateNormal];
                 
                 [self successSharing:@""];
             }
                                           onCancelled:^
             {
                 [self errorPurchasing:@"User Cancelled Transaction"];
             }];
        }
        else
        {
            isPlayClick = YES;
            [self ZoomOutAnimation];
        }
    }
}

-(void)successSharing:(NSString *)successMessage
{
    NSString *strMessage = [NSString stringWithFormat:@"Se han añadido cartas nuevas %@",successMessage];
    
    UIAlertView *alertError =[[UIAlertView alloc] initWithTitle:@"¡Éxito!" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertError show];
}

-(void)errorPurchasing:(NSString *)errorMessage
{
    NSString *strMessage = [NSString stringWithFormat:@"%@",errorMessage];
    
    UIAlertView *alertError =[[UIAlertView alloc] initWithTitle:@"Error" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertError show];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isAnimating)
        return;
    
    if (!isZoomIn)
    {
        NSDictionary *data = [arrayItemsList objectAtIndex:indexPath.row];
        
        NSString *imgName = nil;
        NSString *imgNameBack = nil;
        
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            imgName = @"displayImage_iPhone";
            imgNameBack = @"detailImage_iPhone";
        }
        else
        {
            imgName = @"displayImage_iPad";
            imgNameBack = @"detailImage_iPad";
        }
        
        imgDisplayCurrent = [UIImage imageNamed:[data objectForKey:imgName]];
        imgDetailCurrent = [UIImage imageNamed:[data objectForKey:imgNameBack]];
        
        isAnimating = YES;
        Cell *cell = (Cell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell.superview bringSubviewToFront:cell];
        currentCellInZoom = cell;
        
        [self setPriceForPurchases:cell _indexRow:indexPath.row];
        
        [self applyZoomInAnimation:cell];
    }
    else
    {
        [self ZoomOutAnimation];
    }
}


-(void)setPriceForPurchases:(Cell *)cell _indexRow:(NSInteger)index
{
    NSDictionary *data = [arrayItemsList objectAtIndex:index];
    NSString *fileName = [data objectForKey:@"fileName"];
    NSDictionary *dictProduct = [dictProductsIDs objectForKey:fileName];
    NSString *productID = [dictProduct objectForKey:@"id"];
    
    if(![MKStoreManager isFeaturePurchased:productID] && dictProduct != nil)
    {
        if (isProductsFetched)
        {
            SKProduct *currenProduct = [self getProductInfo:productID];
            NSString *price = [self priceAsString:currenProduct.priceLocale _price:currenProduct.price];
            if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
                cell.btnPlay.titleLabel.font = [UIFont systemFontOfSize:14];
            }
            else{
                    cell.btnPlay.titleLabel.font = [UIFont systemFontOfSize:24];
            }
            [cell.btnPlay setTitle:price forState:UIControlStateNormal];
        }
        else
        {
            //[cell.btnPlay setTitle:@"load..." forState:UIControlStateNormal];
            spinner.frame = CGRectMake(30, 5, 20, 20);
            [cell.btnPlay addSubview:spinner];
            [spinner startAnimating];
        }
    }
}

#pragma mark - ZoomIn
-(void)applyZoomInAnimation:(Cell *)cell
{
    gridCards.scrollEnabled = NO;
    cellFrameOriginal = cell.frame;
    cellBtnBackFrame = cell.btnBack.frame;
    cellBtnPlayFrame = cell.btnPlay.frame;
    
    [UIView transitionWithView:cell
                      duration:0.75
                       options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                    animations:^{
                        
//                        cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.5, 2.5);
//                        cell.center = CGPointMake(gridCards.center.x + gridCards.contentOffset.x,
//                                                  gridCards.center.y + gridCards.contentOffset.y);
                        
                        //NSLog(@"Before Frame : %@",NSStringFromCGPoint(cell.frame.origin));
                        
                        CGFloat xCard , yCard = 0.0;
                        
                        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
                        {
                            xCard = 10.0;
                            yCard = 84.0;
                            cell.btnBack.frame = CGRectMake(cell.btnBack.frame.origin.x+15,
                                                            cell.btnBack.frame.origin.y-30,42,30);
                            cell.btnPlay.frame = CGRectMake(cell.btnPlay.frame.origin.x-60,
                                                            cell.btnPlay.frame.origin.y-30,81,30);
                        }
                        else
                        {
                            xCard = 84.0;
                            yCard = 112.0;
                            cell.btnBack.frame = CGRectMake(cell.btnBack.frame.origin.x+15,
                                                            cell.btnBack.frame.origin.y-150,150,60);
                            cell.btnPlay.frame = CGRectMake(cell.btnPlay.frame.origin.x-120,
                                                            cell.btnPlay.frame.origin.y-150,150,60);
                        }
                        
                        cell.frame = CGRectMake(xCard+gridCards.contentOffset.x, yCard+gridCards.contentOffset.y,cell.frame.size.width*2.5,cell.frame.size.height*2.5);
                        /*cell.btnBack.frame = CGRectMake(cell.btnBack.frame.origin.x+15,
                                                        cell.btnBack.frame.origin.y-30,42,30);
                        cell.btnPlay.frame = CGRectMake(cell.btnPlay.frame.origin.x-60,
                                                        cell.btnPlay.frame.origin.y-30,81,30);*/
                        
                        
                        //NSLog(@"After Frame : %@",NSStringFromCGPoint(cell.frame.origin));
                    }
                    completion:^(BOOL finished) {
                        [self applyFlipRightAnimation:cell];
                    }];
}

-(void)applyFlipRightAnimation:(Cell *)cell
{
    [UIView transitionWithView:cell
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [cell.imgVwShelf setImage:imgDetailCurrent];
                        [cell.btnBack setHidden:NO];
                        [cell.btnPlay setHidden:NO];
                    }
                    completion:^(BOOL finished) {
                        isZoomIn = YES;
                        isAnimating = NO;
                    }];
}
#pragma mark - 

#pragma mark - ZoomOut

-(void)ZoomOutAnimation
{
    isAnimating = YES;
    [self applyFlipLeftAnimation:currentCellInZoom];
}

-(void)applyZoomOutAnimation:(Cell *)cell
{
    [UIView transitionWithView:cell
                      duration:0.75
                       options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                    animations:^{
                        //cell.center = cellOriginalPosition;
                        //cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                        cell.frame = cellFrameOriginal;
                        cell.btnBack.frame = cellBtnBackFrame;
                        cell.btnPlay.frame = cellBtnPlayFrame;
                    }
                    completion:^(BOOL finished) {
                        isZoomIn = NO;
                        isAnimating = NO;
                        gridCards.scrollEnabled = YES;
                        
                        if (isPlayClick)
                        {
                            [self performSelectorOnMainThread:@selector(loadDeck:) withObject:[NSNumber numberWithInt:indexOfDeckInZoom] waitUntilDone:NO];
                            isPlayClick = NO;
                        }
                        
                    }];
}

-(void)applyFlipLeftAnimation:(Cell *)cell
{
    [UIView transitionWithView:cell
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [cell.imgVwShelf setImage:imgDisplayCurrent];
                        [cell.btnBack setHidden:YES];
                        [cell.btnPlay setHidden:YES];
                    }
                    completion:^(BOOL finished) {
                    [self applyZoomOutAnimation:cell];
                    }];
}

#pragma mark -


- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Prevent item from being moved to index 0
    //    if (toIndexPath.item == 0) {
    //        return NO;
    //    }
    return NO;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSDictionary *objectToMove = [arrayItemsList objectAtIndex:fromIndexPath.row];
    
    [arrayItemsList removeObjectAtIndex:fromIndexPath.row];
    [arrayItemsList insertObject:objectToMove atIndex:toIndexPath.row];
}

-(void)loadDeck:(NSNumber *)indexNumber
{
    NSDictionary *dictObject = [arrayItemsList objectAtIndex:[indexNumber intValue]];
    currentCardDeckIndex = [indexNumber intValue];
    NSString *nibName = nil;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        nibName = @"PlayViewController_iPhone";
    }
    else
    {
        nibName = @"PlayViewController_iPad";
    }
    
    PlayViewController *playVw = [[PlayViewController alloc] initWithNibName:nibName
                                                       bundle:[NSBundle mainBundle]];
    playVw.fileNamePack = [dictObject objectForKey:@"fileName"];
    [self.navController setNavigationBarHidden:YES];
    [self.navController setViewControllers:[NSArray arrayWithObject:playVw]];
    
    mainNav = (CustomNavPortraitViewController *)delegate.window.rootViewController;
    [delegate.window setRootViewController:self.navController];
    [delegate.window makeKeyAndVisible];
}



- (IBAction)watchVideo:(id)sender
{
    UIButton *btnWatch = (UIButton *)sender;
    
    [btnWatch setHidden:YES];
    [tblVwDetail setHidden:YES];
    [viewVideo setHidden:NO];
    [btnShareSave setHidden:NO];
    
    [self.videoPlayer play];
}

- (IBAction)pickAnotherDeck:(id)sender
{
    [self.videoPlayer stop];
    [scrllVwResult setHidden:YES];
}

- (IBAction)playThisDeckAgain:(id)sender
{
    [self.videoPlayer stop];
    [self loadDeck:[NSNumber numberWithInt:currentCardDeckIndex]];
}

- (IBAction)shareOrSaveVideo:(id)sender
{
    UIButton *btnSendBy = (UIButton *)sender;
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"Comparte en Facebook"
                     image:nil
                    target:self
                    action:@selector(shareToFacebook)],
      
      [KxMenuItem menuItem:@"Guardar En la galería"
                     image:nil
                    target:self
                    action:@selector(saveToGallery)],
      ];
    
    [KxMenu showMenuInView:self.view
                  fromRect:btnSendBy.frame
                 menuItems:menuItems];
}

- (IBAction)openAboutScreen:(id)sender
{
    NSString *nibName = nil;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        nibName = @"AboutViewController_iPhone";
    }
    else
    {
        nibName = @"AboutViewController_iPad";
    }
    
    AboutViewController *aboutVw = [[AboutViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:aboutVw animated:YES];
}


- (IBAction)openMoreScreen:(id)sender
{
    NSString *nibName = nil;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        nibName = @"moreViewController_iPhone";
    }
    else
    {
        nibName = @"moreViewController_iPad";
    }
    
    moreViewController *moreVw = [[moreViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:moreVw animated:YES];
}

-(void)shareToFacebook
{
    [self setDefaultPermissions];
}

#pragma mark - FaceBookSharing
-(void)setDefaultPermissions
{
    // Set some default permissions
    
    NSArray *permissions = @[@"basic_info",@"email"];
    
    // Set the dictionary that will be passed on to request account access
    
    NSDictionary *fbInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"725430124144864", ACFacebookAppIdKey,
                            permissions, ACFacebookPermissionsKey,
                            ACFacebookAudienceEveryone, ACFacebookAudienceKey,
                            nil];
    
    // Get the Facebook account type for the access request
    
    ACAccountType *fbAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // Request access to the Facebook account with the access info
    
    [self.accountStore requestAccessToAccountsWithType:fbAccountType options:fbInfo completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             // If access granted, then get the Facebook account info
             
             NSArray *accounts = [self.accountStore accountsWithAccountType:fbAccountType];
             
             self.facebookAccount = [accounts lastObject];
             
             // Set the service type for this request. This will be
             // used by the share input flow to configure it's UI.
             
             self.slService = SLServiceTypeFacebook;
             
             NSLog(@"Yes 1");
             
             // Since this handler can be called on an arbitrary queue
             // will show the UI in the main thread.
             
             [self performSelectorOnMainThread:@selector(renewPermissions) withObject:nil waitUntilDone:NO];
         }
         else
         {
             NSLog(@"Access not granted %@",error);
             [self performSelectorOnMainThread:@selector(errorSharing:) withObject:@"Facebook" waitUntilDone:NO];
         }
     }];
}

-(void)renewPermissions
{
    NSArray *permissions = @[@"email",@"publish_stream",@"publish_actions",@"video_upload"];
    
    // Set the dictionary that will be passed on to request
    // account access
    
    NSDictionary *fbInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"725430124144864", ACFacebookAppIdKey,
                            permissions, ACFacebookPermissionsKey,
                            ACFacebookAudienceEveryone, ACFacebookAudienceKey,
                            nil];
    
    // Get the Facebook account type for the access request
    
    ACAccountType *fbAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    // Request access to the Facebook account with the access info
    
    [self.accountStore requestAccessToAccountsWithType:fbAccountType options:fbInfo completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             // If access granted, then get the Facebook account info
             
             NSArray *accounts = [self.accountStore accountsWithAccountType:fbAccountType];
             
             self.facebookAccount = [accounts lastObject];
             
             // Set the service type for this request. This will be
             // used by the share input flow to configure it's UI.
             self.slService = SLServiceTypeFacebook;
             
             // Since this handler can be called on an arbitrary queue
             // will show the UI in the main thread.
             
             [self performSelectorOnMainThread:@selector(sendFacebookRequest) withObject:nil waitUntilDone:NO];
         }
         else
         {
             NSLog(@"Access not granted");
         }
     }];
}

- (void)sendFacebookRequest
{
    // Put together the post parameters. The status message
    // is passed in the message parameter key.
    
    //NSString *strMessage = @"TestingMessage";
    
    // NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:strMessage, @"message", nil];
    NSString *status = @"Guess What";
    NSString *description = @"Vídeo realizado con Adivina La Palabra. Puedes descargar esta divertida aplicación aquí: https://itunes.apple.com/no/app/gjett-hva-heads-up-pa-norsk/id838114118?mt=8&uo=4";
    NSDictionary *params = @{@"title":status, @"description":description};
    
    // Set up the Facebook Graph API URL for posting to a user's timeline
    //NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me/videos"];
    
    // Set up the request, passing all the required parameters
    SLRequest *fbShareRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:requestURL parameters:params];
    
    NSURL *urlPath = delegate.videoUrl;
    
    [fbShareRequest addMultipartData:self.dataRenderVideo
                            withName:@"source"
                                type:@"video/m4v"
                            filename:[urlPath absoluteString]];
    
    // Set up the account for this request
    fbShareRequest.account = self.facebookAccount;
    
    // Perform the request
    [fbShareRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         // In the completion handler, echo back the response
         // which should the Facebook post ID
         
         NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         NSLog(@"returned info: %@", response);
         
         if (response)
         {
             [self performSelectorOnMainThread:@selector(successSharing:)
                                    withObject:@"Share to Facebook" waitUntilDone:NO];
         }
         
     }];
}

-(void)errorSharing:(NSString *)networkType
{
    NSString *strMessage = [NSString stringWithFormat:@"Ve a configuración y establece tu cuenta de  %@",networkType];
    
    UIAlertView *alertError =[[UIAlertView alloc] initWithTitle:@"Ingresa" message:strMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertError show];
}

#pragma mark -

-(void)saveToGallery
{
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:delegate.videoUrl
                                completionBlock:^(NSURL *assetURL, NSError *error)
     {
         UIAlertView *alertSave = [[UIAlertView alloc] initWithTitle:@"" message:@"Se ha guardado el vídeo en la galería" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
         [alertSave show];
         
     }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrAnswersData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdent";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    ResType typeOfAction = [[arrAnswersAction objectAtIndex:indexPath.row] intValue];
    
    if (typeOfAction==typePass)
    {
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    
    if (typeOfAction==typeAnswer)
    {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    if (typeOfAction==typeTimeUp)
    {
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    [cell.textLabel setText:[arrAnswersData objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
