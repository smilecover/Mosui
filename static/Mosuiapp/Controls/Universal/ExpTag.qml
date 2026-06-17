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

        DocDescription {
            desc: qsTr(`
# MosTag 标签 \n
进行标记和分类的小标签。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Control }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
tagState | enum | MosTag.State_Default | 标签状态(来自 MosTag)
text | string | '' | 标签文本
rotating | bool | false | 旋转中
iconSource | int丨string | 0丨'' | 图标(来自 MosIcon)或图标链接
iconSize | int | - | 图标大小
closeIconSource | int丨string | 0丨'' | 关闭图标(来自 MosIcon)或图标链接
closeIconSize | int | true | 关闭图标大小
presetColor | string | '' | 预设颜色
colorText | color | - |文本颜色
colorBg | color | - | 背景颜色
colorBorder | color | - | 边框颜色
colorIcon | color | - | 图标颜色
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
\n<br/>
\n### 支持的信号：\n
- \`close()\` 点击关闭图标(如果有)时发出\n
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
- 用于标记事物的属性和维度。\n
- 进行分类。\n
                       `)
        }

        ThemeToken {
            source: 'MosTag'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosTag.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('基本用法')
            desc: qsTr(`
基本标签的用法\n
通过 \`text\` 设置标签文本。\n
通过 \`closeIconSource\` 设置关闭图标。\n
点击关闭图标将发送 \`close\` 信号。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    width: parent.width
                    spacing: 10

                    Row {
                        spacing: 10

                        MosTag {
                            text: 'Tag 1'
                        }

                        MosTag {
                            text: 'Link'

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Qt.openUrlExternally('https://github.com/mengps/MosuiBasic');
                                }
                            }
                        }

                        MosTag {
                            text: 'Prevent Default'
                            closeIconSource: MosIcon.CloseOutlined
                        }

                        MosTag {
                            text: 'Tag 2'
                            closeIconSource: MosIcon.CloseCircleOutlined
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                Row {
                    spacing: 10

                    MosTag {
                        text: 'Tag 1'
                    }

                    MosTag {
                        text: 'Link'

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Qt.openUrlExternally('https://github.com/mengps/MosuiBasic');
                            }
                        }
                    }

                    MosTag {
                        text: 'Prevent Default'
                        closeIconSource: MosIcon.CloseOutlined
                    }

                    MosTag {
                        text: 'Tag 2'
                        closeIconSource: MosIcon.CloseCircleOutlined
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('多彩标签')
            desc: qsTr(`
通过 \`presetColor\` 设置预设颜色。\n
支持的预设颜色：\n
**['red', 'volcano', 'orange', 'gold', 'yellow', 'lime', 'green', 'cyan', 'blue', 'geekblue', 'purple', 'magenta']** \n
如果预设颜色不在该列表中，则为自定义标签。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    width: parent.width
                    spacing: 10

                    Row {
                        spacing: 10

                        Repeater {
                            model: [ 'red', 'volcano', 'orange', 'gold', 'yellow', 'lime', 'green', 'cyan', 'blue', 'geekblue', 'purple', 'magenta' ]
                            delegate: MosTag {
                                text: modelData
                                presetColor: modelData
                            }
                        }
                    }

                    Row {
                        spacing: 10

                        Repeater {
                            model: [ '#f50', '#2db7f5', '#87d068', '#108ee9' ]
                            delegate: MosTag {
                                text: modelData
                                presetColor: modelData
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                Row {
                    spacing: 10

                    Repeater {
                        model: [ 'red', 'volcano', 'orange', 'gold', 'yellow', 'lime', 'green', 'cyan', 'blue', 'geekblue', 'purple', 'magenta' ]
                        delegate: MosTag {
                            text: modelData
                            presetColor: modelData
                        }
                    }
                }

                Row {
                    spacing: 10

                    Repeater {
                        model: [ '#f50', '#2db7f5', '#87d068', '#108ee9' ]
                        delegate: MosTag {
                            text: modelData
                            presetColor: modelData
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('动态添加和删除')
            desc: qsTr(`
简单生成一组标签，利用 \`close()\` 信号可以实现动态添加和删除。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    width: parent.width
                    spacing: 10

                    Flow {
                        width: parent.width
                        spacing: 10

                        Repeater {
                            id: editRepeater
                            model: ListModel {
                                id: editTagsModel
                                ListElement { tag: 'Unremovable'; removable: false }
                                ListElement { tag: 'Tag 1'; removable: true }
                                ListElement { tag: 'Tag 2'; removable: true }
                            }
                            delegate: MosTag {
                                text: tag
                                closeIconSource: removable ? MosIcon.CloseOutlined : 0
                                onClose: {
                                    editTagsModel.remove(index, 1);
                                }
                            }
                        }

                        MosInput {
                            width: 100
                            font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                            iconSource: MosIcon.PlusOutlined
                            placeholderText: 'New Tag'
                            colorBg: 'transparent'
                            onAccepted: {
                                focus = false;
                                editTagsModel.append({ tag: text, removable: true })
                                clear();
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                Flow {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        id: editRepeater
                        model: ListModel {
                            id: editTagsModel
                            ListElement { tag: 'Unremovable'; removable: false }
                            ListElement { tag: 'Tag 1'; removable: true }
                            ListElement { tag: 'Tag 2'; removable: true }
                        }
                        delegate: MosTag {
                            text: tag
                            closeIconSource: removable ? MosIcon.CloseOutlined : 0
                            onClose: {
                                editTagsModel.remove(index, 1);
                            }
                        }
                    }

                    MosInput {
                        width: 100
                        font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                        iconSource: MosIcon.PlusOutlined
                        placeholderText: 'New Tag'
                        colorBg: 'transparent'
                        onAccepted: {
                            focus = false;
                            editTagsModel.append({ tag: text, removable: true })
                            clear();
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('带图标的标签')
            desc: qsTr(`
通过 \`iconSource\` 设置左侧图标。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    width: parent.width
                    spacing: 10

                    MosTag {
                        text: 'Twitter'
                        iconSource: MosIcon.TwitterOutlined
                        presetColor: '#55acee'
                    }

                    MosTag {
                        text: 'Youtube'
                        iconSource: MosIcon.YoutubeOutlined
                        presetColor: '#cd201f'
                    }

                    MosTag {
                        text: 'Facebook '
                        iconSource: MosIcon.FacebookOutlined
                        presetColor: '#3b5999'
                    }

                    MosTag {
                        text: 'LinkedIn'
                        iconSource: MosIcon.LinkedinOutlined
                        presetColor: '#55acee'
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosTag {
                    text: 'Twitter'
                    iconSource: MosIcon.TwitterOutlined
                    presetColor: '#55acee'
                }

                MosTag {
                    text: 'Youtube'
                    iconSource: MosIcon.YoutubeOutlined
                    presetColor: '#cd201f'
                }

                MosTag {
                    text: 'Facebook '
                    iconSource: MosIcon.FacebookOutlined
                    presetColor: '#3b5999'
                }

                MosTag {
                    text: 'LinkedIn'
                    iconSource: MosIcon.LinkedinOutlined
                    presetColor: '#55acee'
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('预设状态的标签')
            desc: qsTr(`
通过 \`rotating\` 设置图标是否旋转中。\n
通过 \`tagState\` 来设置不同的状态，支持的状态有：\n
- 默认状态(默认){ MosTag.State_Default }\n
- 成功状态{ MosTag.State_Success }\n
- 处理中状态{ MosTag.State_Processing }\n
- 错误状态{ MosTag.State_Error }\n
- 警告状态{ MosTag.State_Warning }\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    width: parent.width
                    spacing: 10

                    Row {
                        spacing: 10

                        MosTag {
                            text: 'success'
                            tagState: MosTag.State_Success
                        }

                        MosTag {
                            text: 'processing'
                            tagState: MosTag.State_Processing
                        }

                        MosTag {
                            text: 'error'
                            tagState: MosTag.State_Error
                        }

                        MosTag {
                            text: 'warning'
                            tagState: MosTag.State_Warning
                        }

                        MosTag {
                            text: 'default'
                            tagState: MosTag.State_Default
                        }
                    }

                    Row {
                        spacing: 10

                        MosTag {
                            text: 'success'
                            tagState: MosTag.State_Success
                            iconSource: MosIcon.CheckCircleOutlined
                        }

                        MosTag {
                            text: 'processing'
                            rotating: true
                            tagState: MosTag.State_Processing
                            iconSource: MosIcon.SyncOutlined
                        }

                        MosTag {
                            text: 'error'
                            tagState: MosTag.State_Error
                            iconSource: MosIcon.CloseCircleOutlined
                        }

                        MosTag {
                            text: 'warning'
                            tagState: MosTag.State_Warning
                            iconSource: MosIcon.ExclamationCircleOutlined
                        }

                        MosTag {
                            text: 'waiting'
                            tagState: MosTag.State_Default
                            iconSource: MosIcon.ClockCircleOutlined
                        }

                        MosTag {
                            text: 'stop'
                            tagState: MosTag.State_Default
                            iconSource: MosIcon.MinusCircleOutlined
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                Row {
                    spacing: 10

                    MosTag {
                        text: 'success'
                        tagState: MosTag.State_Success
                    }

                    MosTag {
                        text: 'processing'
                        tagState: MosTag.State_Processing
                    }

                    MosTag {
                        text: 'error'
                        tagState: MosTag.State_Error
                    }

                    MosTag {
                        text: 'warning'
                        tagState: MosTag.State_Warning
                    }

                    MosTag {
                        text: 'default'
                        tagState: MosTag.State_Default
                    }
                }

                Row {
                    spacing: 10

                    MosTag {
                        text: 'success'
                        tagState: MosTag.State_Success
                        iconSource: MosIcon.CheckCircleOutlined
                    }

                    MosTag {
                        text: 'processing'
                        rotating: true
                        tagState: MosTag.State_Processing
                        iconSource: MosIcon.SyncOutlined
                    }

                    MosTag {
                        text: 'error'
                        tagState: MosTag.State_Error
                        iconSource: MosIcon.CloseCircleOutlined
                    }

                    MosTag {
                        text: 'warning'
                        tagState: MosTag.State_Warning
                        iconSource: MosIcon.ExclamationCircleOutlined
                    }

                    MosTag {
                        text: 'waiting'
                        tagState: MosTag.State_Default
                        iconSource: MosIcon.ClockCircleOutlined
                    }

                    MosTag {
                        text: 'stop'
                        tagState: MosTag.State_Default
                        iconSource: MosIcon.MinusCircleOutlined
                    }
                }
            }
        }
    }
}
