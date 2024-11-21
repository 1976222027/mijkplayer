#!/bin/bash

set -e
set +x

FF_TARGET=$1

if [ -z "$FF_TARGET" ]; then
    echo "You must specific an architecture 'arm64, armv7a, x86, x86_64, ...'.\n"
    exit 1
fi

# 设置目标架构和API级别  
API_LEVEL=
TARGET_HOST=
TARGET_ABI=
FF_ACT_ARCHS_ALL="armv7a arm64 x86 x86_64"
case "$FF_TARGET" in
    armv7a)
	API_LEVEL=16
	TARGET_HOST=armv7a-linux-androideabi
	TARGET_ABI=armeabi-v7a
    ;;
    arm64)
        API_LEVEL=21
        TARGET_HOST=aarch64-linux-android
        TARGET_ABI=arm64-v8a
    ;;
    x86)
	API_LEVEL=16
	TARGET_HOST=i686-linux-android
	TARGET_ABI=x86
    ;;
    x86_64)
    	API_LEVEL=21
    	TARGET_HOST=x86_64-linux-android
    	TARGET_ABI=x86_64
    ;;
    clean)
        echo "$FF_ACT_ARCHS_ALL"
        for ARCH in $FF_ACT_ARCHS_ALL
        do
            if [ -d libsoxr-$ARCH ]; then
                cd libsoxr-$ARCH && git clean -xdf && cd -
            fi
        done
        rm -rf ./build/libsoxr-*
    ;;
    check)
        echo "$FF_ACT_ARCHS_ALL"
    ;;
    *)
        echo "$FF_ACT_ARCHS_ALL"
        exit 1
    ;;
esac

# 设置NDK路径  
NDK_PATH=/home/mahongyin/Android/Sdk/ndk/ndk14

# 设置SoXr源代码路径  
SOXR_SRC_PATH=./libsoxr-$FF_TARGET
  
# 设置编译输出目录  
OUTPUT_DIR=$PWD/build/libsoxr-$FF_TARGET/output  
mkdir -p $OUTPUT_DIR/lib
  
# 配置编译参数  
CFLAGS="-fPIC -std=c++11"
LDFLAGS="-static-libstdc++"

# 配置交叉编译工具链  
TOOLCHAIN=$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64  
SYSROOT=$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/sysroot  
CROSS_COMPILE=$TOOLCHAIN/bin/$TARGET_HOST$API_LEVEL-clang++
CXX=$CROSS_COMPILE  
CC=$CROSS_COMPILE
CXXFLAGS="--sysroot=$SYSROOT $CFLAGS -O3 -funroll-loops"  
LDFLAGS="--sysroot=$SYSROOT $LDFLAGS"  

# 编译SoXr静态库  
cd $SOXR_SRC_PATH  
mkdir -p build-$FF_TARGET && cd build-$FF_TARGET
# cmake是build的上级目录
# CMAKE_MODULE_PATH：指定要搜索的CMake模块的目录如果指定了CMAKE_MODULE_PATH,就可以直接include该目录下的.cmake文件。
# CMAKE_INSTALL_PREFIX：指定安装目标的根目录。CMAKE_PREFIX_PATH：指定要搜索的库文件和头文件的目录,也就是外部引用的。
# -DANDROID_PLATFORM=android-21 -DANDROID_ABI=arm64-v8a -DSOXR_WITHOUT_TESTS=OFF 
cmake -DCMAKE_CXX_FLAGS=$CXXFLAGS -DCMAKE_C_FLAGS=$CFLAGS -DCMAKE_EXE_LINKER_FLAGS=$LDFLAGS -DCMAKE_MODULE_LINKER_FLAGS=$LDFLAGS \
-DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR -DSOXR_WITHOUT_TESTS=OFF -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release ..
make -j4
#cp src/libsoxr.a $OUTPUT_DIR/lib/libsoxr.a
# 安装SoXr库到编译输出目录  可选的模块libsoxr-lsr.a
make install
cd ..
rm -rf build-$FF_TARGET
cd ..
