# MosUI

基于 Qt 6.5+ / QML 的跨平台 UI 组件库与桌面应用框架。

## 项目结构

```
Mosui/
├── MosuiBasic/          # 核心组件库 (C++ + QML)
│   ├── cpp/             # C++ 后端：控件、主题、工具、窗口管理
│   │   ├── controls/    # 自定义绘制控件 (MosRectangle, MosWatermark)
│   │   ├── theme/       # 主题系统 (色彩、尺寸、暗色模式)
│   │   ├── window/      # 无边框窗口 (基于 QWindowKit)
│   │   ├── tools/       # 工具模块 (MQTT、串口、高性能图表)
│   │   └── utils/       # 工具类 (路由、异步哈希、剪贴板)
│   ├── qml/             # QML 组件 (80+ 基础控件)
│   └── resources/       # 主题配置、字体、图片、Shader
├── Mosuiapp/            # 展示应用 / 工具应用
│   ├── Controls/        # 应用页面和示例
│   │   └── Universal/   # 控件示例页面 (Exp*.qml)
│   └── Tools/           # 逆变器 / PLC 工具页面
└── static/              # 静态库构建输出目录
```

## 构建要求

| 依赖 | 版本 | 说明 |
|------|------|------|
| Qt | ≥ 6.5 | Core, Qml, Quick, QuickControls2, WebView, Graphs, Charts, SerialPort, Mqtt |
| CMake | ≥ 3.16 | |
| C++ 标准 | C++17 | MSVC 需 `/permissive-` |
| QtWebEngine | 可选 | 用于 HomePage 玻璃雨背景效果 |

## 构建

```bash
# 动态库构建（默认）
cmake -B build -S .
cmake --build build

# 静态库构建
cmake -B build-static -S . -DMOSUIBASIC_BUILD_STATIC=ON
cmake --build build-static
```

构建产物输出到 `shared/`（动态库）或 `static/`（静态库）目录。

## 运行

```bash
# 动态库模式
cd shared && ./Mosuiapp

# 静态库模式
cd static && ./Mosuiapp
```

## 核心功能

- **80+ QML 控件**：按钮、输入框、表格、树形视图、图表、日期选择器、颜色选择器等
- **主题系统**：亮色/暗色/跟随系统，动态切换，Design Token 体系
- **无边框窗口**：基于 QWindowKit，支持亚克力/云母/模糊特效
- **MQTT 管理器**：QML 单例，支持 SSL、遗嘱消息、自动重连
- **串口管理器**：QML 单例，支持多串口并发通信
- **高性能图表**：折线图、柱状图、饼图、雷达图、散点图

## 许可证

MIT
