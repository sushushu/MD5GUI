//
//  FileWindowController.m
//  FileHash
//
//  Created by Murphy on 08/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import "FileWindowController.h"
#import "FileCollectionViewItem.h"
#import "FileModel.h"
#import "FileHash.h"
//#import <Masonry/Masonry.h>
#import "MBProgressHUD.h"
#import "CMDHelper.h"

@interface FileWindowController () <NSCollectionViewDelegate,NSCollectionViewDataSource>

@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray <FileModel *>*dataArray;

@property (weak) IBOutlet NSButton *allButtn;
@property (weak) IBOutlet NSButton *hButton;
@property (weak) IBOutlet NSButton *mButton;
@property (weak) IBOutlet NSButton *swiftButton;
@property (weak) IBOutlet NSButton *pngButton;
@property (weak) IBOutlet NSButton *webpButton;
@property (weak) IBOutlet NSButton *jpgButton;
@property (weak) IBOutlet NSView *btnsContainerView;
@property (weak) IBOutlet NSButton *gifButton;

@end


@implementation FileWindowController {
    NSArray <NSString *> *_ignoreFilesList;
    NSArray <NSString *> *_allowFilesList;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _ignoreFilesList = @[@".app"];
    _allowFilesList = @[@"h", @"m", @"swift", @"png"];
    [self addButtonEvent];
    [self initViews];
}


- (void)initViews {
    self.dataArray = [NSMutableArray array];

    //kUTTypeFileURL
    [self.collectionView registerForDraggedTypes:@[(NSString*)kUTTypeFileURL]];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    [self.collectionView registerNib:[[NSNib alloc] initWithNibNamed:@"FileCollectionViewItem" bundle:nil] forItemWithIdentifier:@"FileCollectionViewItem"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(480.0, 200.0);
    layout.sectionInset = NSEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView reloadData];
}

- (void)addButtonEvent {
    [self.allButtn setTarget:self];
    [self.allButtn setAction:@selector(test)];
    
}

- (IBAction)clear:(id)sender {
    [self.dataArray removeAllObjects];
    [self.collectionView reloadData];
}

/// 修改当前所有文件的MD5
- (IBAction)changeAll:(NSButton *)sender {
    if (self.dataArray.count == 0 || self.collectionView == nil) {
        return;
    }
    
    // TODO: 这里的文件数量通常会很大，要做限制
//    [self.dataArray enumerateObjectsUsingBlock:^(FileModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        @autoreleasepool {
//            [CMDHelper executeCMDStrForChangeMD5WithPath:obj.filePath];
//        }
//    }];
    
    for (FileModel *obj in self.dataArray) {
        @autoreleasepool {
            [CMDHelper executeCMDStrForChangeMD5WithPath:obj.filePath];
        }
    }
}

//- (void)filterButtonsClick:(NSButton *)sender {
//    if (sender != self.allButtn) {
//        self.allButtn.enabled = NO;
//    }
//
//}

- (IBAction)allClick:(NSButton *)sender {
    
}

/// NSCollectionView

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    FileCollectionViewItem *item =  [collectionView makeItemWithIdentifier:@"FileCollectionViewItem" forIndexPath:indexPath];
    if(!item) {
        item = [[FileCollectionViewItem alloc] initWithNibName:@"FileCollectionViewItem" bundle:nil];
    }
    FileModel *model = self.dataArray[indexPath.item];

    [item configWithModel:model];
    return item;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event {
    return YES;
}

//- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndex:(NSUInteger)index {
//    
//}
- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation {
    [self handleDragInfo:draggingInfo];
    return YES;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath *__autoreleasing  _Nonnull *)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
    return NSDragOperationEvery;
}

