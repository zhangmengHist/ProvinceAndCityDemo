//
//  ProvinceAndCityPickerView.m
//  ProvinceAndCityDemo
//
//  Created by 张猛 on 17/1/14.
//  Copyright © 2017年 Zoesap. All rights reserved.
//

#import "ProvinceAndCityPickerView.h"
@interface ProvinceAndCityPickerView()<UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIWindow *window;
}

@property (nonatomic,copy)      NSString *CancelStr;

@property (nonatomic,strong)    NSString *commitTitle;

@property (nonatomic,weak)      UIView *ButtomView;

@property (nonatomic,copy)      NSString *AttachTitle;

@property (nonatomic,strong)  UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *provincesArray;
@property (nonatomic, strong) NSArray *citiesArray;

#define W [UIScreen mainScreen].bounds.size.width
#define H  [UIScreen mainScreen].bounds.size.height

@end

@implementation ProvinceAndCityPickerView

-(instancetype) initWithCancelStr:(NSString *)str OtherButtonTitles:(NSString *)Titles AttachTitle:(NSString *)AttachTitle
{
    
    self = [super init];
    
    if (self) {
        
    _AttachTitle = AttachTitle;
    _CancelStr = str;
    _commitTitle = Titles;
    [self loadUI];
    [self addSubview];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarOrientationChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    }
    
    return self;
}

-(void)addSubview
{
    UIViewController *toVC = [self appRootViewController];
    if (toVC.tabBarController != nil) {
        [toVC.tabBarController.view addSubview:self];
    }else if (toVC.navigationController != nil){
        [toVC.navigationController.view addSubview:self];
    }else{
        [toVC.view addSubview:self];
    }
}
- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

-(void)loadUI{
    
    /*self*/
    [self setFrame:CGRectMake(0, 0, W, H)];
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    [self setBackgroundColor:[UIColor clearColor]];
    /*end*/
    
    /*buttomView*/ //pickerView和上方的功能区域
    UIView *ButtomView;
    UIView *TopView; //点击消失时间
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统
    if (version >= 8.0f) {
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        ButtomView = [[UIVisualEffectView alloc] initWithEffect:blur];
        
    }else if(version >= 7.0f){
        
        ButtomView = [[UIToolbar alloc] init];
        
    }else{
        
        ButtomView = [[UIView alloc] init];
        
    }
    CGFloat height = 216+50;
    UIFont *font = [UIFont systemFontOfSize:14.0f];
  
    [ButtomView setFrame:CGRectMake(0, H , W, 216+50)];
    _ButtomView = ButtomView;
    ButtomView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:ButtomView];
    
    TopView = [[UIView alloc] init];
    TopView.backgroundColor = [UIColor clearColor];
    [TopView setTag:999];
    [TopView setFrame:CGRectMake(0, 0, W, H)];
    TopView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self addSubview:TopView];
    /*end*/
    
    /*功能条*/
    UIView *functionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, W, 50)];
    functionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [ButtomView addSubview:functionView];

    
    /*CanceBtn*/
    UIButton *Cancebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [Cancebtn setFrame:CGRectMake(5, 15, 50, 20)];
    [Cancebtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [Cancebtn setTitle:_CancelStr forState:UIControlStateNormal];
    [Cancebtn addTarget:self action:@selector(selectedButtons:) forControlEvents:UIControlEventTouchUpInside];
    [Cancebtn addTarget:self action:@selector(scaleToSmall:)
       forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [Cancebtn addTarget:self action:@selector(scaleAnimation:)
       forControlEvents:UIControlEventTouchUpInside];
    [Cancebtn addTarget:self action:@selector(scaleToDefault:)
       forControlEvents:UIControlEventTouchDragExit];
    [Cancebtn setTag:100];
    [functionView addSubview:Cancebtn];
    /*CommitBtn*/
    UIButton *Commitbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [Commitbtn setFrame:CGRectMake(W-55, 15, 50, 20)];
    [Commitbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [Commitbtn setTitle:_commitTitle forState:UIControlStateNormal];
    [Commitbtn addTarget:self action:@selector(commitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [Commitbtn addTarget:self action:@selector(scaleToSmall:)
       forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [Commitbtn addTarget:self action:@selector(scaleAnimation:)
       forControlEvents:UIControlEventTouchUpInside];
    [Commitbtn addTarget:self action:@selector(scaleToDefault:)
       forControlEvents:UIControlEventTouchDragExit];

    [functionView addSubview:Commitbtn];


    /*end*/
    
    [_ButtomView addSubview:self.pickerView];
    self.citiesArray = self.provincesArray[0][@"cities"];
    [self.pickerView reloadAllComponents];

    if ([self isBlankString:_AttachTitle]) {
        
    }else{
        
        UIView *views = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(Cancebtn.frame), 0, W-55-55, 50)];
        views.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
        
        views.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6f];
        //请选择区域标题

        UILabel *AttachTitleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, views.frame.size.width-30, 20)];
        AttachTitleView.font = font;
        AttachTitleView.textColor = [UIColor grayColor];
        AttachTitleView.text = _AttachTitle;
       // AttachTitleView.numberOfLines = 0;
        AttachTitleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        AttachTitleView.textAlignment = NSTextAlignmentCenter;
        [_ButtomView addSubview:views];
        [views addSubview:AttachTitleView];
        [views setTag:9090];
        [self layoutIfNeeded];
    }
    
    typeof(self) __weak weak = self;
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        //[weak setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f]];
        [TopView setFrame:CGRectMake(0, 0, W, H - (216+50))];
        [TopView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f]];
        [ButtomView setFrame:CGRectMake(0, H - (216+50), W, (216+50))];
        
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weak action:@selector(dismiss:)];
        tap.delegate = self;
        [TopView addGestureRecognizer:tap];
        [ButtomView setFrame:CGRectMake(0, H - height, W, height)];
