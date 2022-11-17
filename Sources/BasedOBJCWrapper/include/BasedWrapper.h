//
//  Header.h
//  
//
//  Created by Alexander van der Werff on 12/11/2022.
//

#pragma once

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef int BasedClientID;

@interface BasedWrapper: NSObject

+ (int)basedClient;

+ (void)deleteClient: (BasedClientID)clientId;

+ (void)connect: (BasedClientID)clientId withUrl: (NSString *)url
NS_SWIFT_NAME(connect(clientId:url:));

+ (void)connect: (BasedClientID)clientId withCluster: (NSString *)cluster withOrg: (NSString *)org withProject: (NSString *)project withEnv: (NSString *)env withName: (NSString *) name withKey: (NSString *) key withOptionalKey: (BOOL) optionalKey
NS_SWIFT_NAME(connect(clientId:cluster:org:project:env:name:key:optionalKey:));

+ (void)disconnect: (BasedClientID)clientId
NS_SWIFT_NAME(disconnect(clientId:));

+ (void)auth: (BasedClientID)clientId withName:(NSString *)token andCallback: (void (*)(const char *))callback
NS_SWIFT_NAME(auth(clientId:token:callback:));

+ (void)get: (BasedClientID)clientId withName: (NSString *)name withPayload: (NSString *)payload andCallback: (void (*)(const char *, const char *))callback
NS_SWIFT_NAME(get(clientId:name:payload:callback:));

+ (void)function: (BasedClientID)clientId withName: (NSString *)name withPayload: (NSString *)payload andCallback: (void (*)(const char *, const char *))callback
NS_SWIFT_NAME(function(clientId:name:payload:callback:));

+ (NSString *)service: (BasedClientID)clientId withCluster: (NSString *)cluster withOrg: (NSString *)org withProject: (NSString *)project withEnv: (NSString *)env withName: (NSString *) name withKey: (NSString *) key withOptionalKey: (BOOL) optionalKey
NS_SWIFT_NAME(service(clientId:cluster:org:project:env:name:key:optionalKey:));

+ (int)observe: (BasedClientID)clientId withName: (NSString *)name withPayload: (NSString *) payload andCallback: (void (*)(const char *, uint64_t, const char *)) callback
NS_SWIFT_NAME(observe(clientId:name:payload:callback:));

+ (void)unobserve: (BasedClientID)clientId andSubId: (int)subId
NS_SWIFT_NAME(unobserve(clientId:subscriptionId:));


+ (void)auth2:(BasedClientID)clientId withName:(NSString *)token completion:(void (^)(NSString*))completion;

@end

NS_ASSUME_NONNULL_END
