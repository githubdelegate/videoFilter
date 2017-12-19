//
//  ZYGPUImgOutput.m
//  SimpleVideoFilter
//
//  Created by zhangyun on 2017/11/9.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import "ZYGPUImgOutput.h"
#import "ZYFrameBuffer.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>


void runAsynchronouslyOnVideoProcessQueue(void (^block)(void)){
    if(dispatch_get_current_queue() == [[ZYGPUImgCtx shareCtx] videoProcessingQueue]){
        block();
    }else{
        dispatch_async([[ZYGPUImgCtx shareCtx] videoProcessingQueue], block);
    }
}

void  runSynchronoouslyOnVideoProcessQueue(void(^block)(void)){
    if(dispatch_get_current_queue() == [[ZYGPUImgCtx shareCtx] videoProcessingQueue]){
        block();
    }else{
        dispatch_sync([[ZYGPUImgCtx shareCtx] videoProcessingQueue], block);
    }
}

@implementation ZYGPUImgOutput
- (instancetype)init {
    if(self = [super init]){

        // internlformat 和format的区别：
        /* 1. format和type 组合起来用来描述本地数据的布局，就是client 端的数据，
         * 2. internalformat 描述的是GPU内部如何保存处理纹理数据格式。
         * 3. opengl会把数据从format转换到internalformat
         * 4. 想把纹理数据快速高效的上传到gpu，最好不要转换。
         * 3. 一般情况下这两个是一样的，不然每次都要转换影响性能。
         * */

        _outputOptions.minFilter = GL_LINEAR;
        _outputOptions.magFilter = GL_LINEAR;
        _outputOptions.wrapT = GL_CLAMP_TO_EDGE;
        _outputOptions.wrapS = GL_CLAMP_TO_EDGE;
        _outputOptions.internalFormat = GL_RGBA;
        _outputOptions.format = GL_BGRA;
        _outputOptions.type = GL_UNSIGNED_BYTE;
    }
    return self;
}
@end
