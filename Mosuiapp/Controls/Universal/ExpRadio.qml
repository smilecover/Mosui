import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
# MosRadio 单选框 \n
用于在多个备选项中选中单个状态。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { RadioButton }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
effectEnabled | bool | true | 是否开启点击效果
hoverCursorShape | enum | Qt.PointingHandCursor | 悬浮时鼠标形状(来自 Qt.*Cursor)
colorText | color | - | 文本颜色
colorIndicator | color | - | 指示器颜色
colorIndicatorBorder | color | - | 指示器边框颜色
radiusIndicator | [MosRadius](internal://MosRadius) | 8 | 指示器圆角
contentDescription | string | '' | 内容描述(提高可用性)
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
- 用于在多个备选项中选中单个状态。\n
- 和 [MosSelect](internal://MosSelect) 的区别是，MosRadio 所有选项默认可见，方便用户在比较中选择，因此选项不宜过多。\n
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
最简单的用法。\n
通过 \`enabled\` 设置是否启用。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosRadio {
                        text: qsTr('Radio')
                    }

                    MosRadio {
                        text: qsTr('Disabled')
                        enabled: false
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosRadio {
                    text: qsTr('Radio')
                }

                MosRadio {
                    text: qsTr('Disabled')
                    enabled: false
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
使用 \`ButtonGroup(QtQuick原生组件)\` 来实现一组互斥的 MosRadio 配合使用。\n
                       `)
            code: `
                import QtQuick
                
                import MosuiBasic

                Row {
                    height: 50
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    spacing: 10

                    ButtonGroup { id: radioGroup }

                    MosRadio {
                        text: qsTr('LineChart')
                        ButtonGroup.group: radioGroup

                        MosIconText {
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            iconSize: 24
                            iconSource: MosIcon.LineChartOutlined
                        }
                    }

                    MosRadio {
                        text: qsTr('DotChart')
                        ButtonGroup.group: radioGroup

                        MosIconText {
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            iconSize: 24
                            iconSource: MosIcon.DotChartOutlined
                        }
                    }

                    MosRadio {
                        text: qsTr('BarChart')
                        ButtonGroup.group: radioGroup

                        MosIconText {
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            iconSize: 24
                            iconSource: MosIcon.BarChartOutlined
                        }
                    }

                    MosRadio {
                        text: qsTr('PieChart')
                        ButtonGroup.group: radioGroup

                        MosIconText {
                            anchors.bottom: parent.top
                            anchors.bottomMargin: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            iconSize: 24
                            iconSource: MosIcon.PieChartOutlined
                        }
                    }
                }
            `
            exampleDelegate: Row {
                height: 50
                anchors.top: parent.top
                anchors.topMargin: 20
                spacing: 10

                ButtonGroup { id: radioGroup }

                MosRadio {
                    text: qsTr('LineChart')
                    ButtonGroup.group: radioGroup

                    MosIconText {
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconSize: 24
                        iconSource: MosIcon.LineChartOutlined
                    }
                }

                MosRadio {
                    text: qsTr('DotChart')
                    ButtonGroup.group: radioGroup

                    MosIconText {
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconSize: 24
                        iconSource: MosIcon.DotChartOutlined
                    }
                }

                MosRadio {
                    text: qsTr('BarChart')
                    ButtonGroup.group: radioGroup

                    MosIconText {
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconSize: 24
                        iconSource: MosIcon.BarChartOutlined
                    }
                }

                MosRadio {
                    text: qsTr('PieChart')
                    ButtonGroup.group: radioGroup

                    MosIconText {
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconSize: 24
                        iconSource: MosIcon.PieChartOutlined
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
垂直的 MosRadio，配合更多输入框选项。\n
                       `)
            code: `
                import QtQuick
                
                import MosuiBasic

                Column {
                    spacing: 10

                    ButtonGroup { id: radioGroup2 }

                    MosRadio {
                        text: qsTr('Option A')
                        ButtonGroup.group: radioGroup2
                    }

                    MosRadio {
                        text: qsTr('Option B')
                        ButtonGroup.group: radioGroup2
                    }

                    MosRadio {
                        text: qsTr('Option C')
                        ButtonGroup.group: radioGroup2
                    }

                    MosRadio {
                        text: qsTr('More...')
                        ButtonGroup.group: radioGroup2

                        MosInput {
                            visible: parent.checked
                            placeholderText: qsTr('Please input')
                            width: 110
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                ButtonGroup { id: radioGroup2 }

                MosRadio {
                    text: qsTr('Option A')
                    ButtonGroup.group: radioGroup2
                }

                MosRadio {
                    text: qsTr('Option B')
                    ButtonGroup.group: radioGroup2
                }

                MosRadio {
                    text: qsTr('Option C')
                    ButtonGroup.group: radioGroup2
                }

                MosRadio {
                    text: qsTr('More...')
                    ButtonGroup.group: radioGroup2

                    MosInput {
                        width: 110
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right
                        anchors.leftMargin: 10
                        visible: parent.checked
                        placeholderText: qsTr('Please input')
                    }
                }
            }
        }
    }
}
