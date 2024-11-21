#!/bin/bash

set -e
set +x

FF_ARCH=$1

if [ -z "$FF_ARCH" ]; then
    echo "You must specific an architecture 'arm64, armv7a, x86, x86_64, ...'."
    echo ""
    exit 1
fi
FF_BUILD_ROOT=$(pwd) # $PWD
FF_BUILD_NAME=ffmpeg-$FF_ARCH
FF_BUILD_NAME_OPENSSL=openssl-$FF_ARCH
FF_BUILD_NAME_LIBSOXR=libsoxr-$FF_ARCH
# ffmpeg对于abi源码目录
FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME
# 各abi单独拼接参数
FF_CFG_FLAGS=
FF_EXTRA_CFLAGS=
FF_EXTRA_LDFLAGS=

CPU=
ARCH=
API=
CROSS_PREFIX=
CC=
CXX=
OPTIMIZE_CFLAGS=

TOOLCHAIN=/home/mahongyin/Android/Sdk/ndk/23.2.8568313/toolchains/llvm/prebuilt/linux-x86_64
SYSROOT=$TOOLCHAIN/sysroot
# 附属于ldflags，用于启用libsoxr\openssl拼接参数
FF_DEP_LIBS=
#--------------------
# 用于结束后合并so
FF_MODULE_DIRS="compat libavcodec libavfilter libavformat libavutil libswresample libswscale"
FF_ASSEMBLER_SUB_DIRS=
#--------------------
FF_ACT_ARCHS_ALL="armv7a arm64 x86 x86_64"
#FF_MAKE_TOOLCHAIN_FLAGS="--system=linux-x86_64 --install-dir=$TOOLCHAIN"
# build目录
BUILD_DIR=$FF_BUILD_ROOT/build
FF_PREFIX=$BUILD_DIR/$FF_BUILD_NAME/output
#--prefix路径：必须先创建
if [ ! -d $FF_PREFIX ]; then
    mkdir -p $FF_PREFIX
fi

FF_DEP_OPENSSL_INC=$BUILD_DIR/$FF_BUILD_NAME_OPENSSL/output/include
FF_DEP_OPENSSL_LIB=$BUILD_DIR/$FF_BUILD_NAME_OPENSSL/output/lib
FF_DEP_LIBSOXR_INC=$BUILD_DIR/$FF_BUILD_NAME_LIBSOXR/output/include
FF_DEP_LIBSOXR_LIB=$BUILD_DIR/$FF_BUILD_NAME_LIBSOXR/output/lib
FF_CFLAGS="-O3 -Wall -pipe \
    -std=c99 \
    -ffast-math \
    -fstrict-aliasing -Werror=strict-aliasing \
    -Wno-psabi -Wa,--noexecstack \
    -DANDROID -DNDEBUG"

#--------------------

echo_usage() {
    echo "Usage:"
    echo "  build_ffmpeg.sh armv7a|arm64|x86|x86_64"
    echo "  build_ffmpeg.sh clean"
    echo "  build_ffmpeg.sh check"
    exit 1
}

case "$FF_ARCH" in
armv7a)
    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=arm --cpu=cortex-a8"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-neon"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-thumb"
    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS -Wl,--fix-cortex-a8"
    FF_ASSEMBLER_SUB_DIRS="arm"

    CPU=armv7-a
    ARCH=arm
    API=16
    CROSS_PREFIX=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-
    CC=${CROSS_PREFIX}clang
    CXX=CC=${CROSS_PREFIX}clang++
    OPTIMIZE_CFLAGS="-march=$CPU"
    #build_start

    ;;
arm64)
    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=aarch64 --enable-yasm"
    FF_EXTRA_CFLAGS="-march=arm64 $FF_EXTRA_CFLAGS"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"
    FF_ASSEMBLER_SUB_DIRS="aarch64 neon"

    CPU=armv8-a
    ARCH=arm64
    API=21
    CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android$API-
    CC=${CROSS_PREFIX}clang
    CXX=CC=${CROSS_PREFIX}clang++
    OPTIMIZE_CFLAGS="-march=$CPU"
    #build_start
    ;;
