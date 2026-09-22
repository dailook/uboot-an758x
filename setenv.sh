export PATH="$(pwd)/aarch64-linux-musl-cross/bin:$PATH"
export CROSS_COMPILE=aarch64-linux-musl-
export ARM32_CROSS_COMPILE=arm-none-eabi-
export MBEDTLS_DIR="$(pwd)/mbedtls-3.4.1"
export BUILD_JOBS=$(nproc)
