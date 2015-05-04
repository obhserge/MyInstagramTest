//
//  obhServerManager.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhServerManager.h"
#import "obhLoginViewController.h"
#import "obhAccessToken.h"

//Model
#import "obhUser.h"
#import "obhPost.h"
#import "obhComment.h"

//Category
#import "NSDictionary+UrlEncoding.h"

@interface obhServerManager ()

@property (strong, nonatomic) NSURLConnection* connection;
@property (strong, nonatomic) obhAccessToken* accessToken;

@end

@implementation obhServerManager

// инициализируем синглтон, который будет возвращать нам ServerManager
+ (obhServerManager*)sharedManager {
    
    static obhServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[obhServerManager alloc] init];
    });
    
    return manager;
}


- (void)authorizeUser:(void(^)(obhUser* user)) completion {
    
    // при вызове блока авторизации, инициализируем login view controller,
    // который возвращает нам токен
    
    obhLoginViewController* loginVC =
    [[obhLoginViewController alloc] initWithCompletionBlock:^(obhAccessToken *token) {
        self.accessToken = token;
        
        // если мы получили токен, тогда записываем его в NSUserDefaults
        // если токен уже есть, проверяем его, новее ли он, если да, то
        // записываем новый токен. После отправляем запрос на получении
        // информации о пользователе, передам в запрос токен
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        if (![defaults objectForKey:@"accessToken"]) {
            
            [defaults setObject:self.accessToken.token forKey:@"accessToken"];
            [defaults synchronize];
            
        } else {
            
            NSString* currentToken = [defaults objectForKey:@"accessToken"];
            
            if (![currentToken isEqualToString:self.accessToken.token]) {
                
                [defaults setObject:token forKey:@"accessToken"];
                [defaults synchronize];
                
            }
        }
            
        if (token) {
            [self getUser:@"self"
                onSuccess:^(obhUser *user) {
                    if (completion) {
                        completion(user);
                    }
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    if (completion) {
                        completion(Nil);
                    }
                }];
        }
        
        
        if (completion) {
            completion(nil);
        }
    }];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nav animated:YES completion:Nil];
    
}


- (void)postCode:(NSString*) code
       onSuccess:(void(^)(obhAccessToken *token)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure {
    
    // 2 пункт авторизации. instagram возвращает нам code, который мы обмениваем на token
    // отправляем POST запрос
    
    NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"fd9549572a0a400596776b00a687ee9a", @"client_id",
                               @"24661ba4e67c4f219abc282367318e4f", @"client_secret",
                               @"authorization_code", @"grant_type",
                               @"http://www.sergeernie.com", @"redirect_uri",
                               code, @"code", nil];
    
    NSString *paramString = [paramDict urlEncodedString];
    
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
    
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               
                               id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                               
                               if (jsonData && [NSJSONSerialization isValidJSONObject:jsonData]) {
                               
                                   obhAccessToken* token = [[obhAccessToken alloc] init];
                                   
                                   NSString *accesstoken = [jsonData objectForKey:@"access_token"];
                                   
                                   if(accesstoken) {
                                   
                                       token.token = accesstoken;
                                       success(token);
                                       
                                   }
                                   
                               } else {
                                   
                                   if (failure) {
                                       NSLog(@"failure!");
                                   }
                                   
                               }
                               
                               // handle response
                           }];

    
}

- (void)getUser:(NSString*) userID
      onSuccess:(void(^)(obhUser* user)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure {
    
    // GET запрос на получении информации о пользователе
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/"
                                                      "%@/?access_token=%@", userID, self.accessToken.token];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               
                               id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                               
                               NSDictionary* dictionaryWithData = [jsonData objectForKey:@"data"];
                               
                               if ([dictionaryWithData count] > 0) {
                                   
                                   obhUser* user = [[obhUser alloc] initWithServerResponse:dictionaryWithData];
                                   
                                   if (success) {
                                       success(user);
                                   }
                                   
                               } else {
                                   
                                   if (failure) {
                                       NSLog(@"failure!");
                                   }
                               }

                               // handle response
                           }];
    
}


