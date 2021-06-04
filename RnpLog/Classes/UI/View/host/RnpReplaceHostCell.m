//
//  RnpReplaceHostCell.m
//  RnpLog
//
//  Created by user on 2021/5/24.
//

#import "RnpReplaceHostCell.h"
/* -- Util -- */
#import "RnpDefine.h"
/* -- Model -- */
#import "RnpReplaceHostModel.h"
@interface RnpReplaceHostCell ()

@property (nonatomic, strong) UITextField * keyTF;

@property (nonatomic, strong) UITextField * valueTF;

@property (nonatomic, strong) UILabel * label;

@end
@implementation RnpReplaceHostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.keyTF = UITextFieldNew().rnp
        .font([UIFont systemFontOfSize:15])
        .textColor(UIColor.lightGrayColor)
        .placeholder(@" 输入需要替换的域名")
        .border(1, UIColor.lightGrayColor)
        .cornerRadius(10)
        .addTarget(self, @selector(keyChange:), UIControlEventEditingChanged)
        .view;
        
        self.label = UILabelNew().rnp
        .font([UIFont systemFontOfSize:16])
        .text(@":")
        .view;
        
        self.valueTF = UITextFieldNew().rnp
        .font([UIFont systemFontOfSize:15])
        .textColor(UIColor.lightGrayColor)
        .placeholder(@" 输入替换后的域名")
        .border(1, UIColor.lightGrayColor)
        .cornerRadius(10)
        .addTarget(self, @selector(valueChange:), UIControlEventEditingChanged)
        .view;
        
        self.rnp
        .selectionStyle(UITableViewCellSelectionStyleNone);
        self.contentView.rnp
        .backgroundColor(UIColor.whiteColor)
        .addSubView(self.keyTF)
        .addSubView(self.label)
        .addSubView(self.valueTF);
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout{
    [self.keyTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(40.f);
    }];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.keyTF.mas_right).offset(10.f);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(10.f);
    }];
    [self.valueTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerY.equalTo(self.keyTF);
        make.left.equalTo(self.label.mas_right).offset(10);
        make.right.mas_equalTo(-15.f);
    }];
}

- (void)setHostModel:(RnpReplaceHostModel *)hostModel
{
    _hostModel = hostModel;
    self.keyTF.text = hostModel.original_host;
    self.valueTF.text = hostModel.replace_host;
}

#pragma mark --
- (void)keyChange:(UITextField *)tf{
    self.hostModel.original_host = tf.text;
}
- (void)valueChange:(UITextField *)tf{
    self.hostModel.replace_host = tf.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
