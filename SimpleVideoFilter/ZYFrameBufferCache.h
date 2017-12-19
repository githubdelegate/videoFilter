//
// Created by zhangyun on 2017/12/18.
// Copyright (c) 2017 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYFrameBuffer.h"

@interface ZYFrameBufferCache : NSObject
// 获取framebuffer
- (ZYFrameBuffer *)framebufferForSize:(CGSize)size option:(ZYGPUTextureOptions)option onlyTexture:(BOOL)only;
// 把framebuffer 放回到缓存池
- (void)returnFramebuffer2Cache:(ZYFrameBuffer *)framebuffer;
@end
