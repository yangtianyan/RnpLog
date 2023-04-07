//
//  RnpRequestCell.m
//  NetworkLog
//
//  Created by user on 2021/5/14.
//

#import "RnpRequestCell.h"
/* -- Model -- */
#import "RnpDataModel.h"
/* -- Util -- */
#import "RnpDefine.h"
@interface RnpRequestCell ()

@property (nonatomic, strong) UILabel * titleLB;

@property (nonatomic, strong) UILabel * dateLB;

@property (nonatomic, strong) UILabel * stateLB;

@end
@implementation RnpRequestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLB = UILabelNew().rnp
        .textColor([UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1])
        .font([UIFont systemFontOfSize:15])
        .numberOfLines(0)
        .view;
        
        self.dateLB = UILabelNew().rnp
        .textColor([UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1])
        .font([UIFont systemFontOfSize:10])
        .view;
        
        self.stateLB = UILabelNew().rnp
        .textColor([UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1])
        .font([UIFont systemFontOfSize:10])
        .view;
        
        UIViewNew().rnp
        .addToSuperView(self.contentView)
        .backgroundColor([UIColor colorWithRed:235/355.f green:235/355.f blue:235/355.f alpha:1])
        .mas_makeConstraints(^(MASConstraintMaker * _Nonnull make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(1);
        });
        
        
        self.contentView.rnp
        .backgroundColor(UIColor.whiteColor)
        .addSubView(self.titleLB)
        .addSubView(self.stateLB)
        .addSubView(self.dateLB)
        .addGesture([[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAct)])
        ;
        [self setupLayout];
    }
    return self;
}

- (void)setupLayout{
    CGFloat padding = 15;
    [self.titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(padding);
        make.right.mas_equalTo(-padding);
        make.top.mas_equalTo(5.f);
    }];
    [self.stateLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLB);
        make.top.equalTo(self.titleLB.mas_bottom).offset(5);
    }];
    [self.dateLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLB);
        make.top.equalTo(self.stateLB.mas_bottom).offset(5);
        make.bottom.mas_equalTo(-5.f);
    }];
}

- (void)setModel:(RnpDataModel *)model
{
    if (_model) {
        [self removeObserver];
    }
//    [model addObserver:self forKeyPath:@"originalData" options:NSKeyValueObservingOptionNew context:NULL];
    [model.task addObserver:self forKeyPath:@"response" options:NSKeyValueObservingOptionNew context:NULL];
    [model.task addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:NULL];

    _model = model;
    NSURLSessionDataTask * task = model.task;
    NSString * tag = @"";
    if (task.response == nil) {
        if (task.error) {
            tag = @"❌ ";
            if (model.redirectedUrl.length) {
                tag = @"🔄 ";
            }
        }else{
            tag = @"⚠️";
        }
    }else{
        tag = @"✅ ";
    }
    self.titleLB.text = [NSString stringWithFormat:@"%@ %@",tag, task.originalRequest.URL];
    self.dateLB.text = [NSString stringWithFormat:@"%@", model.requestDate];
    if([task.response isKindOfClass:NSHTTPURLResponse.class]){
        self.stateLB.text = [NSString stringWithFormat:@"HttpCode: %lu",[(NSHTTPURLResponse *)task.response statusCode]];
    }else{
        self.stateLB.text = @" ";
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString * tag = @"";
//        if ([keyPath isEqualToString:@"response"]) {
//            tag = self.model.task.response ? @"✅ " : @"❌ ";
//        }else if ([keyPath isEqualToString:@"error"])
//        {
//            tag = self.model.task.error ?  @"❌  " : @"✅ ";
//        }
//        self.titleLB.text = [NSString stringWithFormat:@"%@ %@",tag, self.model.task.originalRequest.URL];
        [self setModel:self.model];
    });

}
- (void)removeObserver{
    [_model.task removeObserver:self forKeyPath:@"response"];
    [_model.task removeObserver:self forKeyPath:@"error"];
}
- (void)longAct{
    !self.longPressBlock ?: self.longPressBlock();
}

- (void)dealloc
{
    [self removeObserver];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
