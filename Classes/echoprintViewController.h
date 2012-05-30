//
//  echoprintViewController.h
//  echoprint
//
//  Created by Brian Whitman on 6/13/11.
//  Copyright 2011 The Echo Nest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "TSLibraryImport.h"
#import "MicrophoneInput.h"

// developer.echonest.com
#define API_KEY @"CCQ7NJ6VUAXLXMA1T"
#define API_HOST @"developer.echonest.com"

@interface echoprintViewController : UIViewController <MPMediaPickerControllerDelegate> {
	BOOL recording;
	IBOutlet UIButton* recordButton;
	IBOutlet UILabel* statusLine;
	MicrophoneInput* recorder;
    NSTimer *repeatingTimer;
    int samples;
}

@property (assign) NSTimer *repeatingTimer;
@property (nonatomic) int counter;
@property (retain, nonatomic) IBOutlet UILabel *samplesLabel;
@property (retain, nonatomic) IBOutlet UISlider *samplesSlider;
@property (retain, nonatomic) IBOutlet UISwitch *timerSwitch;

- (void)getSong:(const char*)fpCode;
- (NSDictionary *)userInfo;

- (IBAction)pickSong:(id)sender;
- (IBAction)startMicrophone:(id)sender;
- (IBAction)retestExistingAudio:(id)sender;
- (IBAction)toggleTimer:(id)sender;
- (IBAction)setNumberOfSamples:(id)sender;

@end

