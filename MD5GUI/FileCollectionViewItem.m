//
//  FileCollectionViewItem.m
//  FileHash
//
//  Created by Murphy on 08/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import "FileCollectionViewItem.h"
//#import <Masonry/Masonry.h>
#import "FileHash.h"
#import "MBProgressHUD.h"
#import "CMDHelper.h"

#define MB_AUTORELEASE(exp) exp


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

@implementation FileCollectionViewItem {
    MBProgressHUD *HUD;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.model = [FileModel new];
    
    self.filePathLabel.layer.cornerRadius = 5;
    self.filePathLabel.layer.borderWidth = 1.f;
    self.filePathLabel.layer.borderColor = NSColor.lightGrayColor.CGColor;
}

- (IBAction)openFile:(NSButton *)sender {
    if (!self.model) {
        return;
    }
    
    // TODO: open 打开文件的时候，路径中不能有空格
    [CMDHelper executeCMDStr:[NSString stringWithFormat:@"open %@",self.model.filePath]];
}

- (IBAction)change:(NSButton *)sender {
    if (!self.model) {
        return;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD showWhileExecuting:@selector(task) onTarget:self withObject:nil animated:YES];
}

- (void)task {
    [CMDHelper executeCMDStrForChangeMD5WithPath:self.model.filePath];
    
    // 重新计算md5
    NSString *mewMD5 = [FileHash getFileMD5WithPath:self.model.filePath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       self.fileMD5Label.stringValue = mewMD5;
    });
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
