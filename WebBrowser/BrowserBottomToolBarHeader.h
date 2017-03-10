//
//  BrowserBottomToolBarHeader.h
//  WebBrowser
//
//  Created by 钟武 on 2016/11/6.
//  Copyright © 2016年 钟武. All rights reserved.
//

#ifndef BrowserBottomToolBarHeader_h
#define BrowserBottomToolBarHeader_h

typedef NS_ENUM(NSInteger, BottomToolBarButtonTag) {
    BottomToolBarBackButtonTag,
    BottomToolBarForwardButtonTag,
    BottomToolBarRefreshOrStopButtonTag,
    BottomToolBarMultiWindowButtonTag,
    BottomToolBarMoreButtonTag,
    BottomToolBarFlexibleButtonTag,
    
    //用于准确识别刷新或停止
    BottomToolBarRefreshButtonTag,
    BottomToolBarStopButtonTag,
};

#define TOOLBAR_BUTTON_BACK_STRING @"toolbar_goback_normal"
#define TOOLBAR_BUTTON_BACK_HILIGHT_STRING @"toolbar_goback_highlighted"
#define TOOLBAR_BUTTON_FORWARD_STRING @"toolbar_goforward_normal"
#define TOOLBAR_BUTTON_FORWARD_HILIGHT_STRING @"toolbar_forward_highlighted"
#define TOOLBAR_BUTTON_REFRESH_STRING @"menu_refresh_normal"
#define TOOLBAR_BUTTON_STOP_STRING @"toolbar_stop_normal"
#define TOOLBAR_BUTTON_MORE_STRING @"toolbar_more_normal"
#define TOOLBAR_BUTTON_MULTIWINDOW_STRING @"toolbar_multiwindow_normal"

@protocol BrowserBottomToolBarButtonClickedDelegate <NSObject>

@optional
- (void)browserBottomToolBarButtonClickedWithTag:(BottomToolBarButtonTag)tag;

@end

#endif /* BrowserBottomToolBarHeader_h */
