//
//  WXYZ_WeakScriptMessageHandlerDelegate.h
//  WXReader
//
//  Created by Andrew on 2020/7/14.
//  Copyright © 2020 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>

/*
 此类用于解决WKWebview无法释放问题
 **/

NS_ASSUME_NONNULL_BEGIN

@interface WXYZ_WeakScriptMessageHandlerDelegate : NSObject <WKScriptMessageHandler>
 
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

NS_ASSUME_NONNULL_END
