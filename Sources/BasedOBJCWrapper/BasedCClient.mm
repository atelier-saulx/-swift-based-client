//
//  BasedOBJC.m
//  
//
//  Created by Alexander van der Werff on 12/11/2022.
//

#import <Foundation/Foundation.h>
#import "BasedCClient.h"
#import <based/based.h>

@interface BasedCClient ()
@end

@implementation BasedCClient

- (BasedClientID)create:(BOOL)enableTls {
    return Based__new_client(enableTls);
}

- (void)delete:(BasedClientID)clientId {
    Based__delete_client(clientId);
}

- (void)connect:(BasedClientID)clientId withUrl:(NSString *)url {
    Based__connect_to_url(clientId, (char *)url.UTF8String);
}

- (void)connect:(BasedClientID)clientId withCluster:(NSString *)cluster withOrg:(NSString *)org withProject:(NSString *)project withEnv:(NSString *)env withName:(NSString *)name withKey:(NSString *)key withOptionalKey:(BOOL)optionalKey withHost:(NSString *)host withDiscoveryUrl:(NSString *)discovery_url {
    Based__connect(clientId, (char *)cluster.UTF8String, (char *)org.UTF8String, (char *)project.UTF8String, (char *)env.UTF8String, (char *)name.UTF8String, (char *)key.UTF8String, optionalKey, (char *)host.UTF8String, (char *)discovery_url.UTF8String);
}

- (void)disconnect:(BasedClientID)clientId {
    Based__disconnect(clientId);
}

- (void)auth:(BasedClientID)clientId withName:(NSString *)token andCallback:(void (*)(const char * _Nonnull))callback {
    Based__set_auth_state(clientId, (char *)token.UTF8String, callback);
}

- (int)get:(BasedClientID)clientId withName:(NSString *)name withPayload:(NSString *)payload andCallback:(void (*)(const char * _Nonnull, const char * _Nonnull, int))callback {
    return Based__get(clientId, (char *)name.UTF8String, (char *)payload.UTF8String, callback);
}

- (int)function:(BasedClientID)clientId withName:(NSString *)name withPayload:(NSString *)payload andCallback:(void (*)(const char * _Nonnull, const char * _Nonnull, int))callback {
    return Based__call(clientId, (char *)name.UTF8String, (char *)payload.UTF8String, callback);
}

- (NSString *)service:(BasedClientID)clientId withCluster:(NSString *)cluster withOrg:(NSString *)org withProject:(NSString *)project withEnv:(NSString *)env withName:(NSString *)name withKey:(NSString *)key withOptionalKey:(BOOL)optionalKey withHtml:(BOOL)html {
    return [NSString stringWithUTF8String: Based__get_service(clientId, (char *)cluster.UTF8String, (char *)org.UTF8String, (char *)project.UTF8String, (char *)env.UTF8String, (char *)name.UTF8String, (char *)key.UTF8String, optionalKey, html)];
}

- (int)observe:(BasedClientID)clientId withName:(NSString *)name withPayload:(NSString *)payload andCallback:(void (*)(const char * _Nonnull, uint64_t, const char * _Nonnull, int))callback {
    return Based__observe(clientId, (char *)name.UTF8String, (char *)payload.UTF8String, callback);
}

- (void)unobserve:(BasedClientID)clientId andSubId:(int)subId {
    Based__unobserve(clientId, subId);
}

@end
