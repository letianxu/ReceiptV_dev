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

@interface RVShoppingViewController() {
    NSMutableArray *_shopItems;
}

@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;

// Things which help us show off the dynamic language features.
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;

@end

@implementation RVShoppingViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_speakBtn setBackgroundColor:[UIColor whiteColor]];
    [_calculateBtn setBackgroundColor:[UIColor whiteColor]];
    [_cameraBtn setBackgroundColor:[UIColor whiteColor]];
    
    _shopItems = [[DBManager sharedInstance] getShoptItems:@"dummy"];
    
    // speech recognition setup
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    
    //[OELogging startOpenEarsLogging]; // Uncomment me for OELogging, which is verbose logging about internal OpenEars operations such as audio settings. If you have issues, show this logging in the forums.
    //[OEPocketsphinxController sharedInstance].verbosePocketSphinx = TRUE; // Uncomment this for much more verbose speech recognition engine output. If you have issues, show this logging in the forums.
    [self.openEarsEventsObserver setDelegate:self]; // Make this class the delegate of OpenEarsObserver so we can get all of the messages about what OpenEars is doing.
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil]; // Call this before setting any OEPocketsphinxController characteristics
    
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
        self.pathToDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"DynamicLanguageModel"];
        self.pathToDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"DynamicLanguageModel"];
    }
    // end of speech recognition setup
}

- (IBAction)launchCamera:(id)sender {
    CameraViewController *picker = [[CameraViewController alloc] init];
    [self presentViewController:picker animated:YES completion:^{}];
}

- (IBAction)launchMicToListen:(id)sender {
    NSLog(@"Speak button (via UIControlEventTouchDown)");
    
    if(![OEPocketsphinxController sharedInstance].isListening) {
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    }
    
}

- (IBAction)stopListening:(id)sender {
    NSLog(@"Speak button (via UIControlEventTouchUpInside)");
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) {
        error = [[OEPocketsphinxController sharedInstance] stopListening]; // React to it by telling Pocketsphinx to stop listening (if it is listening) since it will need to restart its loop after an interruption.
        if(error) NSLog(@"Error while stopping listening when releasing button: %@", error);
    }
    static int count = 0;
    //TODO: parse recognized words and add to shopItem list
    [_shopItems addObject:[[ShopItem alloc] initWithName:[NSString stringWithFormat:@"Item %d", count++] andPrice:0]];
}

#pragma mark -
#pragma mark OEEventsObserver delegate methods

// This is an optional delegate method of OEEventsObserver which delivers the text of speech that Pocketsphinx heard and analyzed, along with its accuracy score and utterance ID.
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    NSLog(@"Local callback: The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

// An optional delegate method of OEEventsObserver which informs that there was an interruption to the audio session (e.g. an incoming phone call).
- (void) audioSessionInterruptionDidBegin {
    NSLog(@"Local callback:  AudioSession interruption began.");
    NSError *error = nil;
    if([OEPocketsphinxController sharedInstance].isListening) {
        error = [[OEPocketsphinxController sharedInstance] stopListening]; // React to it by telling Pocketsphinx to stop listening (if it is listening) since it will need to restart its loop after an interruption.
        if(error) NSLog(@"Error while stopping listening in audioSessionInterruptionDidBegin: %@", error);
    }
}

// An optional delegate method of OEEventsObserver which informs that the interruption to the audio session ended.
- (void) audioSessionInterruptionDidEnd {
    NSLog(@"Local callback:  AudioSession interruption ended.");
    // We're restarting the previously-stopped listening loop.
    if(![OEPocketsphinxController sharedInstance].isListening){
        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE]; // Start speech recognition if we aren't currently listening.
    }
}


@end