//        [UIView animateWithDuration:0.2 animations:^{
//            if (height > H) {
//               // [weak adaptUIBaseOnOriention];
//            }
//        }];
    }];
    
}


- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

-(void)scaleToSmall:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    }];
    
}

- (void)scaleAnimation:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    }];
    
}

- (void)scaleToDefault:(UIButton *)btn{
    
    [UIView animateWithDuration:0.2 animations:^{
        [btn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6f]];
    }];
    
}



-(void)selectedButtons:(UIButton *)btns{
    
   // typeof(self) __weak weak = self;
    [self DismissBlock:^(BOOL Complete) {
        
//        if (!weak.ButtonIndex) {
//            return ;
//        }
//        weak.ButtonIndex(btns.tag-100);
        
    }];
    
    
}
- (void)commitButtonAction:(UIButton *)button
{
    
    NSInteger selectProvince = [self.pickerView selectedRowInComponent:0];
    NSInteger selectCity     = [self.pickerView selectedRowInComponent:1];
    NSDictionary *item = self.provincesArray[selectProvince];
    NSDictionary *cityDict = self.citiesArray[selectCity];
  

    
    typeof(self) __weak weakSelf = self;
    [self DismissBlock:^(BOOL Complete) {
        
      
    weakSelf.selectedCityStr(item[@"ProvinceName"],cityDict[@"CityName"]);
    }];

   
   // NSLog(@"province = %@,city = %@",item[@"ProvinceName"],cityDict[@"CityName"]);
    
  

}

-(void)dismiss:(UITapGestureRecognizer *)tap{
   // typeof(self) __weak weak = self;
    if( CGRectContainsPoint(self.frame, [tap locationInView:_ButtomView])) {
        NSLog(@"tap");
    } else{
        
        [self DismissBlock:^(BOOL Complete) {
//            if (!weak.ButtonIndex) {
//                return ;
//            }
//            weak.ButtonIndex(0);
            
        }];
    }
}


-(void)DismissBlock:(CompleteAnimationBlock)block{
    
    
    typeof(self) __weak weak = self;
    CGFloat height = 216+50;
    UIView *TopView = [self viewWithTag:999];
    
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        
        [TopView setFrame:CGRectMake(0, 0, W, H)];
        [TopView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
        
        [_ButtomView setFrame:CGRectMake(0, H, W, height)];
        
    } completion:^(BOOL finished) {
        
        block(finished);
        [weak removeFromSuperview];
        
    }];
    
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
   // [self adaptUIBaseOnOriention];
}

-(void)show{
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.windowLevel = UIWindowLevelAlert;
    window.backgroundColor = [UIColor clearColor];
    window.alpha = 1;
    window.hidden = false;
    [window addSubview:self];
}

-(void)dealloc{
    
}

-(void)removeFromSuperview{
    NSArray *SubViews = [self subviews];
    for (id obj in SubViews) {
        [obj removeFromSuperview];
    }
    [window resignKeyWindow];
    [window removeFromSuperview];
    window = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
    
}
- (NSArray *)provincesArray {
    if (!_provincesArray) {
        _provincesArray = [[NSMutableArray alloc] init];
        NSURL *provincesURL = [[NSBundle mainBundle] URLForResource:@"Provinces" withExtension:@"plist"];
        NSArray *provincesArray = [NSArray arrayWithContentsOfURL:provincesURL];
        _provincesArray = provincesArray;
    }
    return _provincesArray;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (0 == component) {
        return self.provincesArray.count;
    } else {
        return self.citiesArray.count;
    }
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return W/2.0f;
//    if (0 == component) {
//        return W / 3.0;
//    } else {
//        return W / 3.0 * 2;
//    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (0 == component) {
        NSDictionary *item = self.provincesArray[row];
        return item[@"ProvinceName"];
    } else {
        NSDictionary *cityDict = self.citiesArray[row];
        return cityDict[@"CityName"];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:16];
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (0 == component) {
        self.citiesArray = self.provincesArray[row][@"cities"];
        [self.pickerView reloadAllComponents];
        [self.pickerView selectRow:0 inComponent:1 animated:YES];
    } else {
        
    }
}
- (UIPickerView *)pickerView
{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 50, W, 216)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    
    return _pickerView;
}



@end
