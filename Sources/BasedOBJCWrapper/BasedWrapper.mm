//
//  BasedOBJC.m
//  
//
//  Created by Alexander van der Werff on 12/11/2022.
//

#import <Foundation/Foundation.h>
#import "BasedWrapper.h"
#import "Based.hpp"


@interface BasedWrapper ()

@end


@implementation BasedWrapper

+ (BasedClientID) basedClient {
    int clientId = Based__new_client();
    return clientId;
}

+ (void)deleteClient:(BasedClientID)clientId {
    Based__delete_client(clientId);
}

+ (void)connect:(BasedClientID)clientId withUrl:(NSString *)url {
    Based__connect_to_url(clientId, (char *)url.UTF8String);
}

+ (void)connect:(BasedClientID)clientId withCluster:(NSString *)cluster withOrg:(NSString *)org withProject:(NSString *)project withEnv:(NSString *)env withName:(NSString *)name withKey:(NSString *)key withOptionalKey:(BOOL) optionalKey {
    Based__connect(clientId, (char *)cluster.UTF8String, (char *)org.UTF8String, (char *)project.UTF8String, (char *)env.UTF8String, (char *)name.UTF8String, (char *)key.UTF8String, optionalKey);
}

+ (void)disconnect:(BasedClientID)clientId {
    Based__disconnect(clientId);
}

+ (void)auth:(BasedClientID)clientId withName:(NSString *)token andCallback:(void (*)(const char * _Nonnull))callback {
    Based__auth(clientId, (char *)token.UTF8String, callback);
}

+ (void)get:(BasedClientID)clientId withName:(NSString *)name withPayload:(NSString *)payload andCallback:(void (*)(const char * _Nonnull, const char * _Nonnull))callback {
    Based__get(clientId, (char *)name.UTF8String, (char *)payload.UTF8String, callback);
}

+ (void)function:(BasedClientID)clientId withName:(NSString *)name withPayload:(NSString *)payload andCallback:(void (*)(const char * _Nonnull, const char * _Nonnull))callback {
    Based__function(clientId, (char *)name.UTF8String, (char *)payload.UTF8String, callback);
}

+ (NSString *)service:(BasedClientID)clientId withCluster:(NSString *)cluster withOrg:(NSString *)org withProject:(NSString *)project withEnv:(NSString *)env withName:(NSString *)name withKey:(NSString *)key withOptionalKey:(BOOL)optionalKey {
    return [NSString stringWithUTF8String: Based__get_service(clientId, (char *)cluster.UTF8String, (char *)org.UTF8String, (char *)project.UTF8String, (char *)env.UTF8String, (char *)name.UTF8String, (char *)key.UTF8String, optionalKey)];
}

+ (int)observe:(BasedClientID)clientId withName:(NSString *)name withPayload:(NSString *)payload andCallback:(void (*)(const char * _Nonnull, uint64_t, const char * _Nonnull))callback {
    return Based__observe(clientId, (char *)name.UTF8String, (char *)payload.UTF8String, callback);
}

+ (void)unobserve:(BasedClientID)clientId andSubId:(int)subId {
    Based__unobserve(clientId, subId);
}

@end
