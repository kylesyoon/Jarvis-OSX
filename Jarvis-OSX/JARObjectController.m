//
//  JARObjectController.m
//  Jarvis-OSX
//
//  Created by Kyle Yoon on 4/10/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "JARObjectController.h"
#import "JARMultipeerController.h"
#import "JARAppleScript.h"
#import <AppKit/AppKit.h>

@interface JARObjectController() <MultipeerDelegate, NSMenuDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) JARMultipeerController *multipeerClient;
@property (nonatomic) BOOL didConnect;

@end

@implementation JARObjectController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.multipeerClient = [JARMultipeerController sharedInstance];
        self.multipeerClient.delegate = self;
        self.didConnect = NO;
        NSMenuItem *connectionState = [self.menu itemAtIndex:0];
        connectionState.title = @"Not Connected";
        
        self.menu.delegate = self;
    }
    
    return self;
}

- (void)updateMenuState:(MCSessionState)state peer:(MCPeerID *)peer
{
    NSMenuItem *connectionStatus = [self.menu itemAtIndex:0];
    switch (state) {
        case MCSessionStateNotConnected:
            connectionStatus.title = @"Not Connected";
            break;
        case MCSessionStateConnecting:
            connectionStatus.title = [NSString stringWithFormat:@"Connecting to %@", peer.displayName];
            break;
        case MCSessionStateConnected:
            connectionStatus.title = [NSString stringWithFormat:@"Connected to %@", peer.displayName];
        default:
            break;
    }
}

#pragma mark - Multipeer Delegate

- (void)didReceiveMessage:(NSString *)message
{
    [JARAppleScript doKeystrokeForMessage:message];
}

- (void)didChangeState:(MCSessionState)state peer:(MCPeerID *)peer
{
    [self presentConnectionNotificationForState:state peer:peer];
    [self updateMenuState:state peer:peer];
}

#pragma mark - IBActions

- (IBAction)pressedQuit:(NSMenuItem *)sender
{
    [NSApp terminate:self];
}

- (IBAction)pressedRefreshConnection:(id)sender
{
    [[JARMultipeerController sharedInstance] restartAdvertising];
}

#pragma mark - Notifications

- (void)presentConnectionNotificationForState:(MCSessionState)state peer:(MCPeerID *)peer
{
    NSUserNotification *connectionNotification = [[NSUserNotification alloc] init];
    switch (state) {
        case MCSessionStateConnected:
            connectionNotification.title = [NSString stringWithFormat:@"Connection Successful"];
            connectionNotification.informativeText = [NSString stringWithFormat:@"You are now connected with %@", peer.displayName];
            self.didConnect = YES;
            break;
        case MCSessionStateConnecting:
            connectionNotification.title = [NSString stringWithFormat:@"Connecting..."];
            connectionNotification.informativeText = [NSString stringWithFormat:@"Attempting to connect with %@", peer.displayName];
            break;
        case MCSessionStateNotConnected:
        default:
            if (self.didConnect) {
                connectionNotification.title = [NSString stringWithFormat:@"Disconnected"];
                connectionNotification.informativeText = [NSString stringWithFormat:@"Lost connection with %@", peer.displayName];
            } else {
                connectionNotification.title = [NSString stringWithFormat:@"Not connected"];
            }
            break;
    }
    connectionNotification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:connectionNotification];
    
    // Don't need to pile it up in the notification center.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:connectionNotification];
    });
}

@end
