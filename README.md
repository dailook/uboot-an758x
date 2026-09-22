# AN758x U-Boot

U-Boot for Airoha AN7581/AN7583 with a bilingual Web recovery interface.

面向 Airoha AN7581/AN7583 的 U-Boot，集成中英文 Web 恢复页面。

Hold Reset about one second after power-on to enter Web recovery.

上电约一秒后按住 Reset，即可进入 Web 恢复页面。

## Supported devices / 支持机型

| Target / 构建目标 | Device / 设备 | SoC | Storage / 存储 |
| --- | --- | --- | --- |
| `hg5382a` | FiberHome HG5382A | AN7581 | Parallel NAND |
| `hg5585f-ct` | FiberHome HG5585F CT | AN7581 | Parallel NAND |
| `hg5585f-cu` | FiberHome HG5585F CU | AN7581 | Parallel NAND |
| `xg2010g` | Gemtek XG2010G | AN7581 | SPI NAND |
| `zn504xg-d` | ZNXT ZN504XG-D | AN7581 | SPI NAND |
| `zn515xg-d` | ZNXT ZN515XG-D | AN7581 | SPI NAND |
| `ung00a` | UnionMan UNG00A | AN7581 | SPI NAND |
| `xg-040g-md` | Nokia XG-040G-MD | AN7581 | SPI NAND |
| `xg-040g-tf` | Nokia XG-040G-TF | AN7581 | SPI NAND |
| `xg-040g-mf` | Nokia XG-040G-MF | AN7583 | SPI NAND |

## Build / 构建

### Quick start / 一键编译完整流程

The whole build, from a fresh machine to finished images — copy and
paste as one block (apt password prompt aside):

从干净系统到出镜像的完整流程，可整段复制执行（中途会提示输入
sudo 密码）：

```sh
# 1. Clone this repository / 克隆仓库
#    （工具链、mbed TLS 和 build.sh 均已内置）
git clone https://github.com/dailook/uboot-an758x.git

# 2. Install the only host dependency / 安装唯一的宿主依赖
sudo apt install gcc-arm-none-eabi        # Debian / Ubuntu

# 3. Build with one command / 一键编译命令
cd uboot-an758x                           # 进入 uboot 源码目录
# 以 hg5585f-ct 为例 / take hg5585f-ct as an example
./build.sh hg5585f-ct

# 4. Artifacts / 编译完成后产物在 output/ 目录
ls output/hg5585f-ct/

# 5. 后续需要编译只需一键命令 /以下以hg5585f-ct机型为例
./build.sh hg5585f-ct
```

> `build.sh` sources `setenv.sh` internally, so no manual environment
> setup is needed. / `build.sh` 内部会自动加载 `setenv.sh`，无需手动
> 设置环境变量。

The aarch64 musl toolchain (`aarch64-linux-musl-cross/`) and mbed TLS
3.4.1 (`mbedtls-3.4.1/`) are **bundled in this repository** — no download
needed. Do not replace them with other versions.

aarch64 musl 工具链（`aarch64-linux-musl-cross/`）和 mbed TLS 3.4.1
（`mbedtls-3.4.1/`）**已随仓库自带，无需下载**。请勿换成其他版本。

### 1. Prerequisites / 准备依赖

Only one host package is required — the 32-bit ARM bare-metal toolchain
for the BL2/SPL stage:

除了克隆本仓库外，只需要安装一个宿主软件包——用于编译 32 位
BL2/SPL 阶段的裸机工具链：

```sh
sudo apt install gcc-arm-none-eabi     # Debian / Ubuntu
```

> **Keep mbed TLS at 3.4.x.** The bundled TF-A makefiles compile
> `library/hash_info.c`, which exists only in mbed TLS 3.2–3.5.
> The 3.6 LTS series removed that file — do not "upgrade" it.
>
> **mbed TLS 必须保持 3.4.x。** 本仓库自带的 TF-A makefile 会编译
> `library/hash_info.c`，该文件只存在于 mbed TLS 3.2~3.5；
> 3.6 LTS 系列已将其移除，请勿"升级"它。

