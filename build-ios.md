### Build iOS
```
git clone https://gitee.com/mahongyin/ijkplayer-ffmpeg6.1.git ijkplayer-ios
cd ijkplayer-ios
git checkout -B latest ffplayer

./init-ios.sh

cd ios
./compile-ffmpeg.sh clean
./compile-ffmpeg.sh all
