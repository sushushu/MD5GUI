//
//  FileModel.h
//  FileHash
//
//  Created by Murphy on 08/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *fileHash;
@property (nonatomic,strong) NSString *fileSize;
@property (nonatomic,assign) BOOL isFinish;

@end
