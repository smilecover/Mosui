# MosUI 项目长期记忆

## 项目基本信息
- **项目名：** MosUI —— Qt6 QML 桌面端 UI 组件库
- **技术栈：** Qt6 / QML / C++ / CMake / QWindowKit
- **架构：** 动态库（MosuiBasic），URI `MosuiBasic`，输出到 `shared/` 目录

## 核心模块
- **MosTheme**：基于 JSON Token 的主题引擎，支持亮/暗/系统跟随，Pimpl 设计
- **MosRectangle**：QQuickPaintedItem，支持四角独立圆角、渐变、边框
- **MosWindowAgent**：封装 QWindowKit QuickWindowAgent，无边框窗口
- **MosColorGenerator**：Ant Design 风格色阶生成
- **MosSystemThemeHelper**：系统主题变化检测（timerEvent 轮询）

## 已知待修复问题（2026-04-10 审查）
- MosApp 字体路径错误：`:/HuskarUI/...` → `:/MosuiBasic/...`
- MosWindowAgent::classBegin() + QML onCompleted 双重 setup() 调用
- MosRectangle::border() 使用私有 API QQml_setParent_noEvent
- MosWindow.qml 使用未声明属性 showWhenReady（从 qwindowkit 示例复制未清理）
- MosCaptionbar.qml 完全空实现，无标题、无按钮
- MOSUI_PROPERTY_READONLY 宏：成员变量未值初始化

## 主题文件路径
- 主题主文件：`:/theme/theme/main.json`（硬编码，与项目资源前缀不一致）
