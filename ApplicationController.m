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


-(void)awakeFromNib
{
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
    NSLog(@"Started threadForColor: %@", [color description]);
    
    NSPoint lastPoint = [[self drawView] bounds].origin;
    
    // this thread runs indefinitely
    while (true)
    {        
        if ([[self drawView] lockFocusIfCanDraw])
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
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
            [[self drawView] unlockFocus];
            [pool release];
        }
    }
    NSLog(@"Exited threadForColor: %@", [color description]);
    [poolOne release];
}


#pragma mark -
#pragma mark IBAction
// Use checkboxes in view to set applicationController's properties.
// This is better MVC design than inspecting view checkbox properties in the controller.
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
