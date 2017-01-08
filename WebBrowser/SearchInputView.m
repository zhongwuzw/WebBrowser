//
//  SearchInputView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "SearchInputView.h"
#import "BrowserViewController.h"

typedef enum : NSUInteger {
    SearchButtonBottomButton,
    SearchButtonTopCacelButton
} SearchButton;

typedef enum : NSUInteger {
    QuickInputButtonStateFirst,
    QuickInputButtonStateSecond,
} QuickInputButtonState;

#define CACEL_TITLE @"取消"

@interface SearchInputView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingLayoutContraint;
@property (assign, nonatomic) NSInteger lastThreshold;
@property (assign, nonatomic) QuickInputButtonState quickState;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *bottomButtonCollection;

@end

@implementation SearchInputView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self commonUIInit];
    
    self.quickState = QuickInputButtonStateFirst;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)commonUIInit{
    self.textField.delegate = self;
    
    [self.slider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderFirstTouch:) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(sliderStop:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
}

- (void)sliderFirstTouch:(CharacterSelectView *)slider{
    self.leadingLayoutConstraint.constant = -(self.width - slider.width)/2 + 10;
    self.trailingLayoutContraint.constant = -(self.width - slider.width)/2 + 10;
    [UIView animateWithDuration:.3 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished){
        
    }];
}

- (void)sliderStop:(CharacterSelectView *)slider{
    [self.slider setValue:0.5 animated:NO];
    self.lastThreshold = 0;
    self.leadingLayoutConstraint.constant = 0;
    self.trailingLayoutContraint.constant = 0;
    [UIView animateWithDuration:.3 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished){
        
    }];
}

- (void)sliderValueChangedAction:(CharacterSelectView *)slider{
    if (self.textField.selectedTextRange.empty) {
        NSInteger offset = (slider.value - 0.5) * self.textField.text.length * 2;
        NSInteger labsOffset = labs(offset);
        if ((labsOffset > self.lastThreshold && offset < 0) || (labsOffset < self.lastThreshold && offset > 0)) {
            self.lastThreshold = labsOffset;
            UITextPosition *newPosition = [self.textField positionFromPosition:self.textField.selectedTextRange.end inDirection:UITextLayoutDirectionLeft offset:1];
            UITextRange *newSelectedRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
            [self.textField setSelectedTextRange:newSelectedRange];
        }
        else if ((labsOffset < self.lastThreshold && offset < 0) || (labsOffset > self.lastThreshold && offset > 0))
        {
            self.lastThreshold = labsOffset;
            UITextPosition *newPosition = [self.textField positionFromPosition:self.textField.selectedTextRange.end inDirection:UITextLayoutDirectionRight offset:1];
            UITextRange *newSelectedRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
            [self.textField setSelectedTextRange:newSelectedRange];
        }
    }
}

- (IBAction)handleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case SearchButtonTopCacelButton:
            [[[BrowserViewController sharedInstance] navigationController] popViewControllerAnimated:NO];
            break;
        case SearchButtonBottomButton:
            [self.textField insertText:sender.titleLabel.text];
            if (self.quickState == QuickInputButtonStateFirst) {
                [self switchInputViewButtonState];
            }
            break;
        default:
            break;
    }
}

- (void)switchInputViewButtonState{
    self.quickState = !self.quickState;
    NSArray *titleArray = self.quickState ? @[@".",@"/",@".com",@".cn"] : @[@"www.",@"m.",@"http://",@"https://"];
    [self.bottomButtonCollection enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop){
        [button setTitle:titleArray[idx] forState:UIControlStateNormal];
    }];
}

#pragma mark - UITextFieldDelegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldTextDidChange:(NSNotification *)notify{
    UITextField *textField = [notify object];
    if (textField.text.length == 0) {
        if (self.quickState) {
            [self switchInputViewButtonState];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
