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

#endif /* WebViewHeader_h */
