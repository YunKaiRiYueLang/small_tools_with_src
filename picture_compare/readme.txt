图片比对工具
==================================================

目录结构
  build\
      image_compare.html  ← 直接双击使用。要给别人的话，只拷这一个文件就够了。
  src\
      index.html         页面源代码（模板，含 <!--LIBS--> 占位符）
      pako.min.js        Deflate 解压库（pako 2.1.0，MIT）
      UTIF.js            TIFF 解码库（UTIF 3.1.0，MIT，已补 Adobe Deflate 32946 支持）
      build.ps1          把上面三个文件合并成 build\image_compare.html

如何使用
  双击 build\image_compare.html，用 Chrome / Edge / Firefox / Safari 打开。
  把两张图一起拖进窗口，或者点左上角「A：选择图片 / B：选择图片」。
  只拖一张也会立刻显示，补上第二张才开始比对。

如何修改后重新生成
  编辑 src\index.html，然后在 src 目录下运行：
      powershell -ExecutionPolicy Bypass -File .\build.ps1
  会重新生成 build\image_compare.html（覆盖）。

功能
  · 左 A 右 B 并排显示，同倍率缩放、拖动时三处视图同步
  · 分隔条可拖动：A/B 之间左右调宽度，图像区与底部面板之间上下调高度；
    双击分隔条恢复默认，Tab 聚焦后按方向键微调（按住 Shift 加速）
  · 差异位置图：品红标出不同像素，蓝框标出差异区域
  · 左下角像素详情（仿 Beyond Compare）：放大像素阵列 + X/Y + RGB + A + Δ
  · 容差滑杆：最大通道差 ≤ 容差视为相同，同步影响差异图与区域
  · 支持 TIFF（Deflate / Adobe Deflate / LZW / PackBits，8/16 位，多页取第 1 页）
    以及 PNG / JPG / BMP / GIF / WEBP / AVIF
  · 纯本地运行，不联网、不上传图片、不写任何文件
    （仅在浏览器本地存储里记一下分隔条位置，不涉及图片内容）

注意
  · 不要在压缩包里直接双击，先解压出来。
  · 从邮件/微信拿到后若提示被阻止：右键文件 → 属性 → 勾选「解除锁定」→ 确定。
  · 需要现代浏览器，IE 和老版 Edge 不支持。