### 2. Build / 编译

```sh
cd ~/uboot-an758x
./build.sh hg5585f-ct
```

`build.sh` does three things internally / `build.sh` 内部做三件事：

1. `cd` to the repository root (works from any directory) /
   进入仓库根目录（在任意目录下调用均可）
2. source `setenv.sh` to set the cross-compile environment /
   加载 `setenv.sh` 设置交叉编译环境
3. run `scripts/build-an758x.sh` with your target / 
   以指定目标运行 `scripts/build-an758x.sh`

To build for a different device, replace the target name
(see the table above). For example / 编译其他机型时替换目标名
（见上方支持机型表），例如：

```sh
./build.sh hg5382a
```

### Manual build (optional) / 手动编译（可选）

If you prefer to run the steps yourself instead of using `build.sh` /
如果不想用 `build.sh`，也可以手动分步执行：

```sh
cd ~/uboot-an758x
. ./setenv.sh                       # source 方式加载环境（点号+空格！）
./scripts/build-an758x.sh hg5585f-ct
```

> **Why `. ./setenv.sh` and not `./setenv.sh`?** The leading dot runs
> the script in the current shell so the exported variables persist;
> `./setenv.sh` would run it in a subshell and the variables would be
> lost (the build then fails with `CROSS_COMPILE is required`).
>
> **为什么要 `. ./setenv.sh` 而不是 `./setenv.sh`？** 前面的点号让脚本
> 在当前 shell 中执行，导出的变量才会保留；直接 `./setenv.sh` 会在
> 子 shell 中执行，变量随之丢失（编译时报
> `CROSS_COMPILE is required`）。

Before building manually, it is worth verifying that the cross
compilers are picked up — an empty `CROSS_COMPILE` silently falls
back to the host `gcc`:

手动编译前建议验证交叉编译器是否生效——`CROSS_COMPILE` 为空时会
**静默**回退到宿主机 `gcc`：

```sh
${CROSS_COMPILE}gcc --version
# Must print "aarch64-linux-musl-gcc", NOT your host distro name.
# 应打印 aarch64-linux-musl-gcc，不能出现宿主发行版字样。

ls $MBEDTLS_DIR/library/hash_info.c
# Must succeed. / 必须存在。
```

Artifacts are written to `output/<target>/` / 产物位于 `output/<target>/`

Expected outputs / 预期产物：

- `*-firstblock.bin` — BL2 image written at NAND offset `0x0`
- `*-preloader.bin` — BL2 image written at NAND offset `0x800`
  (first `0x800` bytes stay erased / 前 `0x800` 字节保持擦除态)
- `*-bl31-u-boot.fip` — FIP containing BL31 + U-Boot, sent via XMODEM

### Troubleshooting / 常见问题

