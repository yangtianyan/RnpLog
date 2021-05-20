//
//  RnpAddBreakpointSwitchCell.m
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import "RnpBreakpointSwitchCell.h"
/* -- Util -- */
#import "RnpDefine.h"
@interface RnpBreakpointSwitchCell ()

@property (nonatomic, strong, readwrite) UILabel * label;

@property (nonatomic, strong) UISwitch * switchView;

@end

@implementation RnpBreakpointSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.label = UILabelNew().rnp
        .numberOfLines(0)
        .view;
        
        self.switchView = UISwitchNew().rnp
        .addTarget(self, @selector(switchAction:), UIControlEventValueChanged)
        .view;
        
        self.contentView.rnp
        .backgroundColor(UIColor.whiteColor)
        .addSubView(self.label)
        .addSubView(self.switchView);
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout{
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(10.f);
        make.bottom.mas_equalTo(-10.f);
        make.right.equalTo(self.switchView.mas_left).offset(-10.f);
    }];
    [self. switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-15);
    }];
}

- (void)switchAction:(UISwitch *)sw{
    if (self.onChange) {
        self.onChange(sw.on);
    }
}
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.label.text = title;
}
- (void)setIsOn:(BOOL)isOn
{
    self.switchView.on = isOn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
