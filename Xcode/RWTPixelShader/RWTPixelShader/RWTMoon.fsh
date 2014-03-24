//
//  RWTMoon.fsh
//  RWTPixelShader
//
//  Created by Ricardo on 3/23/14.
//  Copyright (c) 2014 RayWenderlich. All rights reserved.
//

// FRAGMENT SHADER

// Precision
precision highp float;

// Uniforms
uniform mat4 uProjectionMatrix;
uniform vec2 uResolution;
uniform float uTime;

// Constants
const vec2 cCenter = vec2(.5, .5);
const float cRadius = .5;
const vec3 cLight = normalize(vec3(.5, .5, 1.));

float sphereDiffuse(void) {
  vec2 position = gl_FragCoord.xy/uResolution - cCenter;
  position = vec2(uProjectionMatrix * vec4(position, 0.0, 1.0));
  
  if (length(position) > cRadius) {
    discard;
  }
  
  float x = position.x;
  float y = position.y;
  float z = sqrt(cRadius*cRadius - x*x - y*y);
  
  vec3 normal = normalize(vec3(x, y, z));
  float diffuse = max(dot(normal, cLight), 0.);
  
  return diffuse;
}

float random(float p) {
  return fract(sin(p)*10000.);
}

float noise(vec2 p) {
  return random(p.x + p.y*10000.);
}

vec2 sw(vec2 p) {
  return vec2(floor(p.x), floor(p.y));
}

vec2 se(vec2 p) {
  return vec2(ceil(p.x), floor(p.y));
}

vec2 nw(vec2 p) {
  return vec2(floor(p.x), ceil(p.y));
}

vec2 ne(vec2 p) {
  return vec2(ceil(p.x), ceil(p.y));
}

float smoothNoise(vec2 p) {
  vec2 inter = smoothstep(0., 1., fract(p));
  float s = mix(noise(sw(p)), noise(se(p)), inter.x);
  float n = mix(noise(nw(p)), noise(ne(p)), inter.x);
  return mix(s, n, inter.y);
  return noise(nw(p));
}

float movingNoise(vec2 p) {
  float total = 0.0;
  total += smoothNoise(p     - uTime);
  total += smoothNoise(p*2.  + uTime) / 2.;
  total += smoothNoise(p*4.  - uTime) / 4.;
  total += smoothNoise(p*8.  + uTime) / 8.;
  total += smoothNoise(p*16. - uTime) / 16.;
  total /= 1. + 1./2. + 1./4. + 1./8. + 1./16.;
  return total;
}

float noiseBrightness(void) {
  vec2 position = gl_FragCoord.xy/uResolution * 5.;
  position = vec2(uProjectionMatrix * vec4(position, 0.0, 1.0));
  
  float brightness = movingNoise(position);
  
  return brightness;
}

void main(void) {
  float diffuse = sphereDiffuse();
  float brightness = noiseBrightness();
  
  gl_FragColor = vec4(vec3(diffuse*brightness), 1.);
}