//
//  ApplicationController.m
//  DesktopService
//
//  Created by Steve Baker on 4/16/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import "ApplicationController.h"


@implementation ApplicationController

#pragma mark properties
@synthesize logTextView;


// Ref Cocoa Fundamentals Guide / Cocoa Objects / Creating a singleton instance. Code listing 2-15
// http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW32
// http://www.cocoadev.com/index.pl?SingletonDesignPattern
// singleton pattern Ref Buck Cocoa Design Patterns Ch 13
// Buck p 153  Override allocators to prevent others from creating more than one instance

static ApplicationController *myInstance = nil;

+ (ApplicationController*)sharedApplicationController{    
    if (myInstance == nil) {        
        myInstance = [[super allocWithZone:NULL] init];        
    }    
    return myInstance;
}

+ (id)allocWithZone:(NSZone *)zone{    
    return [[self sharedApplicationController] retain];
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

// for a singleton, don't implement dealloc method


#pragma mark Log method
-(void)appendStringToLog:(NSString*)aString{
    // Ref: appending text to a view
    // http://developer.apple.com/mac/library/documentation/cocoa/conceptual/TextArchitecture/Tasks/SimpleTasks.html
    NSRange endRange;
    
    endRange.location = [[logTextView textStorage] length];    
    endRange.length = 0;    
    [logTextView replaceCharactersInRange:endRange withString:aString];
    
    endRange.length = [aString length];    
    [logTextView scrollRangeToVisible:endRange];
}

@end
