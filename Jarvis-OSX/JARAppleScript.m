//
//  SLKAppleScript.m
//  Jarvis-OSX
//
//  Created by Kyle Yoon on 4/1/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "JARAppleScript.h"
#import "JARConstants.h"

@implementation JARAppleScript

+ (void)doKeystrokeForMessage:(NSString *)message
{
    NSLog(@"Doing Keystroke for message %@", message);
    
    if ([message isEqualToString:MessagePayload.next]) {
        [JARAppleScript rightArrowKeystroke];
    } else if ([message isEqualToString:MessagePayload.strongNext]) {
        [JARAppleScript rightArrowKeystrokeWithNumberOfStrokes:20];
    } else if ([message isEqualToString:MessagePayload.back]) {
        [JARAppleScript leftArrowKeystroke];
    } else if ([message isEqualToString:MessagePayload.present]) {
        [JARAppleScript cmdEnterKeystroke];
    } else if ([message isEqualToString:MessagePayload.esc]) {
        [JARAppleScript escapeKeystroke];
    } else if ([message isEqualToString:MessagePayload.mute]) {
        [JARAppleScript muteKeystroke];
    } else if ([message isEqualToString:MessagePayload.unmute]) {
        [JARAppleScript unmuteKeystroke];
    }
}

+ (void)rightArrowKeystroke
{
    NSAppleScript *right = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 124"];
    [right executeAndReturnError:nil];
    NSLog(@"Keystroke 124");
}

+ (void)rightArrowKeystrokeWithNumberOfStrokes:(int)strokes
{
    for (int i = 0; i < strokes; i++) {
        [JARAppleScript rightArrowKeystroke];
    }
}

+ (void)leftArrowKeystroke
{
    NSAppleScript *left = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 123"];
    [left executeAndReturnError:nil];
    NSLog(@"Keystroke 123");
}

+ (void)muteKeystroke
{
    NSAppleScript *escape = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to set volume with output muted"];
    [escape executeAndReturnError:nil];
    NSLog(@"Mute");
    
}

+ (void)unmuteKeystroke
{
    NSAppleScript *escape = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to set volume without output muted"];
    [escape executeAndReturnError:nil];
    NSLog(@"Unmute");
    
}

#pragma mark - Non-motion

+ (void)cmdEnterKeystroke
{
    NSAppleScript *cmdEnter = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to keystroke return using command down"];
    [cmdEnter executeAndReturnError:nil];
    NSLog(@"Unmute");
}

+ (void)escapeKeystroke
{
    NSAppleScript *escape = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 53"];
    [escape executeAndReturnError:nil];
    NSLog(@"Keystroke 53");
}

@end
