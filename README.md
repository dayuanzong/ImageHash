# ImageHash (中文优化版)

这是一个基于 Lazarus 和 FreePascal 开发的高性能图片去重/相似图片查找工具，类似 Visipics 但速度更快。

## 主要特性

- **高性能哈希算法**：采用 DHash 算法，快速准确地识别相似图片。
- **多线程处理**：充分利用多核 CPU，大幅提升扫描和对比速度。
- **原生编译**：无外部运行时依赖（除了附带的 DLL），绿色免安装。
- **中文界面与优化**：
  - 界面全面中文化。
  - **UI 优化**：耗时显示自动换算（秒/分/时/天），结果栏日志合并显示。
  - **实时反馈**：修复了运行过程中进度和日志不刷新的问题。
  - **便捷操作**：新增右键点击缩略图切换“忽略/取消忽略”状态。
  - **稳定性修复**：移除 ConcurrentMM 修复了部分系统下的启动崩溃 (Error 216) 问题。

## 下载与安装

本程序为绿色软件，无需安装。
请前往 [Releases 页面](../../tree/main/release_win64) 下载最新编译的 `release_win64` 版本，解压即可使用。

## 使用说明

1. 运行 `ImageHash.exe`。
2. 在左侧面板设置扫描路径。
3. 点击开始按钮进行扫描和哈希计算。
4. 扫描完成后，在右侧结果列表查看相似图片分组。
5. 鼠标左键点击标记删除，右键点击标记忽略。

## 鸣谢 / Credits

The image hashing algorithm (DHash) is by Dr. Neal Krawetz, who writes at Hacker Factor.
* http://www.hackerfactor.com/blog/index.php?/archives/432-Looks-Like-It.html
* http://www.hackerfactor.com/blog/index.php?/archives/529-Kind-of-Like-That.html

The TurboJPEG bindings are by D. R. Commander.
* https://www.djmaster.com/freepascal/bindings/turbojpeg.php

Original project by martok.

## License

The source code is licensed under the MIT license.
