//
//  echoprintViewController.m
//  echoprint
//
//  Created by Brian Whitman on 6/13/11.
//  Copyright 2011 The Echo Nest. All rights reserved.
//

#import "echoprintViewController.h"
extern const char * GetPCMFromFile(char * filename);



@implementation echoprintViewController
@synthesize repeatingTimer;
@synthesize counter;
@synthesize samplesLabel;
@synthesize samplesSlider;
@synthesize timerSwitch;

- (IBAction)pickSong:(id)sender {
	NSLog(@"Pick song");
	MPMediaPickerController* mediaPicker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
	mediaPicker.delegate = self;
	[self presentModalViewController:mediaPicker animated:YES];
	
}

- (void)analyzeFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =[documentsDirectory stringByAppendingPathComponent:@"output.caf"];
    [statusLine setText:@"analysing..."];
    [statusLine setNeedsDisplay];
    [self.view setNeedsDisplay];
    const char * fpCode = GetPCMFromFile((char*) [filePath cStringUsingEncoding:NSASCIIStringEncoding]);
    [self getSong:fpCode];
}

- (NSDictionary *)userInfo {
    return [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"StartDate"];
}

- (void)timerFireMethod:(NSTimer*)theTimer {
    self.counter++;
    NSLog(@"Timer count:%d", self.counter);
    [self performSelectorInBackground:@selector(analyzeFile) withObject:nil];
    
    if (counter == samples) {
        [self stopRecordingSound];
    }
}

- (void)stopRepeatingTimer {
    if (self.repeatingTimer != nil) {
        [self.repeatingTimer invalidate];
        self.repeatingTimer = nil;
    }
}
    
- (void)stopRecordingSound {
    recording = NO;
    [recorder stopRecording];
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [self stopRepeatingTimer];
}

- (void)startRecordingSound {
    [statusLine setText:@"recording..."];
    recording = YES;
    [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
    [recorder startRecording];
    [statusLine setNeedsDisplay];
    [self.view setNeedsDisplay];
    self.counter = 0;
    
    if (timerSwitch.on) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 
                             target:self selector:@selector(timerFireMethod:) 
                             userInfo:[self userInfo] repeats:YES];
        self.repeatingTimer = timer;
    } else {
        [self stopRepeatingTimer];
    }
}

- (IBAction) startMicrophone:(id)sender {
	if(recording) {
        [self performSelectorInBackground:@selector(analyzeFile) withObject:nil];
		[self stopRecordingSound];
	} else {
		[self startRecordingSound];
	}
	NSLog(@"what");
}

- (IBAction)retestExistingAudio:(id)sender {
    [self analyzeFile];
}

- (IBAction)toggleTimer:(id)sender {
}

- (IBAction)setNumberOfSamples:(id)sender {
    samples = ((UISlider *)sender).value;
    self.samplesLabel.text = [[NSString alloc] initWithFormat:@"%d Samples:", samples];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[self dismissModalViewControllerAnimated:YES];
	for (MPMediaItem* item in mediaItemCollection.items) {
		NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
		NSURL* assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
		NSLog(@"title: %@, url: %@", title, assetURL);
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];

		NSURL* destinationURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"temp_data"]];
		[[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
		TSLibraryImport* import = [[TSLibraryImport alloc] init];
		[import importAsset:assetURL toURL:destinationURL completionBlock:^(TSLibraryImport* import) {
			//check the status and error properties of
			//TSLibraryImport
			NSString *outPath = [documentsDirectory stringByAppendingPathComponent:@"temp_data"];
			NSLog(@"done now. %@", outPath);
			[statusLine setText:@"analysing..."];
			const char * fpCode = GetPCMFromFile((char*) [outPath  cStringUsingEncoding:NSASCIIStringEncoding]);
			[statusLine setNeedsDisplay];
			[self.view setNeedsDisplay];
			[self getSong:fpCode];
		}];
		
	}
}

- (void) getSong: (const char*) fpCode {
	NSLog(@"Done %s", fpCode);
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/v4/song/identify?api_key=%@&version=4.12&code=%s", API_HOST, API_KEY, fpCode]];
	ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:url];
	[request setAllowCompressedResponse:NO];
	[request startSynchronous];
	NSError *error = [request error];
	if (!error) {
		NSString *response = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];		
		NSDictionary *dictionary = [response JSONValue];
		NSLog(@"%@", dictionary);
		NSArray *songList = [[dictionary objectForKey:@"response"] objectForKey:@"songs"];
		if([songList count]>0) {
			NSString * song_title = [[songList objectAtIndex:0] objectForKey:@"title"];
			NSString * artist_name = [[songList objectAtIndex:0] objectForKey:@"artist_name"];
			[statusLine setText:[NSString stringWithFormat:@"%@ - %@", artist_name, song_title]];
		} else {
			[statusLine setText:[[NSString alloc] initWithFormat:@"No match for try %d", self.counter]];
		}
	} else {
		[statusLine setText:@"some error"];
		NSLog(@"error: %@", error);
	}
	[statusLine setNeedsDisplay];
	[self.view setNeedsDisplay];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated:YES];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	recorder = [[MicrophoneInput alloc] init];
	recording = NO;
    [samplesSlider setValue:6];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setTimerSwitch:nil];
    [self setSamplesSlider:nil];
    [self setSamplesLabel:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [samplesLabel release];
    [samplesSlider release];
    [timerSwitch release];
    [super dealloc];
}

@end
