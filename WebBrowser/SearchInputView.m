//
//  SearchInputView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "SearchInputView.h"
#import "HTTPClient+SearchSug.h"
#import "BaiduSugResponseModel.h"

@interface SearchInputView () <UITextFieldDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *bdRecoTask;

@end

@implementation SearchInputView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonUIInit];
    }
    return self;
}

- (void)commonUIInit{
    self.textField = ({
        UITextField *textField = [[UITextField alloc] initWithFrame:self.bounds];
        [self addSubview:textField];
        
        textField.textAlignment = NSTextAlignmentCenter;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.delegate = self;
        textField.placeholder = TEXT_FIELD_PLACEHOLDER;
        textField.returnKeyType = UIReturnKeySearch;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enablesReturnKeyAutomatically = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:nil];
        
        textField;
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)handleTextFieldTextChanged:(NSNotification *)notification{
    if ([[notification object] isKindOfClass:[UITextField class]] && (UITextField *)[notification object] == _textField) {
        if ([_textField.text length] > 0) {
            if (self.bdRecoTask && (self.bdRecoTask.state == NSURLSessionTaskStateRunning || self.bdRecoTask.state == NSURLSessionTaskStateSuspended)) {
                [self.bdRecoTask cancel];
            }
            self.bdRecoTask = [[HTTPClient sharedInstance] getSugWithKeyword:_textField.text success:^(NSURLSessionDataTask *task, BaseResponseModel *model){
                BaiduSugResponseModel *bdModel = (BaiduSugResponseModel *)model;
                
            }fail:^(NSURLSessionDataTask *task, BaseResponseModel *model){
                ;
            }];
        }
    }
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
