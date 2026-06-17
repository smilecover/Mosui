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

        DocDescription {
            desc: qsTr(`
# MosSplitView 分隔视图 \n
用于水平或垂直布局项目，并在每个项目之间都有一个可拖动的拆分器。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { SplitView }**\n
\n<br/>
\n### 支持的代理：\n
- **collapseBarStart: Component** (左侧/上侧)折叠按钮\n
  - \`index: int\` 把手索引\n
  - \`collapseBarHovered: bool\` 是否悬浮\n
- **collapseBarEnd: Component** (右侧/下侧)折叠按钮\n
  - \`index: int\` 把手索引\n
  - \`collapseBarHovered: bool\` 是否悬浮\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
resizable | bool | true | 是否开启拖拽伸缩
showCollapsibleIcon | string丨bool | false | 是否显示快速折叠图标(为'auto'时自动显示)
handleSize | real | 2 | 拖拽把手大小
handleTriggerSize | real | 6 | 拖拽触发区域大小
radiusCollapseBar | [MosRadius](internal://MosRadius) | - | 折叠按钮圆角
\n<br/>
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
- 可以水平或垂直地分隔区域。\n
- 当需要自由拖拽调整各区域大小。\n
- 当需要指定区域的最大最小宽高时。\n
                       `)
        }

        ThemeToken {
            source: 'MosSplitView'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosSplitView.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('基本用法')
            desc: qsTr(`
最简单的用法。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosSplitView {
                        width: parent.width
                        height: 300

                        Rectangle {
                            MosSplitView.preferredWidth: parent.width * 0.4
                            MosSplitView.fillHeight: true
                            MosSplitView.minimumWidth: parent.width * 0.1
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'First'
                            }
                        }

                        Rectangle {
                            MosSplitView.fillWidth: true
                            MosSplitView.fillHeight: true
                            MosSplitView.minimumWidth: parent.width * 0.1
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'Second'
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosSplitView {
                    width: parent.width
                    height: 300

                    Rectangle {
                        MosSplitView.preferredWidth: parent.width * 0.4
                        MosSplitView.fillHeight: true
                        MosSplitView.minimumWidth: parent.width * 0.1
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'First'
                        }
                    }

                    Rectangle {
                        MosSplitView.fillWidth: true
                        MosSplitView.fillHeight: true
                        MosSplitView.minimumWidth: parent.width * 0.1
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'Second'
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('启用/禁用拖拽')
            desc: qsTr(`
通过 \`resizable\` 属性来启用/禁用拖拽。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosSwitch {
                        id: resizableSwitch
                        checked: false
                        checkedText: 'Enabled'
                        uncheckedText: 'Disabled'
                    }

                    MosSplitView {
                        width: parent.width
                        height: 300
                        resizable: resizableSwitch.checked

                        Rectangle {
                            MosSplitView.preferredWidth: parent.width * 0.4
                            MosSplitView.fillHeight: true
                            MosSplitView.minimumWidth: parent.width * 0.1
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'First'
                            }
                        }

                        Rectangle {
                            MosSplitView.fillWidth: true
                            MosSplitView.fillHeight: true
                            MosSplitView.minimumWidth: parent.width * 0.1
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'Second'
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosSwitch {
                    id: resizableSwitch
                    checked: false
                    checkedText: 'Enabled'
                    uncheckedText: 'Disabled'
                }

                MosSplitView {
                    width: parent.width
                    height: 300
                    resizable: resizableSwitch.checked

                    Rectangle {
                        MosSplitView.preferredWidth: parent.width * 0.4
                        MosSplitView.fillHeight: true
                        MosSplitView.minimumWidth: parent.width * 0.1
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'First'
                        }
                    }

                    Rectangle {
                        MosSplitView.fillWidth: true
                        MosSplitView.fillHeight: true
                        MosSplitView.minimumWidth: parent.width * 0.1
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'Second'
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('垂直方向')
            desc: qsTr(`
通过 \`orientation\` 属性来设置方向。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosSplitView {
                        width: parent.width
                        height: 300
                        orientation: Qt.Vertical

                        Rectangle {
                            MosSplitView.fillWidth: true
                            MosSplitView.preferredHeight: parent.height * 0.5
                            MosSplitView.minimumHeight: parent.height * 0.1
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'First'
                            }
                        }

                        Rectangle {
                            MosSplitView.fillWidth: true
                            MosSplitView.preferredHeight: parent.height * 0.5
                            MosSplitView.minimumHeight: parent.height * 0.1
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'Second'
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosSplitView {
                    width: parent.width
                    height: 300
                    orientation: Qt.Vertical

                    Rectangle {
                        MosSplitView.fillWidth: true
                        MosSplitView.preferredHeight: parent.height * 0.5
                        MosSplitView.minimumHeight: parent.height * 0.1
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'First'
                        }
                    }

                    Rectangle {
                        MosSplitView.fillWidth: true
                        MosSplitView.preferredHeight: parent.height * 0.5
                        MosSplitView.minimumHeight: parent.height * 0.1
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'Second'
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('可折叠图标显示')
            desc: qsTr(`
通过 \`showCollapsibleIcon\` 属性来控制可折叠图标的显示方式，支持的方式有：\n
- 不显示(默认){ false }\n
- 始终显示{ true }\n
- 悬浮时显示{ 'auto' }\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    Row {
                        spacing: 20

                        MosText {
                            text: 'ShowCollapsibleIcon:'
                        }

                        MosRadio {
                            text: 'Auto'
                            checked: true
                            onToggled: splitView.showCollapsibleIcon = 'auto';
                        }

                        MosRadio {
                            text: 'True'
                            onToggled: splitView.showCollapsibleIcon = true;
                        }

                        MosRadio {
                            text: 'False'
                            onToggled: splitView.showCollapsibleIcon = false;
                        }
                    }

                    MosSplitView {
                        id: splitView
                        width: parent.width
                        height: 300
                        showCollapsibleIcon: 'auto'

                        Rectangle {
                            MosSplitView.preferredWidth: parent.width * 0.2
                            MosSplitView.fillHeight: true
                            clip: true
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'First'
                            }
                        }

                        Rectangle {
                            MosSplitView.preferredWidth: parent.width * 0.2
                            MosSplitView.fillHeight: true
                            clip: true
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'Second'
                            }
                        }

                        Rectangle {
                            MosSplitView.preferredWidth: parent.width * 0.6
                            MosSplitView.fillHeight: true
                            clip: true
                            color: MosTheme.Primary.colorBgBase

                            MosText {
                                anchors.centerIn: parent
                                text: 'Third'
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                Row {
                    spacing: 20

                    MosText {
                        text: 'ShowCollapsibleIcon:'
                    }

                    MosRadio {
                        text: 'Auto'
                        checked: true
                        onToggled: splitView.showCollapsibleIcon = 'auto';
                    }

                    MosRadio {
                        text: 'True'
                        onToggled: splitView.showCollapsibleIcon = true;
                    }

                    MosRadio {
                        text: 'False'
                        onToggled: splitView.showCollapsibleIcon = false;
                    }
                }

                MosSplitView {
                    id: splitView
                    width: parent.width
                    height: 300
                    showCollapsibleIcon: 'auto'

                    Rectangle {
                        MosSplitView.preferredWidth: parent.width * 0.2
                        MosSplitView.fillHeight: true
                        clip: true
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'First'
                        }
                    }

                    Rectangle {
                        MosSplitView.preferredWidth: parent.width * 0.2
                        MosSplitView.fillHeight: true
                        clip: true
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'Second'
                        }
                    }

                    Rectangle {
                        MosSplitView.preferredWidth: parent.width * 0.6
                        MosSplitView.fillHeight: true
                        clip: true
                        color: MosTheme.Primary.colorBgBase

                        MosText {
                            anchors.centerIn: parent
                            text: 'Third'
                        }
                    }
                }
            }
        }
    }
}
