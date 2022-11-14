//
//  BasedOBJC.m
//  
//
//  Created by Alexander van der Werff on 12/11/2022.
//

#import <Foundation/Foundation.h>
#import "Based.h"
#import "Based.hpp"


@interface Based ()

@end


@implementation Based

+ (NSInteger)basedClient {
    int clientId = Based__new_client();
    return clientId;
}

@end
