#version 100

attribute vec4 position;
attribute vec4 inputTextureCoord;

varying vec2 textureCoord;

void main(){
    gl_Position = position;
    textureCoord = inputTextureCoord.xy;
}