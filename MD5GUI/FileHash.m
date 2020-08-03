//
//  FileHash.m
//  FileHash
//
//  Created by Murphy on 07/02/2018.
//  Copyright © 2018 Murphy. All rights reserved.
//

#import "FileHash.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CommonCrypto/CommonCrypto.h>

#define FileHashDefaultChunkSizeForReadingData (1024 * 4)


@implementation FileHash


+ (NSString*)getFileMD5WithPath:(NSString*)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge CFStringRef)path);
}

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath){
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, false);
    if (!fileURL) {
        goto done;
    }
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
    
    if (!readStream) {
        goto done;
    }
    
    bool didSucceed = CFReadStreamOpen(readStream);
    
    if (!didSucceed) {
        goto done;
    }
    
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    bool hasMore = true;
    while (hasMore) {
        uint8_t buffer[FileHashDefaultChunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream, (UInt8 *)buffer, sizeof(buffer));
        if (readBytesCount == -1) {
            break;
        }
        if (readBytesCount == 0) {
            hasMore = false;
            continue;
        }
        CC_MD5_Update(&hashObject, buffer, (CC_LONG)readBytesCount);
        
    }
    didSucceed = !hasMore;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    if (!didSucceed) {
        goto done;
    }
    
    char hash[2 *sizeof(digest)+1];
    for (size_t i =0; i<sizeof(digest); ++i) {
        snprintf(hash + (2*i), 3, "%02x",(int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)hash, kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return  result;
}



@end
