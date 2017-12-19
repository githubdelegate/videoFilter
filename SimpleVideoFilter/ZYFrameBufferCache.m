//
// Created by zhangyun on 2017/12/18.
// Copyright (c) 2017 Cell Phone. All rights reserved.
//

#import "ZYFrameBufferCache.h"
#import "ZYGPUImgOutput.h"


@implementation ZYFrameBufferCache {
    NSMutableDictionary *bufferDict;
    NSMutableDictionary *bufferNumberDict;
}

- (instancetype)init {
    if(self = [super init]){
        bufferDict = [NSMutableDictionary dictionary];
        bufferNumberDict = [NSMutableDictionary dictionary];

    }
    return self;
}

- (NSString *)hashForSize:(CGSize)size options:(ZYGPUTextureOptions)options onlyTexture:(BOOL)only{
    if(only){
        return [NSString stringWithFormat:@"%.1fx%.1f-%d:%d:%d:%d:%d:%d:%d-NOFB",size.width,size.height,options.minFilter,options.magFilter,options.wrapS,options.wrapT,options.internalFormat,options.format,options.type];
    }else{
        return [NSString stringWithFormat:@"%.1fx%.1f-%d:%d:%d:%d:%d:%d:%d",size.width,size.height,options.minFilter,options.magFilter,options.wrapS,options.wrapT,options.internalFormat,options.format,options.type];
    }
}

- (ZYFrameBuffer *)framebufferForSize:(CGSize)size textureOption:(ZYGPUTextureOptions)options onlyTexture:(BOOL)only {
    __block  ZYFrameBuffer *cacheBuffer = nil;
    // 根据提供的参数计算key；获取buffer个数；> 1 就根据key取出来，然后重新设置个数字典，枷锁返回；没有直接创建枷锁返回。
    runSynchronoouslyOnVideoProcessQueue(^{
        NSString *numberHash = [self hashForSize:size options:options onlyTexture:only];
        NSNumber *number =  [bufferNumberDict valueForKey:numberHash];
        if([number integerValue] < 1){
            cacheBuffer = [[ZYFrameBuffer alloc] initWithSize:size];
        }else{
             NSInteger crtId = [number integerValue] - 1;
             while (cacheBuffer == nil && crtId >= 0){
                 NSString *bufHash = [NSString stringWithFormat:@"%@-%ld",numberHash,crtId];
                 cacheBuffer = [bufferDict objectForKey:bufHash];
                 if(cacheBuffer){
                     [bufferDict removeObjectForKey:bufHash];
                 }
                 crtId--;
             }

            crtId++;
            [bufferNumberDict setObject:[NSNumber numberWithInteger:crtId] forKey:numberHash];
            if(cacheBuffer == nil){
               cacheBuffer = [[ZYFrameBuffer alloc] initWithSize:size];
            }
        }
    });
    [cacheBuffer lock];
    return cacheBuffer;
}

- (void)returnFramebuffer2Cache:(ZYFrameBuffer *)framebuffer {
    if(!framebuffer){
        return;
    }

    [framebuffer clearAllLock];

    runAsynchronouslyOnVideoProcessQueue(^{
        CGSize size = framebuffer.size;
        ZYGPUTextureOptions option = framebuffer.options;
        BOOL only = framebuffer.onlyTexture;

        NSString *numHash = [self hashForSize:size options:option onlyTexture:only];
        NSNumber *num = [bufferNumberDict objectForKey:numHash];
        NSInteger  numBuf = [num integerValue];
        NSString *bufHash = [NSString stringWithFormat:@"%@-%ld",numHash,[num integerValue] - 1];
        if([num integerValue] > 0) {
            NSInteger index = [[bufferDict allValues] indexOfObject:framebuffer];
            if (index >= 0) {
                return; // 说明已经有啦
            }
        }
        [bufferDict setObject:framebuffer forKey:bufHash];
        [bufferNumberDict setObject:numHash forKey:numBuf + 1];

    });
}
@end
