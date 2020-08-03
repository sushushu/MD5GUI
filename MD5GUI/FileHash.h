//
//  FileHash.h
//  FileHash
//
//  Created by Murphy on 07/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHash : NSObject

+ (NSString*)getFileMD5WithPath:(NSString*)path;

@end
