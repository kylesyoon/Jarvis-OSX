//
//  MultipeerClient.m
//  JarvisCentral
//
//  Created by Kyle Yoon on 3/20/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "MultipeerClient.h"
#import "AppDelegate.h"

static NSString *const JVSJarvisMessage = @"JARVIS";
static NSString *const JVSNextMessage = @"NEXT";
static NSString *const JVSBackMessage = @"BACK";
static NSString *const JVSESCMessage = @"ESC";
static NSString *const JVSMuteMessage = @"MUTE";
static NSString *const JVSUnmuteMessage = @"UNMUTE";

static NSString *const JARVISServiceType = @"jarvis-service";

@interface MultipeerClient() <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>

@property (strong, nonatomic) MCPeerID *localPeerID;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) NSMenuItem *connectionStatus;

@end

@implementation MultipeerClient

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[NSHost currentHost] localizedName]];
    
    if (!self.advertiser) {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.localPeerID discoveryInfo:nil serviceType:JARVISServiceType];
        
    }
    self.advertiser.delegate = self;
    NSLog(@"ADVERTISER INITALIZED %@", self.advertiser);
    [self.advertiser startAdvertisingPeer];
    
    return self;
}

//- (void)stopAdvertising
//{
//    self.advertiser.delegate = nil;
//    [self.advertiser stopAdvertisingPeer];
//    NSLog(@"Stopped advertising");
//}

#pragma mark - Convenience

- (void)doKeystrokeForMessage:(NSString *)message
{
    NSLog(@"Doing Keystroke for message %@", message);
    
    if ([message isEqualToString:JVSJarvisMessage]) {
//        [self.delegate displayResponse:@"Yes?"];
    } else if ([message isEqualToString:JVSNextMessage]) {
        [self rightArrowKeystroke];
//        [self.delegate displayResponse:JVSNextMessage];
    } else if ([message isEqualToString:JVSBackMessage]) {
        [self leftArrowKeystroke];
//        [self.delegate displayResponse:JVSBackMessage];
    } else if ([message isEqualToString:JVSESCMessage]) {
        [self escapeKeystroke];
//        [self.delegate displayResponse:JVSESCMessage];
    } else if ([message isEqualToString:JVSMuteMessage]) {
        [self muteKeystroke];
//        [self.delegate displayResponse:JVSMuteMessage];
    } else if ([message isEqualToString:JVSUnmuteMessage]) {
        [self unmuteKeystroke];
    }
}

#pragma mark - NSAppleScript
// TODO: Let's make a keystroke constants file and turn this into one method. Need to associate the Message constant with the co-responding key code number.
- (void)rightArrowKeystroke
{
    NSAppleScript *right = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 124"];
    [right executeAndReturnError:nil];
    NSLog(@"Keystroke 124");
}

- (void)leftArrowKeystroke
{
    NSAppleScript *left = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 123"];
    [left executeAndReturnError:nil];
    NSLog(@"Keystroke 123");
}

- (void)escapeKeystroke
{
    NSAppleScript *escape = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to key code 53"];
    [escape executeAndReturnError:nil];
    NSLog(@"Keystroke 53");
}

- (void)muteKeystroke
{
    NSAppleScript *escape = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to set volume with output muted"];
    [escape executeAndReturnError:nil];
    NSLog(@"Mute");
    
}

- (void)unmuteKeystroke
{
    NSAppleScript *escape = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to set volume without output muted"];
    [escape executeAndReturnError:nil];
    NSLog(@"Unmute");
    
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSLog(@"MCNearbyServiceAdvertiser didReceiveInvitationFromPeer: %@", peerID);
    
    if (!self.session) {
        self.session = [[MCSession alloc] initWithPeer:self.localPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    }
    self.session.delegate = self;
    
    invitationHandler(YES, self.session);
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"Error %@", error);
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"MCSessionDelegate - didReceiveDataFrom: %@", peerID);
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received message %@", message);
    
    if (message) {
        [self doKeystrokeForMessage:message];
    }
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    [self.delegate displayState:state peer:peerID];
    
    switch (state) {
        case MCSessionStateNotConnected:
            NSLog(@"NOT CONNECTED");
            break;
        case MCSessionStateConnecting:
            NSLog(@"CONNECTING");
            break;
        default:
            NSLog(@"CONNECTED");
            break;
    }
}
// Boiler plate stuff.
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Did start receiving resource: %@ from peer: %@ with progress:%@", resourceName, peerID, progress);
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"Did finish receiving resource: %@ from peer: %@ at URL: %@ with error :%@", resourceName, peerID, localURL, error);
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Did receive stream: %@ with name: %@ from peer:%@", stream, streamName, peerID);
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

@end
