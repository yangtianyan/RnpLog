//
//  RnpWhiteListHostCell.m
//  RnpLog
//
//  Created by user on 2021/6/4.
//

#import "RnpWhiteListHostCell.h"
/* -- View -- */
#import "RnpDefine.h"
/* -- Util -- */
#import "RnpWhiteListHostModel.h"
@interface RnpWhiteListHostCell ()

@property (nonatomic, strong) UITextField * textField;

@end

@implementation RnpWhiteListHostCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textField = UITextFieldNew().rnp
        .font([UIFont systemFontOfSize:15])
        .textColor(UIColor.lightGrayColor)
        .placeholder(@" 输入需要替换的域名")
        .border(1, UIColor.lightGrayColor)
        .cornerRadius(10)
        .addTarget(self, @selector(textChange:), UIControlEventEditingChanged)
        .view;
        
        self.rnp
        .selectionStyle(UITableViewCellSelectionStyleNone);
        self.contentView.rnp
        .backgroundColor(UIColor.whiteColor)
        .addSubView(self.textField);
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout{
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(40.f);
        make.right.mas_equalTo(-15.f);
    }];
}

- (void)setHostModel:(RnpWhiteListHostModel *)hostModel
{
    _hostModel = hostModel;
    self.textField.text = hostModel.host;
}

#pragma mark --
- (void)textChange:(UITextField *)tf{
    self.hostModel.host = tf.text;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