x86)
    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=x86 --cpu=i686 --enable-yasm"
    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=i686 -msse3 -ffast-math -mfpmath=sse" # -march=atom
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"
    FF_ASSEMBLER_SUB_DIRS="x86"

    CPU=x86
    ARCH=x86
    API=16
    CROSS_PREFIX=$TOOLCHAIN/bin/i686-linux-android$API-
    CC=${CROSS_PREFIX}clang
    CXX=CC=${CROSS_PREFIX}clang++
    OPTIMIZE_CFLAGS="-march=i686"
    ADDITIONAL_CONFIGURE_FLAG=--disable-asm
    #build_start
    ;;
x86_64)
    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=x86_64 --enable-yasm"
    FF_EXTRA_CFLAGS="-march=x86_64 $FF_EXTRA_CFLAGS"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"
    FF_ASSEMBLER_SUB_DIRS="x86"

    CPU=x86-64
    ARCH=x86_64
    API=21
    CROSS_PREFIX=$TOOLCHAIN/bin/x86_64-linux-android$API-
    CC=${CROSS_PREFIX}clang
    CXX=CC=${CROSS_PREFIX}clang++
    OPTIMIZE_CFLAGS="-march=$CPU"
    #build_start
    ;;
clean)
    echo "clean $FF_ACT_ARCHS_ALL"
    for ARCH in $FF_ACT_ARCHS_ALL; do
        if [ -d ffmpeg-$ARCH ]; then
            cd ffmpeg-$ARCH && git clean -xdf && cd -
        fi
    done
    rm -rf ./build/ffmpeg-*
    ;;
check)
    echo "$FF_ACT_ARCHS_ALL"
    ;;
*)
    echo_usage
    exit 1
    ;;
esac

#----------
# ijkffmpeg公共配置
export COMMON_FF_CFG_FLAGS=
. $FF_BUILD_ROOT/../../config/module.sh

#--------------------
# with openssl
if [ -f "${FF_DEP_OPENSSL_LIB}/libssl.a" ]; then
    echo "OpenSSL detected"
    # FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-nonfree"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-openssl"

    FF_CFLAGS="$FF_CFLAGS -I${FF_DEP_OPENSSL_INC}"
    FF_DEP_LIBS="$FF_DEP_LIBS -L${FF_DEP_OPENSSL_LIB} -lssl -lcrypto"
fi
#--------------------
# with libsoxr
if [ -f "${FF_DEP_LIBSOXR_LIB}/libsoxr.a" ]; then
    echo "libsoxr detected"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-libsoxr"

    FF_CFLAGS="$FF_CFLAGS -I${FF_DEP_LIBSOXR_INC}"
    FF_DEP_LIBS="$FF_DEP_LIBS -L${FF_DEP_LIBSOXR_LIB} -lsoxr"
fi

#拼接公共配置
FF_CFG_FLAGS="$FF_CFG_FLAGS $COMMON_FF_CFG_FLAGS"

#--------------------
# Standard options:
FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$FF_PREFIX"

# Advanced options (experts only):
FF_CFG_FLAGS="$FF_CFG_FLAGS --cross-prefix=$CROSS_PREFIX"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-cross-compile"
FF_CFG_FLAGS="$FF_CFG_FLAGS --target-os=android" #linux
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-pic"
# FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-symver"

if [ "$FF_ARCH" = "x86" ]; then
    FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-asm"
else
    # Optimization options (experts only):
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-asm"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-inline-asm"
fi

# 开启debug的话 --disable-optimizations --disable-small
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-optimizations"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-debug"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-small"

#--------------------

function build_start() {
    echo "build $FF_ARCH"
    make clean
    ./configure --target-os=android \
        --prefix=$FF_PREFIX \
        --arch=$ARCH \
        --cpu=$CPU \
        --cc=$CC \
        --cxx=$CXX \
        --cpu=$CPU \
        --strip=$TOOLCHAIN/bin/llvm-strip \
        --nm=$TOOLCHAIN/bin/llvm-nm \
        --enable-shared \
        --disable-static \
        --enable-gpl \
        --cross-prefix=$CROSS_PREFIX \
        --enable-cross-compile \
        --sysroot=$SYSROOT \
        --extra-cflags="-Os -fpic $OPTIMIZE_CFLAGS" \
        --extra-ldflags="$ADDI_LDFLAGS" \
        $ADDITIONAL_CONFIGURE_FLAG
    make -j8
    make install
}

