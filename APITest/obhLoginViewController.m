//
//  obhLoginViewController.m
//  InstagramTest
//
//  Created by admin on 02.05.15.
//  Copyright (c) 2015 sergeernie. All rights reserved.
//

#import "obhLoginViewController.h"
#import "obhAccessToken.h"
#import "obhServerManager.h"

@interface obhLoginViewController () <UIWebViewDelegate>

@property (copy, nonatomic) obhLoginCpmpletionBlock completionBlock;
@property (weak, nonatomic) UIWebView* webView;

@end

@implementation obhLoginViewController

- (id)initWithCompletionBlock:(obhLoginCpmpletionBlock) completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    
	UIWebView* webView = [[UIWebView alloc] initWithFrame:rect];
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webView];
    
    self.webView = webView;
    
    self.navigationItem.title = @"Login";
    
    // добавляем кнопку cancel
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:self
                                                                          action:@selector(actionCancel:)];
    
    [self.navigationItem setRightBarButtonItem:item animated:NO];
    
    // scope для лайков, комментариев
    NSString *scopeStr = @"scope=likes+comments+relationships";
    
    NSString* urlString = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?"
                           "client_id=fd9549572a0a400596776b00a687ee9a&"
                           "redirect_uri=http://www.sergeernie.com&"
                           "response_type=code&%@", scopeStr];
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    //назначаем делегата
    webView.delegate = self;
    
    //старуем запрос
    [webView loadRequest:request];
    
}

- (void)dealloc {
    self.webView.delegate  = Nil;
}


#pragma mark - Actions

- (void)actionCancel:(UIBarButtonItem*) sender {
    
    if (self.completionBlock) {
        self.completionBlock(Nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // если в ответе сервера присутвствует выражение "?code=",
    // извлекаем code из строки
    
    if ([[[request URL] description] rangeOfString:@"?code="].location != NSNotFound) {
        
        NSString* query = [[request URL] description];
        
        NSArray* array = [query componentsSeparatedByString:@"="];
        
        NSString* code = nil;
        
        if ([array count] > 1) {
            
            code = [array lastObject];
            
            [[obhServerManager sharedManager]
             postCode:code
             onSuccess:^(obhAccessToken* token) {
                 
                 if (token) {
                     self.completionBlock(token);
                 }
             }
             onFailure:^(NSError *error, NSInteger statusCode) {
                 NSLog(@"Failure");
             }];
        }        
        
        self.webView.delegate = Nil;
        
        [self dismissViewControllerAnimated:YES completion:Nil];
        
        return NO;
        
    }
    
    return YES;
}
@end
