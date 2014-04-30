//
//  PlayViewController.m
//  HeadsUp
//
//  Created by Zeeshan Ahmed on 2/12/14.
//  Copyright (c) 2014 RobinGronvold. All rights reserved.
//

#import "PlayViewController.h"



#define kCountReady @"3"
#define kCountPlay @"60"

#define kResultNotify @"ProduceResult"

CustomNavPortraitViewController* mainNav = NULL;

@interface PlayViewController ()

@end

@implementation PlayViewController
@synthesize movieURL;
@synthesize fileNamePack;
@synthesize movieWriter;
@synthesize filter;
@synthesize videoCamera;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self initAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)initAll
{
    arryActionsOnDecks = [[NSMutableArray alloc] init];
    arryCardsDone = [[NSMutableArray alloc] init];
    arrayIndexDones = [[NSMutableArray alloc] init];
    
    viewStartUp.alpha = 0.75;
    viewFirstCard.alpha = 0.75;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].bounds.size.height < 568)
        {
            [viewFirstCard setFrame:CGRectMake(viewFirstCard.frame.origin.x,viewFirstCard.frame.origin.y,480,320)];
        }
        else
        {
            [viewFirstCard setFrame:CGRectMake(viewFirstCard.frame.origin.x,viewFirstCard.frame.origin.y,568,320)];
        }
    }

    
    [self initializeVideoCamera];
    
    NSString *packPath = [[NSBundle mainBundle] pathForResource:fileNamePack ofType:@"plist"];
    arryPack = [[NSMutableArray alloc] initWithContentsOfFile:packPath];
    
    indexCurrentPack = arc4random() % [arryPack count];
    
    readyCount = [kCountReady intValue];
    playCount = [kCountPlay intValue];
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.5;
    
    if ([_motionManager isAccelerometerAvailable])
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [_motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!isPlacedOnForeHead)
                {
                    [self performForeHeadCheck:accelerometerData.acceleration.x
                                        _yAxis:accelerometerData.acceleration.y
                                        _zAxis:accelerometerData.acceleration.z];
                }
                
                if (isGameRunning)
                {
                    [self performPassAnswerCheck:accelerometerData.acceleration.x
                                          _yAxis:accelerometerData.acceleration.y
                                          _zAxis:accelerometerData.acceleration.z];
                }
                
            });
        }];
    }
    else
    {
        NSLog(@"not active");
    }
}

-(void)initializeVideoCamera
{
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    self.filter = [[GPUImageFilter alloc] init];
    
    [self.videoCamera addTarget:self.filter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [self.filter addTarget:filterView];
    
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    
    
    [self.filter addTarget:self.movieWriter];
    [videoCamera startCameraCapture];
}

-(void)startRecording
{
    
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
}

-(void)stopRecording
{
    [self.filter removeTarget:self.movieWriter];
    self.videoCamera.audioEncodingTarget = nil;
    [self.movieWriter finishRecording];
    
    
    
        NSLog(@"Finish");
//    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
//    [library writeVideoAtPathToSavedPhotosAlbum:self.movieURL
//                                completionBlock:^(NSURL *assetURL, NSError *error)
//     {
//         /*notify of completion*/
//         NSLog(@"Complete");
//         
//     }];
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    // Map UIDeviceOrientation to UIInterfaceOrientation.
//    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
//    switch ([[UIDevice currentDevice] orientation])
//    {
//        case UIDeviceOrientationLandscapeLeft:
//            orient = UIInterfaceOrientationLandscapeLeft;
//            break;
//            
//        case UIDeviceOrientationLandscapeRight:
//            orient = UIInterfaceOrientationLandscapeRight;
//            break;
//            
//        case UIDeviceOrientationPortrait:
//            orient = UIInterfaceOrientationPortrait;
//            break;
//            
//        case UIDeviceOrientationPortraitUpsideDown:
//            orient = UIInterfaceOrientationPortraitUpsideDown;
//            break;
//            
//        case UIDeviceOrientationFaceUp:
//        case UIDeviceOrientationFaceDown:
//        case UIDeviceOrientationUnknown:
//            // When in doubt, stay the same.
//            orient = fromInterfaceOrientation;
//            break;
//    }
//    videoCamera.outputImageOrientation = orient;
//    
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES; // Support all orientations.
//}

-(void)performForeHeadCheck:(double)x _yAxis:(double)y _zAxis:(double)z
{
    //NSLog(@"X:%f Y:%f Z:%f",x,y,z);
    
    if (x <= -0.95)
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [lblStartUp setText:@"¡Prepárate! "];
        isPlacedOnForeHead = YES;
        _timerReady = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(readyCountDown)
                                                     userInfo:nil repeats:YES];
    }
}


