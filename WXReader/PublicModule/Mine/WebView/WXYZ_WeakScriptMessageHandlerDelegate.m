//
//  WXYZ_WeakScriptMessageHandlerDelegate.m
//  WXReader
//
//  Created by Andrew on 2020/7/14.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import "WXYZ_WeakScriptMessageHandlerDelegate.h"

@implementation WXYZ_WeakScriptMessageHandlerDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    if (self = [super init]) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
