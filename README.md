# ijkplayer
fork ijkplayer

 Platform | Build Guide
 -------- | ------------
 Android | [编译指南](build-android.md)
 iOS | [编译指南](buld-ios.md)

Video player based on [ffplay](http://ffmpeg.org)


#### issues
https://github.com/Bilibili/ijkplayer/issues/4569
解决方案有两种：
1。创建AudioTrack是，bufferSizeInBytes参数设置为4*minBufferSize，可能会导致音频延迟增加一倍
2。走软的加速，即soundtouch，可能会增加性能消耗  必须执行init-android-soundtouch.sh，重新编译ijkplayer
ijkplayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "soundtouch", 1)
这个设置要放在 prepareAsync()之前设置 紧接着 prepareAsync()这个之前设置就行了
我之前是在new IjkMediaPlayer() 之后设置 一直不起作用 后来改了之后 就ok了
正如jiaobinbin同学说的那样，需要在prepareAsync之前设置就能生效，如果对象new出来以后你又调用了reset函数，
那么久会把这个soundtouch属性干掉了，所以在prepareAsync之前再设置就好了，已经解决了米8上的这个问题
感觉这是小米的一个bug。

ffmpeg 完全使用了ShikinChen的ff6.1， 改编译脚本修参考focuseyes360
感谢：[focuseyes360](https://github.com/focuseyes360)、[ShikinChen](https://github.com/ShikinChen/FFmpeg)



### My Build Environment
- Common
 - ubuntu 20.4 TLS & Mac OS X 12
- Android
 - [NDK r14](http://developer.android.com/tools/sdk/ndk/index.html)
 - Android Studio 4.2.2
 - Gradle 6.7.1
- iOS
 - Xcode 12
- [HomeBrew](http://brew.sh)
 - ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
 - brew install git

### Latest Changes
- [NEWS.md](NEWS.md)

### Features
- Common公共
 - remove rarely used ffmpeg components to reduce binary size [config/module-lite.sh](config/module-lite.sh)
 - 删除很少使用的 ffmpeg 组件以减少二进制大小 [configmodule-lite.sh](configmodule-lite.sh)
 - workaround for some buggy online video.
 - 一些有问题的在线视频的解决方法。
- Android
 - platform: API 16~34  64位是最低21  21~34
 - 平台：API 16~34
 - cpu: ARMv7a, ARM64v8a, x86 x86_64
 - api: [MediaPlayer-like](android/ijkplayer/ijkplayer-java/src/main/java/tv/danmaku/ijk/media/player/IMediaPlayer.java)
 - video-output: NativeWindow, OpenGL ES 2.0
 - 视频输出：NativeWindow、OpenGL ES 2.0
 - audio-output: AudioTrack, OpenSL ES
 - 音频输出：AudioTrack、OpenSL ES
 - hw-decoder: MediaCodec (API 16+, Android 4.1+)
 - 硬件解码器：MediaCodec（API 16+、Android 4.1+）
 - alternative-backend: android.media.MediaPlayer, ExoPlayer
 - 替代后端：android.media.MediaPlayer、ExoPlayer
- iOS
 - platform: iOS 9.0~17.x
 - iOS - 平台：iOS 9.0~17.x
 - cpu: arm64, i386, x86_64, (armv7s is obselete)
 - api: [MediaPlayer.framework-like](ios/IJKMediaPlayer/IJKMediaPlayer/IJKMediaPlayback.h)
 - video-output: OpenGL ES 2.0
 - audio-output: AudioQueue, AudioUnit
 - hw-decoder: VideoToolbox (iOS 8+)
 - alternative-backend: AVFoundation.Framework.AVPlayer, MediaPlayer.Framework.MPMoviePlayerControlelr (obselete since iOS 8)
 - cpu ：arm64、i386、x86_64 
 - api：[MediaPlayer.framework-like](iosIJKMediaPlayerIJKMediaPlayerIJKMediaPlayback.h) 
 - 视频输出：OpenGL ES 2.0 
 - 音频输出：AudioQueue、AudioUnit 
 - 硬件解码器： VideoToolbox (iOS 8+) 
 - 替代后端：AVFoundation.Framework.AVPlayer、MediaPlayer.Framework.MPMoviePlayerControlelr（自 iOS 8 起已废弃）
### NOT-ON-PLAN
- obsolete platforms (Android: API-15 and below; iOS: pre-8.0)
- obsolete cpu: ARMv5, ARMv6, ARMv7, MIPS (I don't even have these types of devices…)
- native subtitle render
- avfilter support

### Before Build
```
# install homebrew, git, yasm
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm

# add these lines to your ~/.bash_profile or ~/.profile
# export ANDROID_SDK=<your sdk path>
# export ANDROID_NDK=<your ndk path>

# on Cygwin (unmaintained)
# install git, make, yasm
```

- If you prefer more codec/format
```
cd config
rm module.sh
ln -s module-default.sh module.sh
cd android/contrib
# cd ios
sh compile-ffmpeg.sh clean
```

- If you prefer less codec/format for smaller binary size (include hevc function)
```
cd config
# 删除默认的解码器
rm module.sh
# 创建一个软连接指向 module-lite-hevc.sh，这个可根据自己需求进行选择
ln -s module-lite-hevc.sh module.sh
cd android/contrib
# cd ios
sh compile-ffmpeg.sh clean
```

- If you prefer less codec/format for smaller binary size (by default)
```
cd config
rm module.sh
ln -s module-lite.sh module.sh
cd android/contrib
# cd ios
sh compile-ffmpeg.sh clean
```

- For Ubuntu/Debian users.
```
# choose [No] to use bash
sudo dpkg-reconfigure dash
```
ijkplayer 删除本地tag
git tag -d  k0.2.3 k0.2.4 k0.3.0 k0.3.1 k0.3.2 k0.3.2-rc.1 k0.3.2-rc.2 k0.3.2-rc.3 k0.3.2.1 k0.3.2.2 k0.3.3 k0.4.0 k0.4.1 k0.4.1.1 k0.4.2 k0.4.2.1 k0.4.2.2 k0.4.2.3 k0.4.2.4 k0.4.3 k0.4.3.1 k0.4.3.12 k0.4.3.3 k0.4.3.5 k0.4.3.6 k0.4.3.7 k0.4.4 k0.4.4.1 k0.4.5 k0.4.5.1 k0.5.0 k0.5.1 k0.5.1.1 k0.6.0 k0.6.1 k0.6.1.1 k0.6.1.2 k0.6.2 k0.6.2.1 k0.6.2.2 k0.6.3 k0.7.0 k0.7.0.1 k0.7.1 k0.7.2 k0.7.3 k0.7.4 k0.7.5 k0.7.6 k0.7.7 k0.7.7.1 k0.7.8 k0.7.8.1 k0.7.9 k0.8.0 k0.8.1 k0.8.2 k0.8.3 k0.8.4 k0.8.5.1 n0.0.1 n0.0.2 n0.0.3 n0.0.4 n0.0.5 n0.0.6 n0.0.7 n0.1.0 n0.1.1 n0.1.2 n0.1.3 n0.2.0 n0.2.1 n0.2.2 wk2.2 wk2.2a wk2.2b
删除远程tag
git push origin --delete k0.2.3 k0.2.4 k0.3.0 k0.3.1 k0.3.2 k0.3.2-rc.1 k0.3.2-rc.2 k0.3.2-rc.3 k0.3.2.1 k0.3.2.2 k0.3.3 k0.4.0 k0.4.1 k0.4.1.1 k0.4.2 k0.4.2.1 k0.4.2.2 k0.4.2.3 k0.4.2.4 k0.4.3 k0.4.3.1 k0.4.3.12 k0.4.3.3 k0.4.3.5 k0.4.3.6 k0.4.3.7 k0.4.4 k0.4.4.1 k0.4.5 k0.4.5.1 k0.5.0 k0.5.1 k0.5.1.1 k0.6.0 k0.6.1 k0.6.1.1 k0.6.1.2 k0.6.2 k0.6.2.1 k0.6.2.2 k0.6.3 k0.7.0 k0.7.0.1 k0.7.1 k0.7.2 k0.7.3 k0.7.4 k0.7.5 k0.7.6 k0.7.7 k0.7.7.1 k0.7.8 k0.7.8.1 k0.7.9 k0.8.0 k0.8.1 k0.8.2 k0.8.3 k0.8.4 k0.8.5.1 n0.0.1 n0.0.2 n0.0.3 n0.0.4 n0.0.5 n0.0.6 n0.0.7 n0.1.0 n0.1.1 n0.1.2 n0.1.3 n0.2.0 n0.2.1 n0.2.2 wk2.2 wk2.2a wk2.2b
- If you'd like to share your config, pull request is welcome.

### Build Android
```
git clone https://github.com/Bilibili/ijkplayer.git ijkplayer-android
cd ijkplayer-android
git checkout -B latest k0.8.8

./init-android.sh

cd android/contrib
./compile-ffmpeg.sh clean
./compile-ffmpeg.sh all

cd ..
./compile-ijk.sh all

# Android Studio:
#     Open an existing Android Studio project
#     Select android/ijkplayer/ and import
#
#     define ext block in your root build.gradle
#     ext {
#       compileSdkVersion = 28       // depending on your sdk version
#       buildToolsVersion = "28.0.3" // depending on your build tools version
#
#       targetSdkVersion = 28        // depending on your sdk version
#     }
#
# If you want to enable debugging ijkplayer(native modules) on Android Studio 2.2+: (experimental)
#     sh android/patch-debugging-with-lldb.sh armv7a
#     Install Android Studio 2.2(+)
#     Preference -> Android SDK -> SDK Tools
#     Select (LLDB, NDK, Android SDK Build-tools,Cmake) and install
#     Open an existing Android Studio project
#     Select android/ijkplayer
#     Sync Project with Gradle Files
#     Run -> Edit Configurations -> Debugger -> Symbol Directories
#     Add "ijkplayer-armv7a/.externalNativeBuild/ndkBuild/release/obj/local/armeabi-v7a" to Symbol Directories
#     Run -> Debug 'ijkplayer-example'
#     if you want to reverse patches:
#     sh patch-debugging-with-lldb.sh reverse armv7a
#
# Eclipse: (obselete)
#     File -> New -> Project -> Android Project from Existing Code
#     Select android/ and import all project
#     Import appcompat-v7
#     Import preference-v7
#
# Gradle
#     cd ijkplayer
#     gradle

```


### Build iOS
```
git clone https://github.com/Bilibili/ijkplayer.git ijkplayer-ios
cd ijkplayer-ios
git checkout -B latest k0.8.8

./init-ios.sh

cd ios
./compile-ffmpeg.sh clean
./compile-ffmpeg.sh all

# Demo
#     open ios/IJKMediaDemo/IJKMediaDemo.xcodeproj with Xcode
# 
# Import into Your own Application
#     Select your project in Xcode.
#     File -> Add Files to ... -> Select ios/IJKMediaPlayer/IJKMediaPlayer.xcodeproj
#     Select your Application's target.
#     Build Phases -> Target Dependencies -> Select IJKMediaFramework
#     Build Phases -> Link Binary with Libraries -> Add:
#         IJKMediaFramework.framework
#
#         AudioToolbox.framework
#         AVFoundation.framework
#         CoreGraphics.framework
#         CoreMedia.framework
#         CoreVideo.framework
#         libbz2.tbd
#         libz.tbd
#         MediaPlayer.framework
#         MobileCoreServices.framework
#         OpenGLES.framework
#         QuartzCore.framework
#         UIKit.framework
#         VideoToolbox.framework
#
#         ... (Maybe something else, if you get any link error)
# 
```


### Support (支持) ###
- Please do not send e-mail to me. Public technical discussion on github is preferred.
- 请尽量在 github 上公开讨论[技术问题](https://github.com/bilibili/ijkplayer/issues)，不要以邮件方式私下询问，恕不一一回复。


### License

```
Copyright (c) 2017 Bilibili
Licensed under LGPLv2.1 or later
```

ijkplayer required features are based on or derives from projects below:
- LGPL
  - [FFmpeg](http://git.videolan.org/?p=ffmpeg.git)
  - [libVLC](http://git.videolan.org/?p=vlc.git)
  - [kxmovie](https://github.com/kolyvan/kxmovie)
  - [soundtouch](http://www.surina.net/soundtouch/sourcecode.html)
- zlib license
  - [SDL](http://www.libsdl.org)
- BSD-style license
  - [libyuv](https://code.google.com/p/libyuv/)
- ISC license
  - [libyuv/source/x86inc.asm](https://code.google.com/p/libyuv/source/browse/trunk/source/x86inc.asm)

android/ijkplayer-exo is based on or derives from projects below:
- Apache License 2.0
  - [ExoPlayer](https://github.com/google/ExoPlayer)

android/example is based on or derives from projects below:
- GPL
  - [android-ndk-profiler](https://github.com/richq/android-ndk-profiler) (not included by default)

ios/IJKMediaDemo is based on or derives from projects below:
- Unknown license
  - [iOS7-BarcodeScanner](https://github.com/jpwiddy/iOS7-BarcodeScanner)

ijkplayer's build scripts are based on or derives from projects below:
- [gas-preprocessor](http://git.libav.org/?p=gas-preprocessor.git)
- [VideoLAN](http://git.videolan.org)
- [yixia/FFmpeg-Android](https://github.com/yixia/FFmpeg-Android)
- [kewlbear/FFmpeg-iOS-build-script](https://github.com/kewlbear/FFmpeg-iOS-build-script) 

### Commercial Use
ijkplayer is licensed under LGPLv2.1 or later, so itself is free for commercial use under LGPLv2.1 or later

But ijkplayer is also based on other different projects under various licenses, which I have no idea whether they are compatible to each other or to your product.

[IANAL](https://en.wikipedia.org/wiki/IANAL), you should always ask your lawyer for these stuffs before use it in your product.
