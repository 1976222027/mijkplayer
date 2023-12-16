### Build Android

Android SDK 21及以下版本支持的NDK架构：
armeabi
armeabi-v7a
x86
Android SDK 22及以上版本支持的NDK架构：
armeabi-v7a
arm64-v8a
x86
x86_64

```
git clone https://gitee.com/mahongyin/ijkplayer-ffmpeg6.1.git ijkplayer-android
cd ijkplayer-android
git checkout -B latest ffplayer

./init-android.sh

cd android/contrib
./compile-ffmpeg.sh clean
./compile-ffmpeg.sh all

cd ..
./compile-ijk.sh all