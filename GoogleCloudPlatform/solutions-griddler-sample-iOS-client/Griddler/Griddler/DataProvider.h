//
//  dataProvider.h
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

#import <Foundation/Foundation.h>

#import "GTLGriddlerInvitation.h"
#import "GTLGriddlerPlayer.h"
#import "GTLServiceGriddler.h"
#import "GTLQueryGriddler.h"
#import "GTMOAuth2Authentication.h"
#import "GameModel.h"

/**
 * The purpose of this interface is to expose functionality around
 * communicating with the Griddler App Engine Cloud Endpoints
 */
@interface DataProvider : NSObject

extern const int MAX_RETRIES;

//Registration methods

///Register the player
- (void)registerPlayer:(void(^)(GTLGriddlerPlayer *))block;

///Register the player along with their Google+ Id
- (void)registerPlayerWithPlusId:(NSString*)plusId
                           block:(void(^)(GTLGriddlerPlayer *))block;

///Register the player's device
- (void)registerDevice:(NSString *)deviceId
                 block:(void(^)(GTLObject *))block;

///Unregister the player's device
- (void)unRegisterDevice:(NSString *)deviceId
                   block:(void(^)(GTLObject *))block;

///Assign the player's Google+ Id to their player record
- (void)assignGooglePlusId:(NSString*)plusId
                     block:(void(^)(GTLObject *))block;


//get player methods

///Get the player's multiplayer record
- (void)getPlayerRecord:(void(^)(GTLGriddlerPlayer *))block;

///Get all of the active players that are registered
- (void)getPlayers:(void(^)(NSArray/* of OpponentModel*/ *))block;


// game methods

///Start a new single player game based upon the level
- (void)startNewSinglePlayerGame:(NSInteger)boardLevel
                           block:(void(^)(GameModel *))block;

///Get an existing game
- (void)getGame:(NSNumber*)gameId
          block:(void(^)(GameModel *))block;

///Submit the player's answers for a specific game
- (void)submitAnswers:(NSNumber*)gameId
              answers:(GTLGriddlerGamePlay *)gamePlay
                block:(void(^)(GTLObject *))block;

//invitation methods

///Send an invitation to a player
- (void)sendInvitation:(NSInteger)boardLevel
              playerId:(NSNumber*)playerId
                 block:(void(^)(GTLGriddlerInvitation *))block;

///Send an invitation to a Google+ player
- (void)sendInvitation:(NSInteger)boardLevel
              plusId:(NSString*)plusId
                 block:(void(^)(GTLGriddlerInvitation *))block;

///Accept an invitation
- (void)acceptInvitation:(NSNumber*)gameId
            invitationId:(NSNumber*)invitationId
                   block:(void(^)(GTLObject *))block;

///Decline an invitation
- (void)declineInvitation:(NSNumber*)gameId
             invitationId:(NSNumber*)invitationId
                    block:(void(^)(GTLObject *))block;

///Determine if an invitation was accepted, declined, or not responded
- (void)wasInvitationAccepted:(NSNumber*)gameId
                 invitationId:(NSNumber*)invitationId
                        block:(void(^)(GTLGriddlerInvitation *))block;

///Cancel an invitation
- (void)cancelInvitation:(NSNumber*)gameId
             invitationId:(NSNumber*)invitationId
                    block:(void(^)(GTLObject *))block;


@end
