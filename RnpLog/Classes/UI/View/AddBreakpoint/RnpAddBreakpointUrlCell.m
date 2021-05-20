//
//  RnpAddBreakpointUrlCell.m
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import "RnpAddBreakpointUrlCell.h"
/* -- Util -- */
#import <RnpKit/RnpKitView.h>
#import "RnpDefine.h"
@interface RnpAddBreakpointUrlCell ()<UITextViewDelegate>

@property (nonatomic, strong) UILabel * titleLB;

@property (nonatomic, strong) UITextView * textView;

@end
@implementation RnpAddBreakpointUrlCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLB = UILabelNew().rnp
        .text(@"断点URL")
        .view;
        
        self.textView = UITextViewNew().rnp
        .border(1, UIColor.lightGrayColor)
        .delegate(self)
        .view;
        
        self.contentView.rnp
        .backgroundColor(UIColor.whiteColor)
        .addSubView(self.titleLB)
        .addSubView(self.textView);
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout{
    [self.titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(10);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.equalTo(self.titleLB.mas_bottom).offset(10);
        make.bottom.mas_equalTo(-10.f);
    }];
}

- (void)setEditable:(BOOL)editable
{
    self.textView.editable = editable;
}
- (void)setUrl:(NSString *)url
{
    self.textView.text = url;
}

#pragma mark -- textViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textChangeBlock) {
        self.textChangeBlock(textView.text);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