| Symptom / 现象 | Cause / 原因 | Fix / 解决 |
| --- | --- | --- |
| `CROSS_COMPILE is required` | Ran `scripts/build-an758x.sh` without environment; or `./setenv.sh` used instead of `. ./setenv.sh` / 没带环境直接跑构建脚本，或用了 `./setenv.sh` 而非 source 方式 | Use `./build.sh <target>`, or source with `. ./setenv.sh` first / 使用 `./build.sh <目标>`，或先用 `. ./setenv.sh` |
| `bash: ./build.sh: 权限不够` | File not executable / 文件没有执行权限 | `chmod +x build.sh` / 加上执行权限 |
| Version check prints host gcc (e.g. "Deepin 12.3.0") | `CROSS_COMPILE` is empty; `${CROSS_COMPILE}gcc` silently runs host gcc / 变量为空，静默调用宿主机 gcc | Re-export the variables and verify again / 重新 source 并再次验证 |
| `${CROSS_COMPILE}gcc` → "command not found" | Missing braces: `$CROSS_COMPILEgcc` is parsed as one variable name / 少了大括号，`$CROSS_COMPILEgcc` 被当作一个变量名 | Use `${CROSS_COMPILE}gcc` / 使用大括号写法 |
| TF-A link fails: `library/hash_info.c: No such file or directory` | mbed TLS was replaced with 3.6.x, which removed `hash_info.c` / mbed TLS 被换成了 3.6.x，该版本移除了此文件 | Restore the bundled `mbedtls-3.4.1/` — do not upgrade / 恢复仓库自带的 mbedtls-3.4.1，勿升级 |
| BL31 link fails with many missing `.o` (dramc.o, Hal_io.o, ...) | Incomplete copy of this repo — the DDR blobs under `tf-a/plat/ecnt/an7581/bl31/` are missing / 仓库拷贝不完整，DDR 二进制缺失 | Re-clone with `git clone`; verify `ls tf-a/plat/ecnt/an7581/bl31/*.o \| wc -l` prints 23 / 重新完整克隆，验证该目录有 23 个 .o 文件 |

## Installation / 刷入

1### Automatic / 自动刷机

Run [AN758x-Stock2UBI](https://github.com/pbs05/an758x-stock2ubi) from the
stock system. Back up the needed partitions, then upload `*-preloader.bin` or
`*-firstblock.bin` together with
`*-bl31-u-boot.fip`. The tool writes the recovery bootloader and reboots.<br>
在原厂系统中运行 [AN758x-Stock2UBI](https://github.com/pbs05/an758x-stock2ubi)，
备份需要保留的分区，然后上传 `*-preloader.bin` 或 `*-firstblock.bin`，以及
`*-bl31-u-boot.fip`。工具写入恢复引导后自动重启。

### Manual / 手动刷机

1. Back up every MTD partition and UBI volume.<br>
   备份全部 MTD 分区和 UBI 卷。
2. Write one BL2 image at the beginning of NAND:<br>
   在 NAND 开头写入以下一种 BL2 镜像：

   - Write `*-firstblock.bin` from NAND offset `0x0`.<br>
     从 NAND `0x0` 偏移写入 `*-firstblock.bin`。
   - Leave the first `0x800` bytes erased and write `*-preloader.bin` from
     NAND offset `0x800`.<br>
     保持前 `0x800` 字节为擦除态，从 NAND `0x800` 偏移写入
     `*-preloader.bin`。
3. Boot the device. When BL2 requests a FIP, press `x` and send
   `*-bl31-u-boot.fip` through XMODEM.<br>
   启动设备；BL2 请求 FIP 时按 `x`，通过 XMODEM 发送
   `*-bl31-u-boot.fip`，临时进入 U-Boot。

With either method, connect Ethernet and open `http://192.168.0.1/` (the first
boot may take about one minute). For the first installation, select
**Rebuild UBI / 重建 UBI**, then write `*-bl31-u-boot.fip`, restore the board-data
volumes, upload the sysupgrade image, and select **Boot system / 启动系统**.<br>
通过以上任一方法进入 U-Boot 后，连接网线并打开 `http://192.168.0.1/`（首次启动
可能需要约一分钟）。首次安装选择 **重建 UBI**，随后写入 `*-bl31-u-boot.fip`、
恢复板级数据卷、上传 sysupgrade 镜像，最后选择 **启动系统**。

Subsequent upgrades use **Install system / 刷写系统** directly.

后续升级直接使用 **刷写系统**。

## TF-A sources / TF-A 来源

- [Ansuel/atf-airoha](https://github.com/Ansuel/atf-airoha)
- [mkshevetskiy/atf-airoha](https://github.com/mkshevetskiy/atf-airoha)
- [Yuzhii0718/atf-airoha](https://github.com/Yuzhii0718/atf-airoha)
