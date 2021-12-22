//
//  GoogleService.m
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

#import "GoogleService.h"

#import "GTLPlus.h"
#import "GTLPlusPerson.h"
#import "UserSettingsProvider.h"
#import "GTMOAuth2Authentication.h"
#import "OpponentModel.h"

#pragma mark -

@implementation GoogleService

BOOL (^isPlusUser)(void) = ^{
    UserSettingsProvider *provider = [[UserSettingsProvider alloc] init];
    return [provider getIsUsingGooglePlus];
};

GTLServicePlus* (^getPlusService)(void) = ^{
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];

    plusService.retryEnabled = YES;

    [plusService setAuthorizer:[AuthenticationService authFromKeychain]];

    return plusService;
};

#pragma mark public methods

+ (void)loadUserProfile:(void (^)(GTLPlusPerson *))callback {
    if(isPlusUser() == YES) {
        [self loadGooglePlusUserProfile:callback];
    }
    else {
        [self loadGoogleUserProfile:callback];
    }
}

+ (void)loadUserFriends:(void (^)(NSArray *))callback {
    NSLog(@"loading friends...");
    GTLServicePlus *service = getPlusService();

    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                                          collection:kGTLPlusCollectionVisible];
    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket,
                            GTLPlusPeopleFeed *peopleFeed,
                            NSError *error) {
            if(error)
                [self logError:error
                     fromClass:NSStringFromClass([self class])
                    FromMethod:NSStringFromSelector(_cmd)];

            NSLog(@"loading friends...Done!");
            if(callback){
            
                NSMutableArray *friends = [[NSMutableArray alloc] init];
                
                for(GTLPlusPerson *person in peopleFeed.items){
                    
                    OpponentModel *opponent = [[OpponentModel alloc] initWithGooglePlusUser:person];
                    
                    [friends addObject:opponent];
                }
                
                callback(friends);
            }
        }];
}

#pragma mark private methods

+(void)loadGoogleUserProfile:(void (^)(GTLPlusPerson *))callback {
    NSLog(@"loading google profile...");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:UserInfoUrl]];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];

    fetcher.authorizer = [AuthenticationService authFromKeychain];

    [fetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        GTLPlusPerson *person = [[GTLPlusPerson  alloc] init];

        GTMOAuth2Authentication *auth = (GTMOAuth2Authentication *)fetcher.authorizer;
        // set default values
        person.DisplayName = auth.userEmail;

        if (error) {
            // failed; either an NSURLConnection error occurred, or the server returned a status value of at least 300
            // the NSError domain string for server status errors is kGTMHTTPFetcherStatusDomain

            [self logError:error
                 fromClass:NSStringFromClass([self class])
                FromMethod:NSStringFromSelector(_cmd)];
        } else {

            NSDictionary *data = [GTLJSONParser objectWithData:retrievedData error:nil];

            GTLPlusPersonImage *image = nil;

            NSDictionary *imageItem = data[@"image"];

            if(imageItem) {
                image = [[GTLPlusPersonImage alloc] init];
                image.url = imageItem[@"url"];
            }
            
            if(data[@"displayName"]) person.DisplayName = data[@"displayName"];
            person.identifier = auth.userID ?: data[@"id"];
            person.image = image;
            person.isPlusUser = data[@"isPlusUser"];
            person.nickname = data[@"nickname"];
        }

        NSLog(@"loading google profile...Done!");
        if(callback)
            callback(person);

    }];
}

+(void)loadGooglePlusUserProfile:(void (^)(GTLPlusPerson *))callback {
    NSLog(@"loading google plus profile...");
    GTLServicePlus *service = getPlusService();

    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];

    [service executeQuery:query
        completionHandler:^(GTLServiceTicket *ticket,
                            GTLPlusPerson *person,
                            NSError *error) {
            if(error)
                [self logError:error
                     fromClass:NSStringFromClass([self class])
                    FromMethod:NSStringFromSelector(_cmd)];

            NSLog(@"loading google plus profile...Done!");
            if(callback)
                callback(person);
        }];
}

@end