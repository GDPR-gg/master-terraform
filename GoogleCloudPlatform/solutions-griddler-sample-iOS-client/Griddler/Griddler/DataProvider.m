//
//  dataProvider.m
//  Griddler
//
//  Copyright 2013 Google Inc. All Rights Reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "DataProvider.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "authenticationService.h"
#import "enumerations.m"
#import "GameModel.h"
#import "OpponentModel.h"
#include "GPPSignIn.h"
#include "GTLPlusConstants.h"
#import "GTLGriddlerGamePlayStatus.h"
#import "GTLGriddlerPlayer.h"
#import "GTLGriddlerGame.h"
#import "GTLGriddlerInvitation.h"
#import "GTLGriddlerPlayerCollection.h"
#import <UIKit/UIKit.h>
#import "OpenUDID.h"

@implementation DataProvider

const int MAX_RETRIES = 3;

+ (GTLServiceGriddler *)createService {

    GTLServiceGriddler *service = [[GTLServiceGriddler alloc] init];
    service.rpcURL = [NSURL URLWithString:kGriddlerServiceUrl];
    
    GTMOAuth2Authentication *auth = [AuthenticationService authFromKeychain];

    [auth setAuthorizationTokenKey:@"id_token"];
    [[service fetcherService] setAuthorizer:auth];

    return service;
}

- (NSString *)getDeviceID {
    NSString *deviceIdentifier = @"";
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        // pre-iOS6 Devices
        deviceIdentifier = [OpenUDID value];
    }
    return deviceIdentifier;
}

- (void)registerPlayer:(void(^)(GTLGriddlerPlayer *))block {
    NSLog(@"registerPlayer....");
    GTLServiceGriddler *service = [DataProvider createService];

    GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointInsertWithGooglePlusId:@""];
    // GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointRegisterPlayer];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"registerPlayer....Done!");
        if(block)
            block((GTLGriddlerPlayer*)results);

    }];
}

- (void)registerPlayerWithPlusId:(NSString*)plusId
                           block:(void(^)(GTLGriddlerPlayer *))block{
    
    NSLog(@"registerPlayer with plus id....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointInsertWithGooglePlusId:plusId];

    // GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointRegisterPlayerWithPlusIdWithPlusId:plusId];
    
    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"registerPlayer with plus id....Done!");
        if(block)
            block((GTLGriddlerPlayer*)results);
        
    }];
}

- (void)assignGooglePlusId:(NSString*)plusId
                     block:(void(^)(GTLObject *))block {
    NSLog(@"assignGooglePlusId....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointAssignPlayerPlusIdWithGooglePlusId:plusId];
    
    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"assignGooglePlusId....Done!");
        if(block)
            block((GTLObject*)results);
        
    }];
}


- (void)getPlayerRecord:(void(^)(GTLGriddlerPlayer *))block {
    NSLog(@"getPlayerRecord....");
    // Get (single record)
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointGet];
    
    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"getPlayerRecord....Done!");
        if(block)
            block((GTLGriddlerPlayer*)results);
        
    }];
}

- (void)getPlayers:(void(^)(NSArray *))block {
    NSLog(@"getPlayers....");
    
    // list (multiple)
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointList];
    
    /*
        This endpoint method was intentionally simplified for a small number
        of opponents. If large lists are expected to be returned paging
        should be implemented.
     */
    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"getPlayers....Done!");
        if(block){
            
            NSMutableArray *opponentList = [[NSMutableArray alloc] init];
            GTLGriddlerPlayerCollection *playerList = (GTLGriddlerPlayerCollection*)results;
            
            for (GTLGriddlerPlayer *player in playerList.items) {
                OpponentModel *opponent = [[OpponentModel alloc] initWithGriddlerPlayer:player];
                
                [opponentList addObject:opponent];
            }
            
            block(opponentList);
        }
    }];
}

- (void)startNewSinglePlayerGame:(NSInteger)boardLevel
                           block:(void(^)(GameModel *))block {
    NSLog(@"startNewSinglePlayerGame....");
    // Game endpoint
    
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointStartSinglePlayerGameWithBoardLevel:boardLevel];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"startNewSinglePlayerGame....Done!");
        if(block){
            
            GTLGriddlerGame *game = (GTLGriddlerGame*)results;
            
            GameModel *model = [[GameModel alloc] init:game.identifier boardDetail:game.board playerList:game.gamePlays];
            
            block(model);
            
        }
    }];

}

- (void)getGame:(NSNumber*)gameId
          block:(void(^)(GameModel *))block {
    NSLog(@"getGame....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointGetGameWithIdentifier:[gameId longLongValue]];
    
    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"getGame....Done!");
        if(block){
            
            GTLGriddlerGame *gameResult = (GTLGriddlerGame*)results;
            
            GameModel *model = [[GameModel alloc] init:gameResult.identifier boardDetail:gameResult.board playerList:gameResult.gamePlays];
            
            block(model);
            
        }
    }];
    
}

- (void)submitAnswers:(NSNumber*)gameId
              answers:(GTLGriddlerGamePlayStatus *)gamePlay
                block:(void(^)(GTLObject *))block {
    NSLog(@"submitAnswers....");
    
    
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointSubmitAnswersWithObject:gamePlay
                                                    identifier:[gameId
                                                    longLongValue]];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"submitAnswers....Done!");
        if(block)
            block((GTLObject*)results);
        
    }];
}

