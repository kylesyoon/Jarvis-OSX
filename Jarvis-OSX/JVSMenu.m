//
//  JVSMenu.m
//  Jarvis-OSX
//
//  Created by Kyle Yoon on 3/30/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "JVSMenu.h"
#import "MultipeerClient.h"
#import "AppDelegate.h"

@interface JVSMenu() <MultipeerDelegate, NSMenuDelegate>

@end

@implementation JVSMenu

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    MultipeerClient *multipeer = [MultipeerClient sharedInstance];
    multipeer.delegate = self;
}

- (void)displayState:(MCSessionState)state peer:(MCPeerID *)peer
{
    NSMenuItem *connection = [self itemAtIndex:0];
    switch (state) {
        case MCSessionStateNotConnected:
            connection.title = @"Not Connected";
            break;
        case MCSessionStateConnecting:
            connection.title = [NSString stringWithFormat:@"Connecting to %@", peer.displayName];
            break;
        case MCSessionStateConnected:
            connection.title = [NSString stringWithFormat:@"Connected to %@", peer.displayName];
        default:
            break;
    }
}

#pragma mark - Menu IBActions

- (IBAction)pressedQuit:(NSMenuItem *)sender
{
    [NSApp terminate:self];
}

@end
