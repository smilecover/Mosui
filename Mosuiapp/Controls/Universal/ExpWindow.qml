import QtQuick
import QtQuick.Controls

import MosuiBasic

import '../../Controls'

Flickable {
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { }

    Column {
        id: column
        width: parent.width - 15
        spacing: 30

        MosDescription {
            desc: qsTr(`
# MosWindow 无边框窗口\n
跨平台无边框窗口的最佳实现，基于 [QWindowKit](https://github.com/stdware/qwindowkit)。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Window }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
effect | enum | 平台相关 | 窗口特效(来自 MosWindow)
captionBar | [MosCaptionbar](internal://MosCaptionbar) | - | 窗口标题栏
windowAgent | MosWindowAgent | - | 窗口代理
followThemeSwitch | bool | true | 是否跟随系统明/暗模式自动切换
initialized | bool | false | 指示窗口是否已经初始化完毕
rootOpacity | real | 1.0 | 窗口不透明度
windowIcon | string | '' | 窗口图标路径
captionbarcolor | color | 'transparent' | 标题栏背景色
\n<br/>
\n### 支持的函数：\n
- \`setEffect(newEffect: int): bool\` 设置窗口特效 \n
- \`setWindowMode(isDark: bool): bool\` 设置窗口明/暗模式 \n
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
当用户需要自定义窗口形态时作为基础无边框窗口使用，默认提供一个 [MosCaptionbar](internal://MosCaptionbar)。\n
支持亚克力、Mica、DWM 模糊等多种窗口特效，跨平台自适应。
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('基本')
            desc: qsTr(`
使用方法等同于 \`Window\`。\n
**注意** 不要嵌套使用 MosWindow (源于Qt的某些BUG)，应通过 \`Loader\` 动态创建，并设置 \`active: false\` 避免页面加载时立即弹出窗口。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Item {
                    height: 50

                    MosButton {
                        text: (windowLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                        type: MosButton.Type_Primary
                        onClicked: windowLoader.active = !windowLoader.active;
                    }

                    Loader {
                        id: windowLoader
                        active: false
                        sourceComponent: MosWindow {
                            width: 600
                            height: 400
                            title: qsTr('无边框窗口')
                            effect: MosWindow.Effect_None
                            captionbar.closeCallback: () => windowLoader.active = false;

                            Rectangle {
                                anchors.fill: parent
                                color: MosTheme.Primary.colorBgBase
                            }

                            MosText {
                                anchors.centerIn: parent
                                text: qsTr('Hello MosWindow!')
                                font.pixelSize: 24
                            }
                        }
                    }
                }
            `
            exampleDelegate: Item {
                height: 50

                MosButton {
                    text: (basicWindowLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                    type: MosButton.Type_Primary
                    onClicked: basicWindowLoader.active = !basicWindowLoader.active;
                }

                Loader {
                    id: basicWindowLoader
                    active: false
                    sourceComponent: MosWindow {
                        width: 600
                        height: 400
                        title: qsTr('无边框窗口')
                        effect: MosWindow.Effect_None
                        captionbar.closeCallback: () => basicWindowLoader.active = false;

                        Rectangle {
                            anchors.fill: parent
                            color: MosTheme.Primary.colorBgBase
                        }

                        MosText {
                            anchors.centerIn: parent
                            text: qsTr('Hello MosWindow!')
                            font.pixelSize: 24
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('窗口特效')
            desc: qsTr(`
通过 \`effect\` 属性设置窗口特效，支持的特效：\n
- 无特效{ MosWindow.Effect_None }\n
- DWM 模糊{ MosWindow.Effect_dwm_blur }\n
- 亚克力材质(默认 Windows){ MosWindow.Effect_acrylic_material }\n
- Mica{ MosWindow.Effect_mica }\n
- Mica Alt{ MosWindow.Effect_mica_alt }\n
- Mac 模糊(仅 macOS){ MosWindow.Effect_mac_blur }\n\n
也可以调用 \`setEffect()\` 函数动态切换特效。\n
**提示** 特效生效时窗口背景透明，需要自行添加内容背景以确保文字可读。
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10
                    property int selectedEffect: effectRadio.currentCheckedValue

                    MosRadioBlock {
                        id: effectRadio
                        initCheckedIndex: 1
                        model: [
                            { label: 'None', value: MosWindow.Effect_None },
                            { label: 'Acrylic', value: MosWindow.Effect_acrylic_material },
                            { label: 'Mica', value: MosWindow.Effect_mica },
                            { label: 'Mica Alt', value: MosWindow.Effect_mica_alt },
                            { label: 'DWM Blur', value: MosWindow.Effect_dwm_blur },
                        ]
                    }

                    MosButton {
                        type: MosButton.Type_Primary
                        text: (effectWinLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                        onClicked: effectWinLoader.active = !effectWinLoader.active;
                    }

                    Loader {
                        id: effectWinLoader
                        active: false
                        sourceComponent: MosWindow {
                            width: 500
                            height: 300
                            title: qsTr('特效窗口')
                            effect: selectedEffect
                            captionbar.closeCallback: () => effectWinLoader.active = false;

                            Rectangle {
                                anchors.fill: parent
                                color: MosTheme.Primary.colorBgBase
                                opacity: selectedEffect === MosWindow.Effect_None ? 1.0 : 0.85
                            }

                            MosText {
                                anchors.centerIn: parent
                                text: qsTr('窗口特效演示')
                                font.pixelSize: 18
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10
                property int selectedEffect: effectRadio.currentCheckedValue

                MosRadioBlock {
                    id: effectRadio
                    initCheckedIndex: 1
                    model: [
                        { label: 'None', value: MosWindow.Effect_None },
                        { label: 'Acrylic', value: MosWindow.Effect_acrylic_material },
                        { label: 'Mica', value: MosWindow.Effect_mica },
                        { label: 'Mica Alt', value: MosWindow.Effect_mica_alt },
                        { label: 'DWM Blur', value: MosWindow.Effect_dwm_blur },
                    ]
                }

                MosButton {
                    type: MosButton.Type_Primary
                    text: (effectWinLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                    onClicked: effectWinLoader.active = !effectWinLoader.active;
                }

                Loader {
                    id: effectWinLoader
                    active: false
                    sourceComponent: MosWindow {
                        width: 500
                        height: 300
                        title: qsTr('特效窗口')
                        effect: selectedEffect
                        captionbar.closeCallback: () => effectWinLoader.active = false;

                        Rectangle {
                            anchors.fill: parent
                            color: MosTheme.Primary.colorBgBase
                            opacity: selectedEffect === MosWindow.Effect_None ? 1.0 : 0.85
                        }

                        MosText {
                            anchors.centerIn: parent
                            text: qsTr('窗口特效演示')
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('标题栏定制')
            desc: qsTr(`
通过 \`captionbar\` 属性访问标题栏，可以定制图标、颜色、按钮行为等。\n
- \`captionbarcolor\` 设置标题栏背景色\n
- \`windowIcon\` 设置窗口图标\n
- \`captionbar.closeCallback\` 拦截关闭按钮行为\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Item {
                    height: 50

                    MosButton {
                        type: MosButton.Type_Primary
                        text: (captionWinLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                        onClicked: captionWinLoader.active = !captionWinLoader.active;
                    }

                    Loader {
                        id: captionWinLoader
                        active: false
                        sourceComponent: MosWindow {
                            width: 500
                            height: 300
                            title: qsTr('标题栏定制')
                            effect: MosWindow.Effect_None
                            captionbarcolor: '#1677ff'
                            captionbar.closeCallback: () => captionWinLoader.active = false;

                            Rectangle {
                                anchors.fill: parent
                                color: MosTheme.Primary.colorBgBase
                            }

                            MosText {
                                anchors.centerIn: parent
                                text: qsTr('定制标题栏颜色')
                                font.pixelSize: 18
                                color: '#1677ff'
                            }
                        }
                    }
                }
            `
            exampleDelegate: Item {
                height: 50

                MosButton {
                    type: MosButton.Type_Primary
                    text: (captionWinLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                    onClicked: captionWinLoader.active = !captionWinLoader.active;
                }

                Loader {
                    id: captionWinLoader
                    active: false
                    sourceComponent: MosWindow {
                        width: 500
                        height: 300
                        title: qsTr('标题栏定制')
                        effect: MosWindow.Effect_None
                        captionbarcolor: '#1677ff'
                        captionbar.closeCallback: () => captionWinLoader.active = false;

                        Rectangle {
                            anchors.fill: parent
                            color: MosTheme.Primary.colorBgBase
                        }

                        MosText {
                            anchors.centerIn: parent
                            text: qsTr('定制标题栏颜色')
                            font.pixelSize: 18
                            color: '#1677ff'
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('明暗模式')
            desc: qsTr(`
通过 \`followThemeSwitch\` 属性控制是否跟随系统明/暗模式自动切换。\n
也可以调用 \`setWindowMode(isDark)\` 函数手动设置窗口的明/暗模式。
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosCheckBox {
                        id: followCheck
                        checked: true
                        text: qsTr('跟随主题切换')
                    }

                    MosButton {
                        type: MosButton.Type_Primary
                        text: (themeWinLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                        onClicked: themeWinLoader.active = !themeWinLoader.active;
                    }

                    Loader {
                        id: themeWinLoader
                        active: false
                        sourceComponent: MosWindow {
                            width: 500
                            height: 300
                            title: qsTr('明暗模式')
                            effect: MosWindow.Effect_None
                            followThemeSwitch: followCheck.checked
                            captionbar.closeCallback: () => themeWinLoader.active = false;

                            Rectangle {
                                anchors.fill: parent
                                color: MosTheme.Primary.colorBgBase
                            }

                            MosText {
                                anchors.centerIn: parent
                                text: qsTr('切换系统主题查看效果')
                                font.pixelSize: 18
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosCheckBox {
                    id: followCheck
                    checked: true
                    text: qsTr('跟随主题切换')
                }

                MosButton {
                    type: MosButton.Type_Primary
                    text: (themeWinLoader.active ? qsTr('隐藏') : qsTr('显示')) + qsTr('窗口')
                    onClicked: themeWinLoader.active = !themeWinLoader.active;
                }

                Loader {
                    id: themeWinLoader
                    active: false
                    sourceComponent: MosWindow {
                        width: 500
                        height: 300
                        title: qsTr('明暗模式')
                        effect: MosWindow.Effect_None
                        followThemeSwitch: followCheck.checked
                        captionbar.closeCallback: () => themeWinLoader.active = false;

                        Rectangle {
                            anchors.fill: parent
                            color: MosTheme.Primary.colorBgBase
                        }

                        MosText {
                            anchors.centerIn: parent
                            text: qsTr('切换系统主题查看效果')
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }
    }
}
