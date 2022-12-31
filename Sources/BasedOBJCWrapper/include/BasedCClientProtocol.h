//
//  Header.h
//  
//
//  Created by Alexander van der Werff on 26/12/2022.
//

#ifndef BasedCClientProtocol_h
#define BasedCClientProtocol_h

NS_ASSUME_NONNULL_BEGIN

typedef int BasedClientID;

@protocol BasedCClientProtocol

- (int)create;

- (void)delete: (BasedClientID)clientId;

- (void)connect: (BasedClientID)clientId withUrl: (NSString *)url
NS_SWIFT_NAME(connect(clientId:url:));

- (void)connect: (BasedClientID)clientId withCluster: (NSString *)cluster withOrg: (NSString *)org withProject: (NSString *)project withEnv: (NSString *)env withName: (NSString *) name withKey: (NSString *) key withOptionalKey: (BOOL) optionalKey
NS_SWIFT_NAME(connect(clientId:cluster:org:project:env:name:key:optionalKey:));

- (void)disconnect: (BasedClientID)clientId
NS_SWIFT_NAME(disconnect(clientId:));

- (void)auth: (BasedClientID)clientId withName:(NSString *)token andCallback: (void (*)(const char *))callback
NS_SWIFT_NAME(auth(clientId:token:callback:));

- (int)get: (BasedClientID)clientId withName: (NSString *)name withPayload: (NSString *)payload andCallback: (void (*)(const char *, const char *, int))callback
NS_SWIFT_NAME(get(clientId:name:payload:callback:));

- (int)function: (BasedClientID)clientId withName: (NSString *)name withPayload: (NSString *)payload andCallback: (void (*)(const char *, const char *, int))callback
NS_SWIFT_NAME(function(clientId:name:payload:callback:));

- (NSString *)service: (BasedClientID)clientId withCluster: (NSString *)cluster withOrg: (NSString *)org withProject: (NSString *)project withEnv: (NSString *)env withName: (NSString *) name withKey: (NSString *) key withOptionalKey: (BOOL) optionalKey
NS_SWIFT_NAME(service(clientId:cluster:org:project:env:name:key:optionalKey:));

- (int)observe: (BasedClientID)clientId withName: (NSString *)name withPayload: (NSString *) payload andCallback: (void (*)(const char *, uint64_t, const char *, int)) callback
NS_SWIFT_NAME(observe(clientId:name:payload:callback:));

- (void)unobserve: (BasedClientID)clientId andSubId: (int)subId
NS_SWIFT_NAME(unobserve(clientId:subscriptionId:));

@end

#endif /* BasedCClientProtocol_h */

NS_ASSUME_NONNULL_END
