//
//  ViewController.m
//  ProvinceAndCityDemo
//
//  Created by 张猛 on 17/1/14.
//  Copyright © 2017年 Zoesap. All rights reserved.
//

#import "ViewController.h"
#import "ProvinceAndCityPickerView.h"

@interface ViewController ()
{
    UILabel *_label;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 80, 40)];
    [button setTitle:@"点击" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
   // button.backgroundColor = [UIColor orangeColor];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _label = [[UILabel alloc]initWithFrame:CGRectMake(20, 150, self.view.frame.size.width-40, 30)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"显示地区";
    [self.view addSubview:_label];
    
    
    
}
- (void)buttonClick
{
    ProvinceAndCityPickerView *pickerView = [[ProvinceAndCityPickerView alloc]initWithCancelStr:@"取消" OtherButtonTitles:@"确定" AttachTitle:nil];
    [self.view addSubview:pickerView];
    pickerView.selectedCityStr = ^(NSString *province,NSString *city){
        NSLog(@"city = %@===%@",province,city);
        _label.text = [NSString stringWithFormat:@"%@%@",province,city];
        
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