#--------------------
echo ""
echo "--------------------"
echo "[*] configurate ffmpeg"
echo "--------------------"
cd $FF_SOURCE
if [ -f "./config.h" ]; then
    echo 'reuse configure'
else
    which $CC
    ./configure $FF_CFG_FLAGS \
        --arch=$ARCH \
        --cpu=$CPU \
        --cc=$CC \
        --cxx=$CXX \
        --cpu=$CPU \
        --strip=$TOOLCHAIN/bin/llvm-strip \
        --nm=$TOOLCHAIN/bin/llvm-nm \
        --sysroot=$SYSROOT \
        --extra-cflags="-Os -fpic $FF_CFLAGS $FF_EXTRA_CFLAGS" \
        --extra-ldflags="$FF_DEP_LIBS $FF_EXTRA_LDFLAGS"
    make clean
fi

#--------------------
echo ""
echo "--------------------"
echo "[*] compile ffmpeg"
echo "--------------------"
cp config.* $FF_PREFIX
make -j4
make install
# 合并so
mkdir -p $FF_PREFIX/include/libffmpeg
cp -f config.h $FF_PREFIX/include/libffmpeg/config.h

#--------------------
echo ""
echo "--------------------"
echo "[*] link ffmpeg"
echo "--------------------"
echo $FF_EXTRA_LDFLAGS

FF_C_OBJ_FILES=
FF_ASM_OBJ_FILES=
for MODULE_DIR in $FF_MODULE_DIRS; do
    C_OBJ_FILES="$MODULE_DIR/*.o"
    if ls $C_OBJ_FILES 1>/dev/null 2>&1; then
        echo "link $MODULE_DIR/*.o"
        FF_C_OBJ_FILES="$FF_C_OBJ_FILES $C_OBJ_FILES"
    fi

    for ASM_SUB_DIR in $FF_ASSEMBLER_SUB_DIRS; do
        ASM_OBJ_FILES="$MODULE_DIR/$ASM_SUB_DIR/*.o"
        if ls $ASM_OBJ_FILES 1>/dev/null 2>&1; then
            echo "link $MODULE_DIR/$ASM_SUB_DIR/*.o"
            FF_ASM_OBJ_FILES="$FF_ASM_OBJ_FILES $ASM_OBJ_FILES"
        fi
    done
done

$CC -lm -lz -shared --sysroot=$FF_SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FF_EXTRA_LDFLAGS \
    -Wl,-soname,libijkffmpeg.so \
    $FF_C_OBJ_FILES \
    $FF_ASM_OBJ_FILES \
    $FF_DEP_LIBS \
    -o $FF_PREFIX/libijkffmpeg.so

mysedi() {
    f=$1
    exp=$2
    n=$(basename $f)
    cp $f /tmp/$n
    sed $exp /tmp/$n >$f
    rm /tmp/$n
}

echo ""
echo "--------------------"
echo "[*] create files for shared ffmpeg"
echo "--------------------"
rm -rf $FF_PREFIX/shared
mkdir -p $FF_PREFIX/shared/lib/pkgconfig
ln -s $FF_PREFIX/include $FF_PREFIX/shared/include
ln -s $FF_PREFIX/libijkffmpeg.so $FF_PREFIX/shared/lib/libijkffmpeg.so
cp $FF_PREFIX/lib/pkgconfig/*.pc $FF_PREFIX/shared/lib/pkgconfig
for f in $FF_PREFIX/lib/pkgconfig/*.pc; do
    # in case empty dir
    if [ ! -f $f ]; then
        continue
    fi
    cp $f $FF_PREFIX/shared/lib/pkgconfig
    f=$FF_PREFIX/shared/lib/pkgconfig/$(basename $f)
    # OSX sed doesn't have in-place(-i)
    mysedi $f 's/\/output/\/output\/shared/g'
    mysedi $f 's/-lavcodec/-lijkffmpeg/g'
    mysedi $f 's/-lavfilter/-lijkffmpeg/g'
    mysedi $f 's/-lavformat/-lijkffmpeg/g'
    mysedi $f 's/-lavutil/-lijkffmpeg/g'
    mysedi $f 's/-lswresample/-lijkffmpeg/g'
    mysedi $f 's/-lswscale/-lijkffmpeg/g'
done
