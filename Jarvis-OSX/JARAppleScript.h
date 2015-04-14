//
//  SLKAppleScript.h
//  Jarvis-OSX
//
//  Created by Kyle Yoon on 4/1/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JARAppleScript : NSAppleScript

+ (void)doKeystrokeForMessage:(NSString *)message;

@end