-(void)readyCountDown
{
    if (readyCount == 0)
    {
        [_timerReady invalidate];
        isGameRunning = YES;
        _timerRun = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(playCountDown)
                                                   userInfo:nil repeats:YES];
        //Recording
        [self startRecording];
        
        viewToHide = viewStartUp;
        viewToShow = viewFirstCard;
        [self loadNextCard];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"gong" ofType:@"mp3"]; /// set .mp3 name which you have in project
        audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        audioPlayer.delegate=self;
        //[audioPlayer setNumberOfLoops: 2];
        [audioPlayer play];

        //[self hideCurrentSubView];
        //[self showNextSubView];
    }
    else
    {
        [lblStartUp setText:[NSString stringWithFormat:@"%i",readyCount]];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"mp3"]; /// set .mp3 name which you have in project
        audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        audioPlayer.delegate=self;
        //[audioPlayer setNumberOfLoops: 2];
        [audioPlayer play];
        readyCount--;
    }
}


-(void)playCountDown
{
    if (playCount == 0)
    {
        [audioPlayer stop];
        [_timerRun invalidate];
        
        //Recording
        [self stopRecording];
        
        isGameRunning = NO;
        [viewFirstCard setBackgroundColor:[UIColor redColor]];
        [lblFirstCard setText:@"Se acabó el tiempo"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"wrong_sound" ofType:@"mp3"]; /// set .mp3 name which you have in project
            audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
            audioPlayer.delegate=self;
            [audioPlayer setNumberOfLoops: 2];
            [audioPlayer play];
    
        

        [lblGameCountDown setText:@""];
        [arryActionsOnDecks addObject:[NSNumber numberWithInt:typeTimeUp]];
        
        [self hideCurrentSubView];
        [self showNextSubView];
        
        [self performSelector:@selector(goBackToCardsSelection) withObject:nil afterDelay:3.0];
    }
    else
    {
        [lblGameCountDown setText:[NSString stringWithFormat:@"%i",playCount]];
        playCount--;
    }
}

-(void)performPassAnswerCheck:(double)x _yAxis:(double)y _zAxis:(double)z
{
    //NSLog(@"X:%f Y:%f Z:%f",x,y,z);
    
    if (z <= -0.83 && !isPass)
    {
        [viewFirstCard setBackgroundColor:[UIColor orangeColor]];
        //NSLog(@"PASS");
        isPass=YES;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"wrong_sound" ofType:@"mp3"]; /// set .mp3 name which you have in project
        audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        audioPlayer.delegate=self;
        [audioPlayer play];
        [arryActionsOnDecks addObject:[NSNumber numberWithInt:typePass]];
    }
    
    if (z >= 0.75 && !isCorrect)
    {
        [viewFirstCard setBackgroundColor:[UIColor greenColor]];
        //NSLog(@"Correct");
        isCorrect=YES;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"correct_sound" ofType:@"mp3"]; /// set .mp3 name which you have in project
        audioPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        audioPlayer.delegate=self;
        [audioPlayer play];
        [arryActionsOnDecks addObject:[NSNumber numberWithInt:typeAnswer]];
    }
    
    if (x <= -0.75 && (isCorrect || isPass))
    {
        [self loadNextCard];
        [self hideCurrentSubView];
        isCorrect = NO;
        isPass = NO;
    }
}

-(void)loadNextCard
{
    //NSLog(@"%@",[arryPack objectAtIndex:indexCurrentPack]);
    [viewFirstCard setBackgroundColor:[UIColor blueColor]];
    [lblFirstCard setText:[arryPack objectAtIndex:indexCurrentPack]];
    [arryCardsDone addObject:[arryPack objectAtIndex:indexCurrentPack]];
    
    [arryPack removeObjectAtIndex:indexCurrentPack];
    indexCurrentPack = arc4random() % [arryPack count];
    
    [self hideCurrentSubView];
    [self showNextSubView];
}

- (void)showNextSubView
{
	[self.view addSubview:viewToShow];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.35];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[self.view layer] addAnimation:animation forKey:@"SlideView"];
}

- (void)hideCurrentSubView
{
    
	[viewToHide removeFromSuperview];
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.35];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromRight];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[self.view layer] addAnimation:animation forKey:@"SlideView"];
}

-(void)goBackToCardsSelection
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.arryAnswers = arryActionsOnDecks;
    delegate.arryCardsAnswered = arryCardsDone;
    delegate.videoUrl = self.movieURL;
    
    [self.videoCamera stopCameraCapture];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kResultNotify object:nil];
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [delegate.window setRootViewController:mainNav];
    [delegate.window makeKeyAndVisible];
}

@end
