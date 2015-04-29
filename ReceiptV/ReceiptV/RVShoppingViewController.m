//
//  MSMapViewController.m
//  Example
//
//  Created by Eric Horacek on 10/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <MapKit/MapKit.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OELogging.h>
#import <OpenEars/OEAcousticModel.h>
#import "CameraViewController.h"
#import "RVShoppingViewController.h"
#import "DBManager.h"
#import "ViewUtils.h"
#import "SpeechResult.h"

@interface RVShoppingViewController() {
    OEPocketsphinxController *_OESingleton;
    DBManager *_dbManager;
}

@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;

// Things which help us show off the dynamic language features.
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;

// Timer to update recording audio input level on image in a different thread
@property (nonatomic, strong) NSTimer *audioInputLevelTimer;
@end

@implementation RVShoppingViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_speakBtn setBackgroundColor:[UIColor whiteColor]];
    [_calculateBtn setBackgroundColor:[UIColor whiteColor]];
    [_cameraBtn setBackgroundColor:[UIColor whiteColor]];
    
    [_speakBtn addTarget:self action:@selector(launchMicToListen) forControlEvents:UIControlEventTouchDown];
    [_speakBtn addTarget:self action:@selector(stopListening) forControlEvents:UIControlEventTouchUpInside];
    [_speakBtn addTarget:self action:@selector(stopListening) forControlEvents:UIControlEventTouchDragExit];
    
    _audioMeterView.hidden = YES;
    
    _OESingleton =[OEPocketsphinxController sharedInstance];
    _dbManager = [DBManager sharedInstance];
    
    if (![_dbManager isTableExisting:@"dummy_ShopName"])
        [_dbManager createTableWithName:@"dummy_ShopName" primaryKey:nil shopItemClass:[ShopItem class]];
    else
        NSLog(@"Table %@ already exists", @"dummy_ShopName");
    
    // speech recognition setup
    _openEarsEventsObserver = [[OEEventsObserver alloc] init];
    _openEarsEventsObserver.delegate = self;
    
    //[OELogging startOpenEarsLogging]; // Uncomment me for OELogging, which is verbose logging about internal OpenEars operations such as audio settings. If you have issues, show this logging in the forums.
    //[_OESingleton.verbosePocketSphinx = TRUE; // Uncomment this for much more verbose speech recognition engine output. If you have issues, show this logging in the forums.
    [_openEarsEventsObserver setDelegate:self]; // Make this class the delegate of OpenEarsObserver so we can get all of the messages about what OpenEars is doing.
    
    [_OESingleton setActive:TRUE error:nil]; // Call this before setting any OEPocketsphinxController characteristics
    
    NSArray *wordsArray = @[@"BACKWARD",
                                    @"CHANGE",
                                    @"FORWARD",
                                    @"GO",
                                    @"LEFT",
                                    @"MODEL",
                                    @"RIGHT",
                                    @"TURN"];
    
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    
    //languageModelGenerator.verboseLanguageModelGenerator = TRUE; // Uncomment me for verbose language model generator debug output.
    
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:wordsArray withFilesNamed:@"DynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    } else {
        _pathToDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"DynamicLanguageModel"];
        _pathToDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"DynamicLanguageModel"];
    }
    // end of speech recognition setup
}

- (IBAction)launchCamera:(id)sender {
    CameraViewController *picker = [[CameraViewController alloc] init];
    [self presentViewController:picker animated:YES completion:^{}];
}

- (void)launchMicToListen
{
    NSLog(@"Speak button (via UIControlEventTouchDown)");
    if (!_OESingleton.micPermissionIsGranted)
        return;
    
    if(!_OESingleton.isListening) {
        NSLog(@"Start the engine and recognition loop...");
        [_OESingleton startListeningWithLanguageModelAtPath:_pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:_pathToDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    }
    
    if (_OESingleton.isSuspended)
    {
        NSLog(@"Resume recognition loop...");
        [_OESingleton resumeRecognition];
    }
    
    _audioMeterView.hidden = NO;
    _audioInputLevelTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateAudioInputLevel) userInfo:nil repeats:YES];
    
}

- (void)stopListening
{
    NSLog(@"Speak button (via UIControlEventTouchUpInside)");
    if(_OESingleton.isListening && !_OESingleton.isSuspended) {
        NSLog(@"Keep the engine going but stop listening to speech...");
        [_OESingleton suspendRecognition];
    }
    if (_audioInputLevelTimer && [_audioInputLevelTimer isValid])
    {
        [_audioInputLevelTimer invalidate];
        _audioInputLevelTimer = nil;
    }
    _audioMeterView.hidden = YES;
}

