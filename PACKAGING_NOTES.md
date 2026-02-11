# 打包问题与处理记录

本文记录在 Windows 环境下对 ImageHash 进行构建/打包时遇到的错误与对应处理方式，便于复现与排查。

## 1) 缺失 bitSpaceControls 依赖

**报错**  
Broken dependency: bitSpaceControls

**原因**  
上游项目文件里仍声明了 bitSpaceControls 包依赖，但仓库内没有该包，也没有子模块指向。

**处理**  
在项目文件中移除该 RequiredPackages 条目，仅保留 LCL。

## 2) 缺失 sortbase.pas

**报错**  
Fatal: Can't find unit sortbase used by uThreadClassifier

**原因**  
上游在较新的提交中新增了 sortbase.pas，但当前下载包中不存在该文件。

**处理**  
补充 sortbase.pas 到工程根目录。

## 3) x86_64 下 POPCNT 内联汇编错误

**报错**  
Asm: [popcnt reg64,reg32] invalid combination of opcode and operands

**原因**  
uUtils 中使用了手写 POPCNT 汇编，在当前 FPC 版本/目标平台组合下不兼容。

**处理**  
将 GetBitCount32/64 改为 System.PopCnt 实现。

## 4) 缺失 uProgramInfoDialog / InfoDialog1

**报错**  
Can't find unit uProgramInfoDialog used by uFrmMain  
Identifier not found "TInfoDialog"

**原因**  
该对话框单元不在源码包中。

**处理**  
移除 uProgramInfoDialog 引用，并将按钮逻辑改回 MessageDlg，删除 lfm 中的 InfoDialog1 组件。

## 5) 缺失 uwinImports / OpenFolderAndSelectFile

**报错**  
Can't find unit uwinImports used by uFrmMain  
Identifier not found "OpenFolderAndSelectFile"

**原因**  
源码包里缺少 uwinImports 单元；该函数只用于“打开所在目录并选中文件”。

**处理**  
在 uFrmMain 内实现简化函数，使用 OpenDocument 打开文件所在目录。

## 6) 启动时报 ConcurrentMM 运行时错误

**报错**  
Runtime error 216 at $XXXXXXXX  
PoolInitialize, line 308 of lib/ConcurrentMM/ConcMM.pas

**原因**  
ConcurrentMM 在当前环境下初始化失败，导致程序启动即崩溃。

**处理**  
从 ImageHash.lpr 的 uses 中移除 ConcMM，恢复使用 FPC 默认内存管理器。

## 7) Win32 链接阶段无法写入可执行文件

**报错**  
Can't create object file: ...\bin_i386\ImageHash.exe (error code: 5)

**原因**  
可执行文件被占用（上一轮运行未退出或被其他进程锁定）。

**处理**  
结束占用进程并删除旧的 ImageHash.exe 后重新编译。

## 8) 打包时压缩包被占用

**报错**  
Compress-Archive: 存档文件已存在或正由另一进程使用

**原因**  
压缩包在资源管理器预览或被其他进程占用。

**处理**  
关闭占用进程后重新打包，或改用新文件名输出。

## 产物

Win64 构建输出位于 bin_x86_64，打包包含：

- ImageHash.exe
- libturbojpeg-0.dll
- README.md
