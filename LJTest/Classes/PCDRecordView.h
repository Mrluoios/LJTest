//
//  PCDRecordView.h
//  PCDBank
//
//  Created by luojian on 2022/5/8.
//  Copyright © 2022 DK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PCDTakeRecordBlock)(NSDictionary *data);

@interface PCDRecordView : UIView
@property(nonatomic,copy)PCDTakeRecordBlock recordBlock;
@property(nonatomic,assign)NSInteger recordTime;
//录音
//-(void)initTakeRecordSubViews;
+(void)takeMyTest;
@end

NS_ASSUME_NONNULL_END
