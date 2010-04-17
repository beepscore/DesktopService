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


// singleton pattern Ref Buck Cocoa Design Patterns Ch 13
// Buck p 153  Override allocators to prevent others from creating more than one instance
+(id)hiddenAlloc{
    // [super alloc] will retain the object
    // ????: Clang warns potential leak.  OK for singleton?
    return [super alloc];
}

+(NSString*)name{
    return @"ApplicationController";
}

+(id)alloc{
    NSLog(@"%@: use +sharedApplicationController instead of +alloc", [[self class] name]);
    return nil;
}

+(id)new{
    return [self alloc];
}

+(id)allocWithZone:(NSZone *)zone{
    return [self alloc];
}

-(id)copyWithZone:(NSZone *)zone{
    // -copy inherited from NSObject calls -copyWithZone:
    NSLog(@"ApplicationController:  attempt to -copy may be a bug.");
    [self retain];
    return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    // -mutableCopy inherited from NSObject calls -mutableCopyWithZone:
    return [self copyWithZone:zone];
}

// Buck p 150, 154
+(ApplicationController*)sharedApplicationController{
    
    static ApplicationController *myInstance = nil;
    if (!myInstance) {
        // ????: Clang warns incorrect decrement of the reference count... why?
        myInstance = [[ApplicationController hiddenAlloc] init];
    }
    return myInstance;
}

- (void)dealloc {
    [logTextView release], logTextView = nil;
    
    [super dealloc];
}

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
