### Build Android

Android SDK 21以下版本支持的NDK架构：
armeabi       9+
armeabi-v7a   16+
x86
Android SDK 21及以上版本支持的NDK架构：
armeabi-v7a
arm64-v8a     21+
x86
x86_64        21+

```
配置NDK环境
 export ANDROID_NDK=...ndk/22.1.7171670

# install homebrew, git, yasm
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm
# 需要配置 SDK和NDK路径
# add these lines to your ~/.bash_profile or ~/.profile
# export ANDROID_SDK=<your sdk path>
# export ANDROID_NDK=<your ndk path>
# Cygwin下需要安装的软件
# on Cygwin (unmaintained)
# install git, make, yasm
//获取源码
git clone https://gitee.com/mahongyin/ijkplayer-ffmpeg6.1.git ijkplayer-android
cd ijkplayer-android
#git checkout -b 本地分支名 origin/远程分支名
git checkout -B latest ffplayer
```

```
cd config
rm module.sh
ln -s module-lite.sh module.sh
cd android/contrib
# cd ios
sh compile-ffmpeg.sh clean

对于Ubuntu/Debian用户。
# choose [No] to use bash
sudo dpkg-reconfigure dash
正在删除 通过 dash 从 /bin/sh 到 /bin/sh.distrib 的转移
正在添加 通过 bash 从 /bin/sh 到 /bin/sh.distrib 的转移
正在删除 通过 dash 从 /usr/share/man/man1/sh.1.gz 到 /usr/share/man/man1/sh.distrib.1.gz 的转移
正在添加 通过 bash 从 /usr/share/man/man1/sh.1.gz 到 /usr/share/man/man1/sh.distrib.1.gz 的转移
```

```
./init-android.sh
包含了【./init-android-libyuv.sh./init-android-soundtouch.sh】
./init-android-openssl.sh
./init-android-libsoxr.sh
#NDK路径，openssl需要ANDROID_NDK_ROOT变量，所以把它export一下
export ANDROID_NDK_ROOT=$HOME/Library/Android/sdk/ndk/ndk14
若是提示 ndk -build 权限不够，则需要给权限，建议给整个ndk文件夹权限。
chmod -R 777 文件夹
参数-R是递归的意思
777表示开放所有权限

cd android/contrib
./compile-openssl.sh clean
./compile-openssl.sh arm64
./compile-openssl.sh armv7a
./compile-openssl.sh x86
./compile-openssl.sh x86_64
新版编译脚本 ./build_openssl.sh all

./compile-libsoxr.sh clean
./compile-libsoxr.sh arm64
./compile-libsoxr.sh armv7a
./compile-libsoxr.sh x86
./compile-libsoxr.sh x86_64

cd android/contrib
./compile-ffmpeg.sh clean
./compile-ffmpeg.sh arm64
./compile-ffmpeg.sh armv7a
./compile-ffmpeg.sh x86
./compile-ffmpeg.sh x86_64
新版编译脚本 ./build_ffmpeg.sh all

# 到android目录
cd ..
./compile-ijk.sh all
```

