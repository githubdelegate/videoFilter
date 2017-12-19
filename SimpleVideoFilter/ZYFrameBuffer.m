//
// Created by zhangyun on 2017/11/28.
// Copyright (c) 2017 Cell Phone. All rights reserved.
//

#import "ZYFrameBuffer.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ZYGPUImgCtx.h"

@interface ZYFrameBuffer(){
    GLuint  frameBuffer;
    NSInteger refCount;
    ZYGPUTextureOptions _options;
    BOOL  _onlyTexture;
}
@end

@implementation ZYFrameBuffer

- (instancetype)initWithSize:(CGSize)size {
    if(self = [super init]){
        renderSize = size;
        refCount = 0;
        [self generateFrameBuffer];
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size options:(ZYGPUTextureOptions)options onlyTexture:(BOOL)onlyTexture{
    if(self = [super init]){
        renderSize = size;
        _options = _options;
        _onlyTexture = onlyTexture;
    }
    return [self initWithSize:size];
}

- (void)generateFrameBuffer{

    glGenFramebuffers(1,&frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);

    // corevideo  fast 创建texture
    CVOpenGLESTextureCacheRef textureCacheRef;
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [ZYGPUImgCtx shareCtx].currentCtx, NULL,&textureCacheRef);

    CFDictionaryRef empty;
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0,
            &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1,
            &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);

    CVPixelBufferRef pixelBufferRef;
    CVReturn  err = CVPixelBufferCreate(kCFAllocatorDefault, renderSize.width, renderSize.height,
            kCVPixelFormatType_32ARGB, attrs, pixelBufferRef);
    if(err){
        NSLog(@"create pixel buffer failed");
        return;
    }

    CVOpenGLESTextureRef  textureRef;
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCacheRef, NULL,
            NULL, GL_TEXTURE_2D, GL_RGBA, renderSize.width, renderSize.height,GL_BGRA,GL_UNSIGNED_BYTE,0,&textureRef);

    if(err){
        NSLog(@"create texture from cache");
        return;
    }

    CFRelease(attrs);
    CFRelease(empty);
    glBindTexture(CVOpenGLESTextureGetTarget(textureRef), CVOpenGLESTextureGetName(textureRef));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    renderTexture = CVOpenGLESTextureGetName(textureRef);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderTexture, 0);

    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)destoryFramebuffer{

}


#pragma mark - lock

- (void)unlock {
    refCount--;
    if(refCount < 1){
        // 这个buffer 要被回收
        [[ZYGPUImgCtx getFrameBufferCache] returnFramebuffer2Cache:self];
    }
}

- (void)lock {
    refCount++;
}

- (void)clearAllLock{
    refCount = 0;
}

- (GLuint)renderTextureId {
    return renderTexture;
}

#pragma mark - getter
- (CGSize)size{
    return renderSize;
}

- (ZYGPUTextureOptions)options {
    return _options;
}

- (BOOL)onlyTexture {
    return _onlyTexture;
}
@end