- (void)getSelfFeedWithCount:(NSInteger) count
                       maxID:(NSString*) maxID
                       minID:(NSString*) minID
                   onSuccess:(void(^)(NSArray* posts)) success
                   onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure {
    
    // GET запрос на получении своего feed'a
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* token;
    
    if ([defaults objectForKey:@"accessToken"]) {
        token = [defaults objectForKey:@"accessToken"];
    }
    
    NSString *urlString = [[NSString alloc] init];
    
    if (maxID != Nil) {
        
        urlString =
        [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&max_id=%@&count=%ld", token, maxID, (long)count];
        
    } else if (minID != Nil) {
        
        urlString =
        [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&min_id=%@", token, minID];
        
    } else {
        urlString =
        [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=%ld", token, (long)count];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:60];
    
    [request setHTTPMethod:@"GET"];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               
                               NSDictionary * innerJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                               
                               NSDictionary* dictionaryWithData = [innerJson objectForKey:@"data"];
                               
                               //NSLog(@"dictionaryWithData = %@", [dictionaryWithData description]);
                               
                               NSMutableArray* objectsArray = [NSMutableArray array];
                               
                               for (NSDictionary* dict in dictionaryWithData) {
                                   obhPost* post = [[obhPost alloc] initWithServerResponse:dict];
                                   [objectsArray addObject:post];
                               }
                               
                               if (success) {
                                   success(objectsArray);
                               } else {
                                   if (failure) {
                                       NSLog(@"failure!");
                                   }
                               }
                               
                               // handle response
                           }];

    
}


- (void)postComment:(NSString*) text
            onMedia:(NSString*) mediaID
          onSuccess:(void(^)(id result)) success
          onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure {
    
    // POST запрос, на размещение комментария
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* token;
    
    if ([defaults objectForKey:@"accessToken"]) {
        token = [defaults objectForKey:@"accessToken"];
        NSLog(@"token = %@", token);
    }

    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/comments", mediaID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"access_token",
                               text, @"text", nil];
    
    
    NSString *paramString = [paramDict urlEncodedString];
    
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               
                               NSDictionary * innerJson = [NSJSONSerialization
                                                           JSONObjectWithData:data
                                                           options:kNilOptions
                                                           error:nil];
                               
                               NSLog(@"NSMutableDictionary sendAsynchronousRequest = %@", [innerJson description]);

                               if (success) {
                                   success(innerJson);
                               } else {
                                   if (failure) {
                                       NSLog(@"failure!");
                                   }
                               }
                               
                               // handle response
                           }];
    
}


- (void)getCommentsWithMediaID:(NSString*) mediaID
                     onSuccess:(void(^)(NSArray* comments)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode )) failure {
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* token;
    
    if ([defaults objectForKey:@"accessToken"]) {
        token = [defaults objectForKey:@"accessToken"];
    }
    
    NSString *urlString = [[NSString alloc] init];
    
    if (mediaID) {
        urlString =
        [NSString stringWithFormat:@"https://api.instagram.com/v1/media/%@/comments?access_token=%@", mediaID, token];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               
                               id innerJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                               
                               NSDictionary* dictionaryWithData = [innerJson objectForKey:@"data"];
                               
                               NSMutableArray* objectsArray = [NSMutableArray array];
                               
                               for (NSDictionary* dict in dictionaryWithData) {
                                   obhComment* comment = [[obhComment alloc] initWithDictionary:dict];
                                   [objectsArray addObject:comment];
                               }
                               
                               if (success) {
                                   success(objectsArray);
                               } else {
                                   if (failure) {
                                       NSLog(@"failure!");
                                   }
                               }
                               
                               // handle response
                           }];
    
}


@end
