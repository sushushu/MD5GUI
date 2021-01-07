//
//  CMDHelper.m
//  MD5GUI
//
//  Created by Jianzhimao on 2020/8/6.
//  Copyright © 2020 Murphy. All rights reserved.
//

#import "CMDHelper.h"

@implementation CMDHelper

/// 根据文件路径执行一段改变改文件的shell脚本
+ (void)executeCMDStrForChangeMD5WithPath:(NSString * _Nonnull)path {
    @autoreleasepool {
        NSLog(@" ******** 正在处理文件：%@ " , path);
        NSString *cmd = [self way1_ComposeCMDStrWithPath:path];
        NSLog(@"即将执行 shell语句: %@" , cmd);
        NSString *ret = [self executeCMDStr:cmd];
        if (ret.length == 0) {
            NSLog(@"******** 处理成功！！ ******** \n\n");
        } else {
            NSLog(@"处理出错: %@",ret);
        }
    }
}

//// 这种调用方式结果是错误的，因为一条命令执行完Task就会销毁，相当于输入完终端关闭，再打开再输出，这时执行第二条语句时第一条语句已经不起作用了
//[self cmd:@"cd Desktop"];
//[self cmd:@"mkdir helloWorld"];
//
//// 应使用下面这种方式实现
//[self cmd:@"cd Desktop; mkdir helloWorld"];
// 报错：Too many open files in system,单个进程打开文件句柄数过多,文件系统最大可打开文件数:文件系统最大可打开文件数
//╭─jianzhimao@BatmanMac.local /etc ‹ruby-2.7.0›
//╰─➤  lsof|wc -l
//e   12397
//
+ (NSString *)executeCMDStr:(NSString * _Nonnull)cmd {
    if (cmd.length == 0) {
        return @"not have cmd string";
    }
    
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    
    // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments:arguments];
    
    // 新建输出管道作为Task的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    // 开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    
    // 获取运行结果
    NSData *data = [file readDataToEndOfFile];
    NSString *ret = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    [pipe.fileHandleForReading closeFile]; // 必须加上这句，否贼会
    return ret;
}

/// 方案一：插入\x1-10  、echo -e -n "\x00" >> AppDelegate.h
+ (NSString *)way1_ComposeCMDStrWithPath:(nonnull NSString *)path {
//    NSArray *sets = @[@"0", @"1", @"2", @"8", @"9"];
//    int i = arc4random() % (int)sets.count;
//    NSString *cmd = [NSString stringWithFormat:@"echo -e -n \"\\x%d\" >> %@", i , path];
    NSString *cmd = [NSString stringWithFormat:@"echo -e -n \"\\x00\" >> %@", path];
    return cmd;
}

/// 方案二：插入各种格式符
+ (NSString *)way2_ComposeCMDStrWithPath:(nonnull NSString *)path {
    NSArray *sets = @[@"n", @"r", @"0"];
    
    int i = arc4random() % (int)sets.count;
    NSString *cmd = [NSString stringWithFormat:@"echo -e -n \'\\%@\' >> %@",sets[i], path];
    return cmd;
}

@end