- (void)updateAudioInputLevel
{
    //NSLog(@"Audio input level:%f", [_OESingleton pocketsphinxInputLevel]);
    float audioInputLevel = [_OESingleton pocketsphinxInputLevel];
    UIImage *image;
    if (audioInputLevel <= -115.0) {
        image = [UIImage imageNamed:@"record_animate_01.png"];
    }else if (-115.0 < audioInputLevel && audioInputLevel <= -110.0) {
        image = [UIImage imageNamed:@"record_animate_02.png"];
    }else if (-110.0 < audioInputLevel && audioInputLevel <= -105.0) {
        image = [UIImage imageNamed:@"record_animate_03.png"];
    }else if (-105.0 < audioInputLevel && audioInputLevel <= -100.0) {
        image = [UIImage imageNamed:@"record_animate_04.png"];
    }else if (-100.0 < audioInputLevel && audioInputLevel <= -95.0) {
        image = [UIImage imageNamed:@"record_animate_05.png"];
    }else if (-95.0 < audioInputLevel && audioInputLevel <= -90.0) {
        image = [UIImage imageNamed:@"record_animate_06.png"];
    }else if (-90.0 < audioInputLevel && audioInputLevel <= -85.0) {
        image = [UIImage imageNamed:@"record_animate_07.png"];
    }else if (-85.0 < audioInputLevel && audioInputLevel <= -80.0) {
        image = [UIImage imageNamed:@"record_animate_08.png"];
    }else if (-80.0 < audioInputLevel && audioInputLevel <= -75.0) {
        image = [UIImage imageNamed:@"record_animate_09.png"];
    }else if (-75.0 < audioInputLevel && audioInputLevel <= -70.0) {
        image = [UIImage imageNamed:@"record_animate_10.png"];
    }else if (-70.0 < audioInputLevel && audioInputLevel <= -65.0) {
        image = [UIImage imageNamed:@"record_animate_11.png"];
    }else if (-65.0 < audioInputLevel && audioInputLevel <= -60.0) {
        image = [UIImage imageNamed:@"record_animate_12.png"];
    }else if (-60.0 < audioInputLevel && audioInputLevel <= -55.0) {
        image = [UIImage imageNamed:@"record_animate_13.png"];
    }else {
        image = [UIImage imageNamed:@"record_animate_14.png"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the UI
        [_audioMeterView setImage:image];
    });
}

#pragma mark -
#pragma mark OEEventsObserver delegate methods

// This is an optional delegate method of OEEventsObserver which delivers the text of speech that Pocketsphinx heard and analyzed, along with its accuracy score and utterance ID.
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    SpeechResult *result = [[SpeechResult alloc] initWithResult:hypothesis];
    ShopItem *item = [result parseOneShoptItem];
    
    [_dbManager addShopItemToTable:@"dummy_ShopName" item:item];
}

// Pocketsphinx has an n-best hypothesis dictionary.
- (void) pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray {
    NSLog(@"Local callback:  hypothesisArray is %@",hypothesisArray);
}

// An optional delegate method of OEEventsObserver which informs that there was an interruption to the audio session (e.g. an incoming phone call).
- (void) audioSessionInterruptionDidBegin {
    NSLog(@"Local callback:  AudioSession interruption began.");
    NSError *error = nil;
    if(_OESingleton.isListening) {
        error = [_OESingleton stopListening]; // React to it by telling Pocketsphinx to stop listening (if it is listening) since it will need to restart its loop after an interruption.
        if(error) NSLog(@"Error while stopping listening in audioSessionInterruptionDidBegin: %@", error);
    }
}

// An optional delegate method of OEEventsObserver which informs that the interruption to the audio session ended.
- (void) audioSessionInterruptionDidEnd {
    NSLog(@"Local callback:  AudioSession interruption ended.");
    // We're restarting the previously-stopped listening loop.
    if(!_OESingleton.isListening){
        [_OESingleton startListeningWithLanguageModelAtPath:_pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:_pathToDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't currently listening.
    }
}

// An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
// likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
- (void) pocketsphinxDidStopListening {
    NSLog(@"Local callback: Pocketsphinx has stopped listening.");
}


@end
