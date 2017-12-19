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

- (void)generateFrameBuffer{

    glGenFramebuffers(1,&frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);

    /**
     *             CFDictionaryRef empty; // empty value for attr value.
            CFMutableDictionaryRef attrs;
            empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
            attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);

            CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault,
                    (int)_size.width, (int)_size.height, kCVPixelFormatType_32BGRA, attrs, &renderTarget);
            if (err)
            {
                NSLog(@"FBO size: %f, %f", _size.width, _size.height);
                NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
            }

            // 创建纹理，图片参数为NULL,
            err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, coreVideoTextureCache, renderTarget,
                                                                NULL, // texture attributes
                                                                GL_TEXTURE_2D,
                                                                _textureOptions.internalFormat, // opengl format
                                                                (int)_size.width,
                                                                (int)_size.height,
                                                                _textureOptions.format, // native iOS format
                                                                _textureOptions.type,
                                                                0,
                                                                &renderTexture);
     *
     */
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

- (void)unlock {
    refCount--;
    if(refCount < 1){
        // 这个buffer 要被回收
        //
    }
}

- (void)lock {
    refCount++;
}


- (GLuint)renderTextureId {
    return renderTexture;
}
@end