- (void)registerDevice:(NSString *)deviceId
                 block:(void(^)(GTLObject *))block{
    NSLog(@"registerDevice....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointRegisterDeviceWithDeviceId:deviceId
                                                                                              deviceType:iOS];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"registerDevice....Done!");
        if(block)
            block((GTLObject*)results);
        
    }];
}

- (void)unRegisterDevice:(NSString *)deviceId
                   block:(void(^)(GTLObject *))block {
    NSLog(@"unRegisterDevice....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForPlayerEndpointUnRegisterDeviceWithDeviceId:deviceId];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"unRegisterDevice....Done!");
        if(block)
            block((GTLObject*)results);
        
    }];
}

- (void)sendInvitation:(NSInteger)boardLevel
              playerId:(NSNumber*)playerId
                 block:(void(^)(GTLGriddlerInvitation *))block {
    NSLog(@"sendInvitation:playerId....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointStartMultiplayerGameWithBoardLevel:boardLevel
                                                                                                  inviteeId:[playerId longLongValue]];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"sendInvitation:playerId....Done!");
        if(block)
            block((GTLGriddlerInvitation*)results);
        
    }];
}

- (void)sendInvitation:(NSInteger)boardLevel
                plusId:(NSString*)plusId
                 block:(void(^)(GTLGriddlerInvitation *))block{
    NSLog(@"sendInvitation:plusId....");
    GTLServiceGriddler *service = [DataProvider createService];
    plusId = @"103480441431287402224";
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointStartMultiplayerGameByGooglePlusIdWithBoardLevel:boardLevel
                                                                                                            inviteeGooglePlusId:plusId];

    
    [self executeEndpointWithService:service query:query attemptNumber:1 attemptRetryOnDataMissing:NO block:^(GTLObject *results) {
        NSLog(@"sendInvitation:plusId....Done!");
        if(block)
            block((GTLGriddlerInvitation*)results);
        
    }];

}

- (void)acceptInvitation:(NSNumber*)gameId
            invitationId:(NSNumber*)invitationId
                   block:(void(^)(GTLObject *))block {
    NSLog(@"acceptInvitation:invitationId....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointAcceptInvitationWithGameId:[gameId  longLongValue]
                                                                                            invitationId:[invitationId longLongValue]];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"acceptInvitation:invitationId....Done!");
        if(block)
            block((GTLObject*)results);
        
    }];

}

- (void)declineInvitation:(NSNumber*)gameId
             invitationId:(NSNumber*)invitationId
                    block:(void(^)(GTLObject *))block {
    NSLog(@"declineInvitation:invitationId....");

    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointDeclineInvitationWithGameId:[gameId longLongValue]
                                                                                             invitationId:[invitationId longLongValue]];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"declineInvitation:invitationId....Done!");
        if(block)
            block((GTLObject*)results);
        
    }];
}


- (void)wasInvitationAccepted:(NSNumber*)gameId
                 invitationId:(NSNumber*)invitationId
                        block:(void(^)(GTLGriddlerInvitation *))block {
    NSLog(@"wasInvitationAccepted:invitationId....");

    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointGetInvitationStatusWithGameId:[gameId longLongValue]
                                                                                                 invitationId:[invitationId longLongValue]];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"wasInvitationAccepted:invitationId....Done!");
        if(block)
            block((GTLGriddlerInvitation*)results);
        
    }];

}

- (void)cancelInvitation:(NSNumber*)gameId
            invitationId:(NSNumber*)invitationId
                   block:(void(^)(GTLObject *))block {
    NSLog(@"cancelInvitation:invitationId....");
    GTLServiceGriddler *service = [DataProvider createService];
    GTLQueryGriddler *query = [GTLQueryGriddler queryForGameEndpointCancelInvitationWithGameId:[gameId longLongValue]
                                                                                            invitationId:[invitationId longLongValue]];

    [self executeEndpointWithService:service query:query attemptNumber:1 block:^(GTLObject *results) {
        NSLog(@"cancelInvitation:invitationId....Done!");
        if(block)
            block((GTLObject*)results);
        
    }];
}

-(void)executeEndpointWithService:(GTLServiceGriddler*)service
                            query:(GTLQueryGriddler*)query
                    attemptNumber:(int)attemptNumber
        attemptRetryOnDataMissing:(BOOL)attemptRetry
                            block:(void(^)(GTLObject *))block{
    
    if(attemptNumber > MAX_RETRIES){
        if(block)
            block(nil);
        
        return;
    }
    
    [service executeQuery: query completionHandler:^(GTLServiceTicket *ticket,GTLObject *object, NSError *error) {
        
        
        if(error){
            [self logError:error
                 fromClass:NSStringFromClass([self class])
                FromMethod:NSStringFromSelector(_cmd)];
        }
        
        // Return an object for successful 204 (void response)
        if (error == nil && object == nil) {
            object = (GTLObject *)[NSNumber numberWithBool:YES];
        }
        
        if(block)
            block(object);

    }];

    
}

-(void)executeEndpointWithService:(GTLServiceGriddler*)service
                            query:(GTLQueryGriddler*)query
                    attemptNumber:(int)attemptNumber
                            block:(void(^)(GTLObject *))block{
    
    [self executeEndpointWithService:service
                               query:query
                       attemptNumber:attemptNumber
           attemptRetryOnDataMissing:YES
                               block:block];
    
}


@end
