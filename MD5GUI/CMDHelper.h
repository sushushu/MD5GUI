//
//  CMDHelper.h
//  MD5GUI
//
//  Created by Jianzhimao on 2020/8/6.
//  Copyright © 2020 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMDHelper : NSObject

/// 执行一段shell
+ (NSString *)executeCMDStr:(NSString * _Nonnull)cmd;

/// 根据文件路径执行一段改变改文件的shell脚本
+ (void)executeCMDStrForChangeMD5WithPath:(NSString * _Nonnull)path;

@end

NS_ASSUME_NONNULL_END
