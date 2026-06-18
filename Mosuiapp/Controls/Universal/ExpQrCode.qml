import QtQuick
import QtQuick.Controls
import MosuiBasic

import '../../Controls'

Flickable {
    contentHeight: column.height
    MosScrollBar.vertical: MosScrollBar { }

    Column {
        id: column
        width: parent.width - 15
        spacing: 30

        MosDescription {
            desc: qsTr(`
# MosQrCode 二维码 \n
能够将文本转换生成二维码的组件，支持自定义配色和 Logo 配置。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Item }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
text | string | '' | 要编码的内容
margin | int | 4 | 边距
errorLevel | enum | MosQrCode.Medium | 纠错等级(来自 MosQrCode)
icon.url | url | '' | 图标链接
icon.width | int | 40 | 图标宽度
icon.height | int | 40 | 图高度标
color | color | 'black' | 二维码颜色
colorMargin | color | 'transparent' | 边距颜色
colorBg | color | 'transparent' | 背景颜色
\n<br/>
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
当需要将文本转换成为二维码时使用。\n
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('基本使用')
            desc: qsTr(`
通过 \`text\` 属性设置文本内容。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosQrCode {
                        text: input.text
                        color: MosTheme.Primary.colorTextBase

                        Rectangle {
                            anchors.fill: parent
                            radius: MosTheme.Primary.radiusPrimary
                            color: 'transparent'
                            border.color: MosTheme.Primary.colorFillPrimary
                        }
                    }

                    MosInput {
                        id: input
                        width: 280
                        maximumLength: 60
                        text: 'https://github.com/mengps/MosuiBasic'
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosQrCode {
                    text: input.text
                    color: MosTheme.Primary.colorTextBase

                    Rectangle {
                        anchors.fill: parent
                        radius: MosTheme.Primary.radiusPrimary
                        color: 'transparent'
                        border.color: MosTheme.Primary.colorFillPrimary
                    }
                }

                MosInput {
                    id: input
                    width: 280
                    maximumLength: 60
                    text: 'https://github.com/mengps/MosuiBasic'
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('带 Icon 的例子')
            desc: qsTr(`
通过 \`icon\` 属性设置图标对象，支持的属性有：\n
- icon.url 图标链接\n
- icon.width 图标宽度(默认40)\n
- icon.height 图标高度(默认40)\n
通过 \`errorLevel\` 属性设置错误级别，支持的级别有：\n
- L级 { MosQrCode.Low }\n
- M级(默认) { MosQrCode.Medium }\n
- Q级 { MosQrCode.Quartile }\n
- H级{ MosQrCode.High }\n
**说明:** L级 可纠正约 7% 错误、M级 可纠正约 15% 错误、Q级 可纠正约 25% 错误、H级 可纠正约30% 错误。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosQrCode {
                        text: 'https://github.com/mengps/MosuiBasic'
                        errorLevel: MosQrCode.High
                        color: MosTheme.Primary.colorTextBase
                        icon.url: 'https://gw.alipayobjects.com/zos/rmsportal/KDpgvguMpGfqaHPjicRK.svg'

                        Rectangle {
                            anchors.fill: parent
                            radius: MosTheme.Primary.radiusPrimary
                            color: 'transparent'
                            border.color: MosTheme.Primary.colorFillPrimary
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosQrCode {
                    text: 'https://github.com/mengps/MosuiBasic'
                    errorLevel: MosQrCode.High
                    color: MosTheme.Primary.colorTextBase
                    icon.url: 'https://gw.alipayobjects.com/zos/rmsportal/KDpgvguMpGfqaHPjicRK.svg'

                    Rectangle {
                        anchors.fill: parent
                        radius: MosTheme.Primary.radiusPrimary
                        color: 'transparent'
                        border.color: MosTheme.Primary.colorFillPrimary
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('自定义尺寸')
            desc: qsTr(`
通过 \`width/height\` 属性设置二维码大小。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosButtonBlock {
                        id: sizeBlock
                        model: [
                            { iconSource: MosIcon.MinusOutlined, autoRepeat: true, label: 'Smaller' },
                            { iconSource: MosIcon.PlusOutlined, autoRepeat: true, label: 'Larger' },
                        ]
                        onClicked:
                            (index) => {
                                if (index === 0) size = Math.max(48, Math.min(300, size - 10));
                                if (index === 1) size = Math.max(48, Math.min(300, size + 10));
                            }
                        property int size: 160
                    }

                    MosQrCode {
                        text: 'https://github.com/mengps/MosuiBasic'
                        width: sizeBlock.size
                        height: sizeBlock.size
                        errorLevel: MosQrCode.High
                        color: MosTheme.Primary.colorTextBase
                        icon.url: 'https://gw.alipayobjects.com/zos/rmsportal/KDpgvguMpGfqaHPjicRK.svg'

                        Rectangle {
                            anchors.fill: parent
                            radius: MosTheme.Primary.radiusPrimary
                            color: 'transparent'
                            border.color: MosTheme.Primary.colorFillPrimary
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosButtonBlock {
                    id: sizeBlock
                    model: [
                        { iconSource: MosIcon.MinusOutlined, autoRepeat: true, label: 'Smaller' },
                        { iconSource: MosIcon.PlusOutlined, autoRepeat: true, label: 'Larger' },
                    ]
                    onClicked:
                        (index) => {
                            if (index === 0) size = Math.max(48, Math.min(300, size - 10));
                            if (index === 1) size = Math.max(48, Math.min(300, size + 10));
                        }
                    property int size: 160
                }

                MosQrCode {
                    text: 'https://github.com/mengps/MosuiBasic'
                    width: sizeBlock.size
                    height: sizeBlock.size
                    errorLevel: MosQrCode.High
                    color: MosTheme.Primary.colorTextBase
                    icon.url: 'https://gw.alipayobjects.com/zos/rmsportal/KDpgvguMpGfqaHPjicRK.svg'

                    Rectangle {
                        anchors.fill: parent
                        radius: MosTheme.Primary.radiusPrimary
                        color: 'transparent'
                        border.color: MosTheme.Primary.colorFillPrimary
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('自定义颜色')
            desc: qsTr(`
通过 \`color\` 属性设置二维码颜色。\n
通过 \`colorBg\` 属性设置背景颜色。\n
通过 \`colorMargin\` 属性设置边缘颜色。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosQrCode {
                        text: 'https://github.com/mengps/MosuiBasic'
                        color: MosTheme.Primary.colorSuccess
                    }

                    MosQrCode {
                        text: 'https://github.com/mengps/MosuiBasic'
                        color: MosTheme.Primary.colorInfo
                        colorBg: MosTheme.Primary.colorWarning
                        colorMargin: "#80ff0000"
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosQrCode {
                    text: 'https://github.com/mengps/MosuiBasic'
                    color: MosTheme.Primary.colorSuccess
                }

                MosQrCode {
                    text: 'https://github.com/mengps/MosuiBasic'
                    color: MosTheme.Primary.colorInfo
                    colorBg: MosTheme.Primary.colorWarning
                    colorMargin: "#80ff0000"
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('高级用法')
            desc: qsTr(`
带气泡卡片的例子。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosButton {
                        text: 'Hover me'
                        type: MosButton.Type_Primary

                        MosPopover {
                            x: (parent.width - width) * 0.5
                            y: parent.height + 6
                            width: 160
                            visible: parent.hovered || parent.down
                            closePolicy: MosPopover.NoAutoClose
                            contentDelegate: MosQrCode {
                                text: 'https://github.com/mengps/MosuiBasic'
                                color: MosTheme.Primary.colorTextBase
                            }
                        }
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosButton {
                    text: 'Hover me'
                    type: MosButton.Type_Primary

                    MosPopover {
                        x: (parent.width - width) * 0.5
                        y: parent.height + 6
                        width: 160
                        visible: parent.hovered || parent.down
                        closePolicy: MosPopover.NoAutoClose
                        contentDelegate: MosQrCode {
                            text: 'https://github.com/mengps/MosuiBasic'
                            color: MosTheme.Primary.colorTextBase
                        }
                    }
                }
            }
        }
    }
}
