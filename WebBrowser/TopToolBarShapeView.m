//
//  TopToolBarShapeView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/12.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "TopToolBarShapeView.h"
#import "BrowserViewController.h"
#import "SearchViewController.h"

@interface TopToolBarShapeView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation TopToolBarShapeView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    
    return self;
}

- (void)initializeView{
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
        
        textField;
    });
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer
{
    return (CAShapeLayer *)self.layer;
}

- (void)setTopURLOrTitle:(NSString *)urlOrTitle{
    [self.textField setText:urlOrTitle];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    SearchViewController *searchVC = [SearchViewController new];
    searchVC.origTextFieldString = textField.text;
    [[[BrowserViewController sharedInstance] navigationController] pushViewController:searchVC animated:NO];
    return NO;
}


@end
