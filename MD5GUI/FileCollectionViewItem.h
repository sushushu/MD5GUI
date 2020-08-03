//
//  FileCollectionViewItem.h
//  FileHash
//
//  Created by Murphy on 08/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileModel.h"


@interface FileCollectionViewItem : NSCollectionViewItem

- (void)configWithModel:(FileModel *)model;


@end
