//
//  FileCollectionViewItem.m
//  FileHash
//
//  Created by Murphy on 08/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import "FileCollectionViewItem.h"
#import <Masonry/Masonry.h>

@interface FileCollectionViewItem ()

@property (weak) IBOutlet NSTextField *filePathLabel;
@property (weak) IBOutlet NSTextField *fileMD5Label;
@property (weak) IBOutlet NSTextField *fileSizeLabel;
@property (weak) IBOutlet NSTextField *fileNameLabel;
@property (nonatomic,strong) NSTextField *titleLabel;
@property (nonatomic,strong) NSView *backgroundView;
@property (nonatomic,strong) NSButton *mainBtn;
@property (weak) IBOutlet NSImageView *backGroundImageView;
@property (weak) IBOutlet NSButton *changeButton;

@property (nonatomic,strong) FileModel *model;
@end

@implementation FileCollectionViewItem

- (void)awakeFromNib {
    [super awakeFromNib];

    self.model = [FileModel new];
    
    self.filePathLabel.layer.cornerRadius = 5;
    self.filePathLabel.layer.borderWidth = 1.f;
    self.filePathLabel.layer.borderColor = NSColor.lightGrayColor.CGColor;
}


- (IBAction)change:(NSButton *)sender {
    if (!self.model) {
        return;
    }
    
    self.fileMD5Label.textColor = [NSColor redColor];
    
    NSString *cmd = [self way1_ComposeCMDStrWithPath:self.model.filePath];
    NSLog(@" %@" , cmd);
    NSLog(@" %@" , [self _executeCMDStr:cmd]);
}

/// 方案一：插入1-10  、echo -e -n "\x00" >> AppDelegate.h
- (NSString *)way1_ComposeCMDStrWithPath:(nonnull NSString *)path {
    int x = arc4random() % 11;
    NSString *cmd = [NSString stringWithFormat:@"echo -e -n \"\\x%d\" >> %@", x , path];
    return cmd;
}

/// 方案二：插入各种格式符
- (NSString *)way2_ComposeCMDStrWithPath:(nonnull NSString *)path {
    NSArray *sets = @[@"n", @"r", @"0"];
    
    int i = arc4random() % (int)sets.count;
    NSString *cmd = [NSString stringWithFormat:@"echo -e -n \'\\%@\' >> %@",sets[i], path];
    return cmd;
}


//// 这种调用方式结果是错误的，因为一条命令执行完Task就会销毁，相当于输入完终端关闭，再打开再输出，这时执行第二条语句时第一条语句已经不起作用了
//[self cmd:@"cd Desktop"];
//[self cmd:@"mkdir helloWorld"];
//
//// 应使用下面这种方式实现
//[self cmd:@"cd Desktop; mkdir helloWorld"];
- (NSString *)_executeCMDStr:(NSString *)cmd {
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
    NSString *ret = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return ret;
}

- (void)configWithModel:(FileModel *)model {
    self.model = model;
    
    self.filePathLabel.stringValue = model.filePath?model.filePath:@"";
    self.fileMD5Label.stringValue = model.fileHash?model.fileHash:@"";
    self.fileSizeLabel.stringValue = [NSString stringWithFormat:@"%.3f kb ",model.fileSize.longLongValue / 1024.0];
    self.fileNameLabel.stringValue = model.fileName?model.fileName:@"";
}

- (NSView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [NSView new];
        CALayer *viewLayer = [CALayer layer];
        NSView *backgroundView= [[NSView alloc]init];
        [backgroundView setWantsLayer:YES];
        [backgroundView setLayer:viewLayer];
        backgroundView.layer.backgroundColor = [NSColor redColor].CGColor;
        [backgroundView setNeedsDisplay:YES];
        _backgroundView = backgroundView;
    }
    return _backgroundView;
}


@end
