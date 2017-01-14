//
//  ProvinceAndCityPickerView.h
//  ProvinceAndCityDemo
//
//  Created by 张猛 on 17/1/14.
//  Copyright © 2017年 Zoesap. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SelecetdString)(NSString *province,NSString *city);
typedef void(^CompleteAnimationBlock)(BOOL Complete);


@interface ProvinceAndCityPickerView : UIView
@property (nonatomic,strong)SelecetdString selectedCityStr;

- (instancetype) initWithCancelStr:(NSString *)str OtherButtonTitles:(NSString *)Titles AttachTitle:(NSString *)AttachTitle;

@end
