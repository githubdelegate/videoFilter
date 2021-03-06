//
// Created by zhangyun on 2017/11/28.
// Copyright (c) 2017 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYGPUImgCtx.h"

typedef struct{
    GLenum  minFilter;
    GLenum  magFilter;
    GLenum  wrapS;
    GLenum  wrapT;
    GLenum  format;
    GLenum  internalFormat;
    GLenum  type;
}ZYGPUTextureOptions;

@interface ZYFrameBuffer : NSObject
{
    GLuint renderTexture;
    CGSize renderSize;
}

@property (nonatomic, readonly, assign) CGSize size;
@property (nonatomic, readonly, assign) ZYGPUTextureOptions options;
@property (nonatomic, readonly, assign) BOOL  onlyTexture;

- (instancetype)initWithSize:(CGSize)size;
- (void)activeFrameBuffer;

- (GLuint)renderTextureId;

- (void)lock;
- (void)unlock;
- (void)clearAllLock;
@end
