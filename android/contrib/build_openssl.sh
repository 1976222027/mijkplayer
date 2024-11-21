#!/bin/bash

set -e
set +x

FF_TARGET=$1
FF_ACT_ARCHS_ALL="armv7a arm64 x86 x86_64"
if [ -z "$FF_TARGET" ]; then
    echo "You must specific an architecture 'arm64, armv7a, x86, x86_64, ...'.\n"
    exit 1
fi
#NDK路径，openssl需要ANDROID_NDK_ROOT变量，所以把它export一下
export ANDROID_NDK_HOME=/home/mahongyin/Android/Sdk/ndk/21.4.7075529
export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
#编译平台，我这里是mac是darwin-x86_64   linux是linux-x86_64
HOST_TAG=linux-x86_64
#Android api版本16/21/
MIN_SDK_VERSION=16
#工具链路径
TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG
#把工具链加到PATH环境变量
PATH=$TOOLCHAIN/bin:$PATH
#source ./build-env.sh

#aarch64-linux-android表示要编译armv8
#armv7a-linux-androideabi表示要编译armv7a
#i686-linux-android表示要编译x86
#x86_64-linux-android表示要编译x86_64

# 编译openssl1.1.1w
function build() {
    TARGET_HOST=$1
    ANDROID_ARCH=$2
    OPENSSL_ARCH=$3
    SDK_VERSION=$4
    #输出目录，在build目录下
    BUILD_DIR=$PWD/build/openssl-$ANDROID_ARCH 
    INSTALL_DIR=$BUILD_DIR/output
    #--prefix路径：必须先创建
    if [ ! -d $INSTALL_DIR ]; then
    	mkdir -p $INSTALL_DIR
    fi
 
    cd openssl-$ANDROID_ARCH
    echo "===================="
    echo "build $ANDROID_ARCH"
    echo "===================="
    

    export AR=$TOOLCHAIN/bin/llvm-ar
    export CC=$TOOLCHAIN/bin/$TARGET_HOST$SDK_VERSION-clang
    export AS=$CC
    export CXX=$TOOLCHAIN/bin/$TARGET_HOST$SDK_VERSION-clang++
    export LD=$TOOLCHAIN/bin/ld
    export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
    export STRIP=$TOOLCHAIN/bin/llvm-strip
#android-arm64表示编译64位的arm版本。
#no-unit-test表示不需要单元测试。
#no-shared表示不需要动态库。
    ./Configure $OPENSSL_ARCH no-unit-test no-shared -D__ANDROID_API__=$SDK_VERSION --prefix=$INSTALL_DIR
 #./config no-shared no-comp no-hw no-engine --openssldir=$INSTALL_DIR --prefix=$INSTALL_DIR
    make -j8
    make install_sw
    make distclean
    echo "===================="
    echo "[*] Finished"
    echo "===================="

}

#----------
echo_usage() {
    echo "Usage:"
    echo "  build_openssl.sh armv7a|arm64|x86|x86_64"
    echo "  build_openssl.sh all|all32"
    echo "  build_openssl.sh all64"
    echo "  build_openssl.sh clean"
    echo "  build_openssl.sh check"
    exit 1
}

case "$FF_TARGET" in
    armv7a)
	build armv7a-linux-androideabi armv7a android-arm 16
    ;;
    arm64)
        build aarch64-linux-android arm64 android-arm64 21
    ;;
    x86)
    	build i686-linux-android x86 android-x86 16
    ;;
    x86_64)
    	build x86_64-linux-android x86_64 android-x86_64 21
    ;;
    all32)
	build armv7a-linux-androideabi armv7a android-arm 16
	build i686-linux-android x86 android-x86 16
    ;;
    all|all64)
	build aarch64-linux-android arm64 android-arm64 21
	build x86_64-linux-android x86_64 android-x86_64 21
	build armv7a-linux-androideabi armv7a android-arm 16
	build i686-linux-android x86 android-x86 16
    ;;
    clean)
        echo "$FF_ACT_ARCHS_ALL"
        for ARCH in $FF_ACT_ARCHS_ALL
        do
            if [ -d openssl-$ARCH ]; then
                cd openssl-$ARCH && git clean -xdf && cd -
            fi
        done
        rm -rf ./build/openssl-*
    ;;
    check)
        echo "$FF_ACT_ARCHS_ALL"
    ;;
    *)
        echo_usage
        exit 1
    ;;
esac

