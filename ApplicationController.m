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


#pragma mark Log method
-(void)appendStringToLog:(NSString*)aString
{
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
