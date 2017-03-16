//
//  WebViewHeader.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#ifndef WebViewHeader_h
#define WebViewHeader_h

#define UIWEBVIEW @"UIWebView"
#define DOCUMENT_VIEW @"_documentView"  //_documentView<UIWebBrowserView>
#define DOCUMENT_VIEW__PROTO (id (*)(id, SEL))
#define GOT_WEB_VIEW @"_webView"    //_documentView - _webView<WebView>
#define MAIN_FRAME_URL__PROTO (id (*)(id, SEL))
#define MAIN_FRAME_URL @"mainFrameURL" //_documentView - _webView - mainFrameURL

#define DRAW_IN_WEB_THREAD @"_setDrawInWebThread" //_setDrawInWebThread
#define DRAW_IN_WEB_THREAD__PROTO (void (*)(id, SEL, BOOL))
#define DRAW_CHECKERED_PATTERN @"_setDrawsCheckeredPattern" //_setDrawsCheckeredPattern
#define DRAW_CHECKERED_PATTERN__PROTO (void (*)(id, SEL, BOOL))

#define MAIN_FRAME_TITLE @"mainFrameTitle" //_documentView - _webView - mainFrameTitle
#define MAIN_FRAME_TITLE__PROTO (id (*)(id, SEL))

#define WEB_GOT_TITLE @"webView:didReceiveTitle:forFrame:" //webView:didReceiveTitle:forFrame:

#define MAIN_FRAME @"mainFrame" //_documentView - _webView - mainFrame
#define MAIN_FRAME__PROTO (id (*)(id, SEL))


#define WEB_NEW_WINDOW @"webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:" //webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:
#define WEB_ACTION_NAVIGATION @"webView:decidePolicyForNavigationAction:request:frame:decisionListener:" //webView:decidePolicyForNavigationAction:request:frame:decisionListener:
#define WEB_ACTION_NAVI_TYPE_KEY @"WebActionNavigationTypeKey" //WebActionNavigationTypeKey 用于页面跳转时使用


//main frame load
#define MAIN_FRAME_COMMIT_LOAD @"webViewMainFrameDidCommitLoad:" //webViewMainFrameDidCommitLoad:
#define MAIN_FRAME_FINISIH_LOAD @"webViewMainFrameDidFinishLoad:" //webViewMainFrameDidFinishLoad:
#define MAIN_FRAME_FAILED_LOAD @"webViewMainFrameDidFailLoad:withError:" //webViewMainFrameDidFailLoad:withError:

#define FRAME_PROVISIONALLOAD @"webView:didStartProvisionalLoadForFrame:"


#define BACK_FORWARD_LIST @"backForwardList" //_documentView - _webView - backForwardList<WebBackForwardList>
#define BACK_FORWARD_LIST__PROTO (id (*)(id, SEL)) 

#define BACK_LIST_COUNT @"backListCount"
#define BACK_LIST_COUNT__PROTO (int (*)(id, SEL))
#define BACK_LIST_WITH_LIMIT @"backListWithLimit:"
#define BACK_LIST_WITH_LIMIT__PROTO (id (*)(id, SEL, int))

#define FORWARD_LIST_COUNT @"forwardListCount"
#define FORWARD_LIST_COUNT__PROTO (int (*)(id, SEL))
#define FORWARD_LIST_WITH_LIMIT @"forwardListWithLimit:"
#define FORWARD_LIST_WITH_LIMIT__PROTO (id (*)(id, SEL, int))

#define CURRENT_ITEM @"currentItem"
#define CURRENT_ITEM__PROTO (id (*)(id, SEL))

#define URL_STRING @"URLString"
#define URL_STRING__PROTO (id (*)(id, SEL))

#define URL_TITLE @"title"
#define URL_TITLE__PROTO (id (*)(id, SEL))

#endif /* WebViewHeader_h */
