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
// http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
// Cocoa Fundamentals Guide / Cocoa Objects / Creating a singleton instance. Code listing 2-15
// http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/CocoaObjects.html#//apple_ref/doc/uid/TP40002974-CH4-SW32
// http://www.cocoadev.com/index.pl?SingletonDesignPattern
// Buck Cocoa Design Patterns Ch 13


+ (ApplicationController *)sharedApplicationController
{
    static ApplicationController *sharedApplicationController;    
    @synchronized(self)
    {
        if (!sharedApplicationController)
            sharedApplicationController = [[ApplicationController alloc] init];
        
        return sharedApplicationController;
    }
}


#pragma mark Log method
-(void)appendStringToLog:(NSString*)aString
{
    // Ref: appending text to a view
    // http://developer.apple.com/mac/library/documentation/cocoa/conceptual/TextArchitecture/Tasks/SimpleTasks.html
    NSLog(@"appendStringToLog %@", aString);
    NSRange endRange;
    
    endRange.location = [[logTextView textStorage] length];    
    endRange.length = 0;    
    [logTextView replaceCharactersInRange:endRange withString:aString];
    
    endRange.length = [aString length];    
    [logTextView scrollRangeToVisible:endRange];
}

@end
