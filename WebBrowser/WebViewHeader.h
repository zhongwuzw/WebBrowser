//
//  WebViewHeader.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#ifndef WebViewHeader_h
#define WebViewHeader_h

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

#endif /* WebViewHeader_h */
