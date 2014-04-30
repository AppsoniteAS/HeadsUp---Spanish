//
//  PlayViewController.h
//  HeadsUp
//
//  Created by Zeeshan Ahmed on 2/12/14.
//  Copyright (c) 2014 RobinGronvold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreMotion/CoreMotion.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GPUImage.h"
#import<AVFoundation/AVAudioPlayer.h>
#import "CustomNavPortraitViewController.h"

extern CustomNavPortraitViewController* mainNav;

@interface PlayViewController : UIViewController <AVAudioPlayerDelegate>
{
    
    CMMotionManager *_motionManager;
    __weak IBOutlet UILabel *lblStartUp;
    __weak IBOutlet UILabel *lblGameCountDown;
    BOOL isPlacedOnForeHead;
    AVAudioPlayer* audioPlayer;
    NSTimer *_timerReady;
    int readyCount;
    
    BOOL isGameRunning;
    NSTimer *_timerRun;
    int playCount;
    NSMutableArray *arryPack;
    int indexCurrentPack;
    
    BOOL isPass;
    BOOL isCorrect;
    
    IBOutlet UIView *viewStartUp;
    IBOutlet UIView *viewFirstCard;
    __weak IBOutlet UILabel *lblFirstCard;
    
    UIView *viewToHide;
    UIView *viewToShow;
    
    NSMutableArray *arryActionsOnDecks;
    NSMutableArray *arryCardsDone;
    
    NSMutableArray *arrayIndexDones;
}

@property(nonatomic,retain)NSString *fileNamePack;
@property(nonatomic,retain)NSURL *movieURL;

@property(nonatomic,retain)GPUImageVideoCamera *videoCamera;
@property(nonatomic,retain)GPUImageMovieWriter *movieWriter;
@property(nonatomic,retain)GPUImageOutput<GPUImageInput> *filter;

-(void)initializeVideoCamera;
-(void)startRecording;
-(void)stopRecording;

-(void)performForeHeadCheck:(double)x _yAxis:(double)y _zAxis:(double)z;
-(void)readyCountDown;


-(void)playCountDown;
-(void)performPassAnswerCheck:(double)x _yAxis:(double)y _zAxis:(double)z;

-(void)loadNextCard;

@end