- (void)handleDragInfo:(id<NSDraggingInfo>)draggingInfo {
    NSPasteboard* pb = draggingInfo.draggingPasteboard;
    NSMutableArray *uploadUrls = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *urlItems = [pb pasteboardItems];
    for (NSPasteboardItem *item in urlItems)
    {
        NSArray *array = [item types];
        NSString *string = [item stringForType:[array lastObject]];
        NSURL *urlString = [NSURL URLWithString:string];
        if (urlString)
        {
            [uploadUrls addObject:urlString];
        }
    }
    
    NSArray *urlStringArray = [NSArray array];
    if (uploadUrls.count > 0)
    {
        NSMutableArray *uploadUrlArr = [NSMutableArray array];
        for (NSURL *url in uploadUrls) {
            if (![url isKindOfClass:[NSURL class]]) {
                return;
            }
            [uploadUrlArr addObject:url.path];
        }
        if (uploadUrlArr.count == 0) {
            return;
        }
        urlStringArray = [NSArray arrayWithArray:uploadUrlArr];
    }
    [self handleUrlString:urlStringArray];
}

// 可以处理多个文件或者文件夹
- (void)handleUrlString:(NSArray *)array {
    if (array.count == 0) {
        return;
    }
    
    for (NSString *url in array) {
        BOOL isDir = NO;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:url isDirectory:&isDir];
        if (!isExist) {
            [self showAlertWithMessage:@"文件不存在"];
            return;
        }
        [self showAllFileWithPath:url];
    }

    [self.collectionView reloadData];
}

//遍历所有文件
- (void)showAllFileWithPath:(NSString *)path {
    if (path.length == 0) {
        return;
    }
    
    // TODO: 跳过隐藏文件、非常规文件，点开头的都是隐藏文件
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDir = NO; // 判断是否文件夹
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) { // If folder
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:&error];
            if (error) {
                NSLog(@"出错");
                return;
            }
            NSString * subPath = @"";
            for (NSString *str in dirArray) {
                subPath = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self showAllFileWithPath:subPath];
            }
        }else{ // If file
            [self _createModelWithPath:path];
        }
    }else{
        NSLog(@"this path is not exist!");
    }
}

// 判断是否包含忽略文件,比如xxx.app
- (BOOL)_isContainsIgnoredFileWithPath:(NSString *)path {
    __block BOOL ret = NO;
    if (path.length == 0) {
        return ret;
    }
    [_ignoreFilesList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([path containsString:obj]) {
            ret = YES;
            *stop = YES;
        }
    }];
    
    return ret;
}

- (void)_createModelWithPath:(NSString *)path {
    if (path.length <= 0) {
        return;
    }
    
    NSLog(@" file full path: %@ " , path);
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *att = [fileManger attributesOfItemAtPath:path error:&error];
    if (error || att == nil) {
        NSLog(@"出错 %@",error);
        [self showAlertWithMessage:error.localizedDescription];
        return;
    }
    NSNumber *fileSize = att[NSFileSize];
    NSString *name = [[NSURL fileURLWithPath:path] lastPathComponent];
    NSArray *compose = [name componentsSeparatedByString:@"."];
    if (compose.count == 0) {
        return;
    }
    
    // 检查文件是否在白名单内
    __block BOOL ret = NO;
    NSString *fileSuffix = compose.lastObject;
    [fileSuffix class];
    [_allowFilesList enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:fileSuffix]) {
            ret = YES;
        }
    }];
    if (!ret) {
        return;
    }
    
    FileModel *model = [[FileModel alloc] init];
    model.filePath = path;
    model.fileName = name;
    model.fileSize = fileSize;
    model.fileHash = [FileHash getFileMD5WithPath:path];
    model.isFinish = YES;
    [self.dataArray addObject:model];
    [self.collectionView reloadData];
}

- (void)showAlertWithMessage:(NSString *)msg {
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:@"错误提示"];
    [alert setInformativeText:msg];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"确定");
        }else if(returnCode == NSAlertSecondButtonReturn){
            NSLog(@"删除");
        }
    }];
}

@end
   
