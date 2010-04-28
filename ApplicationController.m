//
//  ApplicationController.m
//  DesktopService
//
//  Created by Steve Baker on 4/16/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import "ApplicationController.h"
#import "ThreadedDrawingView.h"
#import "ListenService.h"


// declare anonymous category for "private" methods, avoid showing in .h file
// Note in Objective C no method is private, it can be called from elsewhere.
// Ref http://stackoverflow.com/questions/1052233/iphone-obj-c-anonymous-category-or-private-category
@interface ApplicationController()
- (void) startService;
@end


@implementation ApplicationController

#pragma mark properties
@synthesize logTextView = logTextView_;
@synthesize drawView = drawView_;

@synthesize shouldDrawColor1;
@synthesize shouldDrawColor2;
@synthesize shouldDrawColor3;

@synthesize color1 = color1_;
@synthesize color2 = color2_;
@synthesize color3 = color3_;

// Ref Singletons
// Cocoa Fundamentals Guide / Cocoa Objects / Creating a singleton instance. Code listing 2-15
// http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW32
//
// Potential problem using singleton in a nib.  Mike Ash overrides -init
// http://www.cocoadev.com/index.pl?SingletonDesignPattern
//
// Chris Hanson's suggested non-strict singleton didn't work.
// http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
// Buck Cocoa Design Patterns Ch 13

+ (ApplicationController*)sharedApplicationController{    
    static ApplicationController *sharedApplicationController;
    
    if (sharedApplicationController == nil) {        
        sharedApplicationController = [[super allocWithZone:NULL] init];        
    }
    return sharedApplicationController;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [[self sharedApplicationController] retain];    
}

- (id)init
{
    self = [super init];
    if (nil != self) {
        // set up the colors we want to draw with
        self.color1 = [NSColor redColor];
        self.color2 = [NSColor greenColor];
        self.color3 = [NSColor blueColor];
        
        self.shouldDrawColor1 = YES;
        self.shouldDrawColor2 = YES;
        self.shouldDrawColor3 = YES;
    }
    return self;
}


// controller is awakeFromNib
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self startService];
    
    [[self drawView] setNeedsDisplay:YES];
    
    // start 3 drawing threads
    [NSThread detachNewThreadSelector:@selector(threadDrawForColor:) 
                             toTarget:self
                           withObject:[self color1]];
    
    [NSThread detachNewThreadSelector:@selector(threadDrawForColor:) 
                             toTarget:self
                           withObject:[self color2]];    
    
    [NSThread detachNewThreadSelector:@selector(threadDrawForColor:) 
                             toTarget:self
                           withObject:[self color3]];    
}


- (id)copyWithZone:(NSZone *)zone{    
    return self;
}

- (id)retain{
    return self;    
}

- (NSUInteger)retainCount{    
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release{    
    //do nothing
}

- (id)autorelease{    
    return self;
}


- (void)dealloc
{
    [color1_ release], color1_ = nil;
    [color2_ release], color2_ = nil;
    [color3_ release], color3_ = nil;
    [super dealloc];
}


#pragma mark Service

-(void)appendStringToLog:(NSString*)aString
{
    // Ref: appending text to a view
    // http://developer.apple.com/mac/library/documentation/cocoa/conceptual/TextArchitecture/Tasks/SimpleTasks.html
    
    NSRange endRange;    
    endRange.location = [[[self logTextView] textStorage] length];    
    endRange.length = 0;    
    [[self logTextView] replaceCharactersInRange:endRange withString:aString];
    
    endRange.length = [aString length];    
    [[self logTextView] scrollRangeToVisible:endRange];
}


- (void) startService
{
    listenService_ = [[ListenService alloc] init];
    [listenService_ startService];
    [listenService_ publishService];    
}


#pragma mark drawing

- (NSPoint) randomPointInBounds: (NSRect) bounds
{
    NSPoint result;
    int width, height;
    width = round (bounds.size.width);
    height = round (bounds.size.height);
    
    // defensive programming?
    if (width <= 0 || height <= 0) {
        return NSZeroPoint;
    }
    
    result.x = (random() % width) + bounds.origin.x;
    result.y = (random() % height) + bounds.origin.y;
    return (result);
}


- (BOOL)shouldDrawColor:(NSColor*)color
{
    // use atomic properties for thread safety
    if ((color == self.color1 && self.shouldDrawColor1) ||
        (color == self.color2 && self.shouldDrawColor2) ||
        (color == self.color3 && self.shouldDrawColor3))
    {
        return YES;
    }
    return NO;
}


- (void)threadDrawForColor:(NSColor *)color
{
    NSAutoreleasePool *poolOne = [[NSAutoreleasePool alloc] init];
    NSLog(@"Started threadDrawForColor: %@", [color description]);
    
    NSPoint lastPoint = [[self drawView] bounds].origin;
    
    // this thread runs indefinitely
    while (true)
    {    
        // lockFocusIfCanDraw is a mutex.
        // When a thread executes lockFocusIfCanDraw, 
        // only that thread can access the locked section of code
        if ([[self drawView] lockFocusIfCanDraw])
        {
            NSAutoreleasePool *poolTwo = [[NSAutoreleasePool alloc] init];
            
            if ([self shouldDrawColor:color])
            {
                NSPoint point;
                point = [self randomPointInBounds:[[self drawView] bounds]];
                [color set];
                [NSBezierPath strokeLineFromPoint:lastPoint 
                                          toPoint:point];
                [[[self drawView] window] flushWindow];
                lastPoint = point;
            }
            // unlock mutex so other threads can draw
            [[self drawView] unlockFocus];
            
            // http://developer.apple.com/mac/library/documentation/Cocoa/Reference/Foundation/Classes/NSAutoreleasePool_Class/Reference/Reference.html#//apple_ref/occ/instm/NSAutoreleasePool/drain
            [poolTwo drain];
        }
    }
    NSLog(@"Exited threadDrawForColor: %@", [color description]);
    // ????: if breakpoint here and user clicks "Draw Red" button, execution stops in drawColor1checked.
    // doesn't happen for other draw2colorChecked. Why?  Evaluation order of conditionals?
    [poolOne drain];
}


#pragma mark -
#pragma mark IBAction
// Use checkboxes in View to have Controller set Model properties.
// Here ApplicationController acts as the Controller and the Model.
// When user click event occurs, view sends message to controller to change model state.
// This is a more event driven design than having the controller continuously poll the view for each button state.
// the shouldDrawColor1,2,3 properties are convenient for handling input from iPhone client.

- (IBAction)drawColor1Checked:(id)sender{
    self.shouldDrawColor1 = (NSOnState == [sender state]);
}


- (IBAction)drawColor2Checked:(id)sender{
    self.shouldDrawColor2 = (NSOnState == [sender state]);
}


- (IBAction)drawColor3Checked:(id)sender{
    self.shouldDrawColor3 = (NSOnState == [sender state]);
}


- (IBAction)handleClearDrawingButton:(id)sender{
    [[self drawView] setNeedsDisplay:YES];
}

@end
