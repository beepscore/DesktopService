//
//  ApplicationController.h
//  DesktopService
//
//  Created by Steve Baker on 4/16/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ThreadedDrawingView;
@class ListenService;


@interface ApplicationController : NSObject {
#pragma mark instance variables
    NSTextView* logTextView_;
    ThreadedDrawingView* drawView_;
    ListenService *listenService_;
   
    // In IB, use bindings to connect checkboxes Draw Red, Green, Blue to shouldDrawColor1, 2, 3
    BOOL shouldDrawColor1;
    BOOL shouldDrawColor2;
    BOOL shouldDrawColor3;
    
    NSColor *color1_;
    NSColor *color2_;
    NSColor *color3_;
}

#pragma mark properties
// Apple recommends on Mac assign IBOutlet, on iPhone retain IBOutlet
// applies only to nib top-level objects?
@property(nonatomic, assign)IBOutlet ThreadedDrawingView *drawView;
@property(nonatomic, assign)IBOutlet NSTextView *logTextView;

// use atomic properties for thread safety
@property(assign) BOOL shouldDrawColor1;
@property(assign) BOOL shouldDrawColor2;
@property(assign) BOOL shouldDrawColor3;

@property(retain)NSColor *color1;
@property(retain)NSColor *color2;
@property(retain)NSColor *color3;

// singleton pattern
+(ApplicationController*)sharedApplicationController;

-(void)appendStringToLog:(NSString*)aString;

- (BOOL)shouldDrawColor:(NSColor*)color;

- (void)threadDrawForColor:(NSColor *)color;


// Note: I tried deleting the drawColor1,2,3Checked IBActions and using only bindings
// without wrapping BOOLs via [NSNumber numberWithBool: aBool]
// The checkboxes appeared to work, but the program leaked memory.
- (IBAction)drawColor1Checked:(id)sender;

- (IBAction)drawColor2Checked:(id)sender;

- (IBAction)drawColor3Checked:(id)sender;

- (IBAction)handleClearDrawingButton:(id)sender;

@end
