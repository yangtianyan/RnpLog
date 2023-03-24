//
//  RnpJsonTreeCell.m
//  RnpLog
//
//  Created by user on 2023/3/23.
//

#import "RnpJsonTreeCell.h"
/* -- Model -- */
#import "RnpTreeModel.h"
/* -- Util -- */
#import <RnpKit.h>
#import "NSDictionary+log.h"
@interface RnpJsonTreeSubView : UIView

@property (nonatomic, strong) UIView * leftView;

@property (nonatomic, strong) UIView * lineView;

@property (nonatomic, strong) UILabel * foldView;

@property (nonatomic, strong) UILabel * keyLB;

@property (nonatomic, strong) UILabel * valueLB;

@property (nonatomic, strong) UIStackView * stackView;

@property (nonatomic, strong) RnpTreeValueModel * valueModel;

@end

@interface RnpJsonTreeCell()

@property (nonatomic, strong) RnpJsonTreeSubView * subView;

@property (nonatomic, strong) UIStackView * stackView;

@property (nonatomic, strong) UIView * leftPadding;

@property (nonatomic, strong) UIView * rightPadding;

@end
@implementation RnpJsonTreeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.leftPadding = UIViewNew().rnp
        .view;
        
        self.rightPadding = UIViewNew().rnp
        .view;
        
        self.subView = [RnpJsonTreeSubView new];
        
        self.stackView = UIStackViewNew().rnp
        .addArrangedSubview(self.leftPadding)
        .addArrangedSubview(self.subView)
        .addArrangedSubview(self.rightPadding)
        .axis(UILayoutConstraintAxisHorizontal)
        .alignment(UIStackViewAlignmentLeading)
        .spacing(0.f)
        .distribution(UIStackViewDistributionFill)
        .view;
        
        self.contentView.rnp
        .addSubView(self.stackView);
        self.rnp.selectionStyle(UITableViewCellSelectionStyleNone);
        [self setupLayout];
        
    }
    return self;
}

- (void)setupLayout{
    [self.leftPadding mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(10);
    }];
    [self.rightPadding mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(10);
    }];
    [self.subView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.contentView).offset(0);
    }];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        (void)make.edges;
    }];
    
}

#pragma mark -- Public
- (void)setValueModel:(RnpTreeValueModel *)valueModel
{
    _valueModel = valueModel;
    [self.leftPadding mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kHorizontalPadding * valueModel.level);
    }];
    self.subView.valueModel = valueModel;
}

@end


@implementation RnpJsonTreeSubView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
    
        self.keyLB = UILabelNew().rnp
        .font(kKeyFont)
        .view;
        
        self.valueLB = UILabelNew().rnp
        .numberOfLines(0)
        .font(kValueFont)
        .view;
        
        self.leftView = UIViewNew().rnp
        .view;
        
        self.foldView = UILabelNew().rnp
        .border(1, UIColor.lightGrayColor)
        .backgroundColor(UIColor.whiteColor)
        .addToSuperView(self.leftView)
        .textAlignment(NSTextAlignmentCenter)
        .font([UIFont systemFontOfSize:10])
        .view;
        
        self.lineView =UIViewNew().rnp
        .addToSuperView(self.leftView)
        .backgroundColor(UIColor.lightGrayColor)
        .mas_makeConstraints(^(MASConstraintMaker * _Nonnull make) {
            make.centerX.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(1.f);
        }).view;
        
        UIViewNew().rnp
            .addToSuperView(self.leftView)
            .backgroundColor(UIColor.lightGrayColor)
            .mas_makeConstraints(^(MASConstraintMaker * _Nonnull make) {
                make.left.mas_equalTo(self.leftView.mas_centerX);
                make.height.mas_equalTo(1.f);
                make.right.mas_equalTo(0);
                make.centerY.mas_equalTo(self.foldView);
            });
        
        self.leftView.rnp.bringSubViewToFront(self.foldView);
        
        self.stackView = UIStackViewNew().rnp
        .addArrangedSubview(self.leftView)
        .addArrangedSubview(self.keyLB)
        .addArrangedSubview(self.valueLB)
        .addArrangedSubview(UIView.new)
        .axis(UILayoutConstraintAxisHorizontal)
        .alignment(UIStackViewAlignmentLeading)
        .spacing(2.f)
        .distribution(UIStackViewDistributionFill)
        .view;
        
        
        self.rnp.addSubView(self.stackView);
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout{
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        (void)make.edges;
    }];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30.f);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.foldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0.f);
        make.top.mas_equalTo(5.f);
        make.width.height.mas_equalTo(10);
    }];
    [self.keyLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_lessThanOrEqualTo(-5.f);
    }];
    [self.valueLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_lessThanOrEqualTo(0.f);
    }];

    [self.keyLB setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.keyLB setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark -- Public
- (void)setValueModel:(RnpTreeValueModel *)valueModel
{
    _valueModel = valueModel;
    BOOL disableFolod = valueModel.type != RnpTreeDictType && valueModel.type != RnpTreeArrayType;
    self.keyLB.rnp
    .text([NSString stringWithFormat:@"%@%@",valueModel.key, disableFolod ? @":" : @""])
    .textColor(valueModel.keyColor)
    .backgroundColor(valueModel.keyBGColor);
    
    self.valueLB.rnp
    .text([valueModel.value isKindOfClass:NSString.class] ? valueModel.value : nil)
    .textColor(valueModel.valueColor)
    .backgroundColor(valueModel.valueBGColor);
    
    self.foldView.hidden = disableFolod;
    self.foldView.text = valueModel.isFold ? @"+" : @"-";
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.equalTo(valueModel.isLast ? self.foldView.mas_centerY : self);
        make.width.mas_equalTo(1.f);
    }];
}

@end
