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
@end

@implementation FileCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.view = self.backgroundView;
//
//    NSTextField *label = [NSTextField new];
//    label.enabled = NO;
//    label.stringValue = @"aaaa";
//    [self.backgroundView addSubview:label];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.offset(0);
//    }];

   
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
     [self mainBtn];
}

- (void)changeMD5 {
    
}


- (void)configWithModel:(FileModel *)model {
    if (!model.isFinish) {
        
    }
    self.filePathLabel.stringValue = model.filePath?model.filePath:@"";
    self.fileMD5Label.stringValue = model.fileHash?model.fileHash:@"";
    self.fileSizeLabel.stringValue = model.fileSize?model.fileSize:@"";
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

- (NSButton *)mainBtn {
    if (!_mainBtn) {
        _mainBtn = [NSButton buttonWithTitle:@"改" target:self action:@selector(changeMD5)];
        _mainBtn.font = [NSFont messageFontOfSize:20];
//        _mainBtn.bezelColor = NSColor.redColor;
        [self.view addSubview:_mainBtn];
        [_mainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.collectionView);
            make.width.height.offset(60);
            make.right.equalTo(self.view).offset(-20);
        }];
    }
    return _mainBtn;
}


@end
