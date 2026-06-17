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

        DocDescription {
            desc: qsTr(`
# MosScrollBar 滚动条\n
滚动条是一个交互式栏，用于滚动某个区域或视图到特定位置。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { ScrollBar }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述 |
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
minimumHandleSize | int | 24 | 滑块的最小大小
colorBar | color | - | 把手颜色
colorBg | color | - | 背景颜色
colorIcon | color | - | 图标颜色(即箭头颜色)
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
当一个项超出其容器大小时使用，提供比原生[ScrollBar]更好的外观和操作体验。
                       `)
        }

        ThemeToken {
            source: 'MosScrollBar'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosScrollBar.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用方法和 \`ScrollBar\` 一致。
                       `)
            code: `
                import QtQuick
                
                import MosuiBasic

                Item {
                    Flickable {
                        width: 200
                        height: 200
                        contentWidth: 400
                        contentHeight: 400
                        ScrollBar.vertical: MosScrollBar { }
                        ScrollBar.horizontal: MosScrollBar { }
                        clip: true

                        MosIconText {
                            iconSize: 400
                            iconSource: MosIcon.BugOutlined
                        }
                    }
                }
            `
            exampleDelegate: Item {
                height: 200

                Flickable {
                    width: 200
                    height: 200
                    contentWidth: 400
                    contentHeight: 400
                    ScrollBar.vertical: MosScrollBar { }
                    ScrollBar.horizontal: MosScrollBar { }
                    clip: true

                    MosIconText {
                        iconSize: 400
                        iconSource: MosIcon.BugOutlined
                    }
                }
            }
        }
    }
}
