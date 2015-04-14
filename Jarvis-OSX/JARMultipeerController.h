//
//  MultipeerClient.h
//  JarvisCentral
//
//  Created by Kyle Yoon on 3/20/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol MultipeerDelegate

- (void)didReceiveMessage:(NSString *)message;
- (void)didChangeState:(MCSessionState)state peer:(MCPeerID *)peer;

@end

@interface JARMultipeerController : NSObject

+ (instancetype)sharedInstance;
- (void)restartAdvertising;
@property id<MultipeerDelegate> delegate;
@property (readonly, nonatomic) MCSessionState currentState;
@property (readonly, strong, nonatomic) MCPeerID *currentPeer;

@end
