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

- (void)displayState:(MCSessionState)state peer:(MCPeerID *)peer;
//- (void)displayResponse:(NSString *)response;

@end

@interface MultipeerClient : NSObject

@property (weak) id<MultipeerDelegate> delegate;

+ (instancetype)sharedInstance;

@end
