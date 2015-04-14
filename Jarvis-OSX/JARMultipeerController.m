//
//  MultipeerClient.m
//  JarvisCentral
//
//  Created by Kyle Yoon on 3/20/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "JARMultipeerController.h"
#import "JARConstants.h"
#import "JARAppleScript.h"

static NSString *const JARVISServiceType = @"jarvis-service";

@interface JARMultipeerController() <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, NSUserNotificationCenterDelegate>

@property (strong, nonatomic) MCPeerID *localPeerID;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) NSMenuItem *connectionStatus;
@property (strong, nonatomic) MCPeerID *connectedPeerID;
@property (nonatomic) MCSessionState sessionState;
@property (nonatomic) BOOL didConnect;

@end

@implementation JARMultipeerController

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
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[NSHost currentHost] localizedName]];
    self.didConnect = NO;
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;

    [self startAdvertising];
}

- (void)startAdvertising
{
    if (!self.advertiser) {
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.localPeerID discoveryInfo:nil serviceType:JARVISServiceType];
        self.advertiser.delegate = self;
    }
    [self.advertiser startAdvertisingPeer];
    NSLog(@"Started up advertising with display name %@", self.advertiser.myPeerID);
}

- (void)stopAdvertising
{
    [self.advertiser stopAdvertisingPeer];
    self.advertiser = nil;
}

- (void)restartAdvertising
{
    [self.advertiser stopAdvertisingPeer];
    [self.advertiser startAdvertisingPeer];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    // TODO: Need to make some kind of controller that decides whether or not to accept the invitation.
    NSLog(@"MCNearbyServiceAdvertiser - Received invitation from peer %@", peerID);

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
    NSLog(@"MCSessionDelegate - Received data from peer %@", peerID);
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received message %@", message);
    
    if (message) {
        [self.delegate didReceiveMessage:message];
    } else if ([message isEqualToString:MessagePayload.restart]) {
        [self restartAdvertising];
    }
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate didChangeState:state peer:peerID];
    });
}

// Boiler plate stuff.
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Did start receiving resource %@ from peer %@ with progress %@", resourceName, peerID, progress);
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"Did finish receiving resource %@ from peer %@ at URL %@ with error %@", resourceName, peerID, localURL, error);
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Did receive stream %@ with name %@ from peer %@", stream, streamName, peerID);
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
