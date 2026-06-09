import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
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
# MosAvatar 头像 \n
用来代表用户或事物，支持图片、图标或字符展示。\n
* **模块 { MosuiBasic}**\n
* **继承自 { Control }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
size | int | 30 | 头像大小
iconSource | int丨string | 0 | 头像图标(来自 MosIcon)或图标链接
imageSource | url | '' | 头像图像
imageMipmap | bool | false | 是否开启层级映射
textSource | string | '' | 头像文本
textFont | font | - | 文本字体(文本头像时生效)
textSize | enum | MosAvatar.Size_Fixed | 文本大小模式(来自 MosAvatar)
textGap | int | 4 | 文本距离两侧单位像素(文本头像时生效)
colorBg | color | - | 背景颜色
colorIcon | color | 'white' | 图标颜色(图标头像时生效)
colorText | color | 'white' |文本颜色(文本头像时生效)
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
\n **注意** \`[iconSource/imageSource/textSource]\`只需提供一种即可
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
当用户需要头像时使用。
                       `)
        }
        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('基本')
            desc: qsTr(`
通过 \`size\` 属性设置大小。\n
通过 \`radiusBg\` 属性设置圆角大小(默认为size一半, 即圆形)。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    Row {
                        spacing: 10

                        MosAvatar {
                            size: 100
                            iconSource: MosIcon.UserOutlined
                        }

                        MosAvatar {
                            size: 80
                            iconSource: MosIcon.UserOutlined
                        }

                        MosAvatar {
                            size: 60
                            iconSource: MosIcon.UserOutlined
                        }

                        MosAvatar {
                            size: 40
                            iconSource: MosIcon.UserOutlined
                        }

                        MosAvatar {
                            size: 20
                            iconSource: MosIcon.UserOutlined
                        }
                    }

                    Row {
                        spacing: 10

                        MosAvatar {
                            size: 100
                            iconSource: MosIcon.UserOutlined
                            radiusBg.all: 6
                        }

                        MosAvatar {
                            size: 80
                            iconSource: MosIcon.UserOutlined
                            radiusBg.all: 6
                        }

                        MosAvatar {
                            size: 60
                            iconSource: MosIcon.UserOutlined
                            radiusBg.all: 6
                        }

                        MosAvatar {
                            size: 40
                            iconSource: MosIcon.UserOutlined
                            radiusBg.all: 6
                        }

                        MosAvatar {
                            size: 20
                            iconSource: MosIcon.UserOutlined
                            radiusBg.all: 6
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                Row {
                    spacing: 10

                    MosAvatar {
                        size: 100
                        iconSource: MosIcon.UserOutlined
                    }

                    MosAvatar {
                        size: 80
                        iconSource: MosIcon.UserOutlined
                    }

                    MosAvatar {
                        size: 60
                        iconSource: MosIcon.UserOutlined
                    }

                    MosAvatar {
                        size: 40
                        iconSource: MosIcon.UserOutlined
                    }

                    MosAvatar {
                        size: 20
                        iconSource: MosIcon.UserOutlined
                    }
                }

                Row {
                    spacing: 10

                    MosAvatar {
                        size: 100
                        iconSource: MosIcon.UserOutlined
                        radiusBg.all: 6
                    }

                    MosAvatar {
                        size: 80
                        iconSource: MosIcon.UserOutlined
                        radiusBg.all: 6
                    }

                    MosAvatar {
                        size: 60
                        iconSource: MosIcon.UserOutlined
                        radiusBg.all: 6
                    }

                    MosAvatar {
                        size: 40
                        iconSource: MosIcon.UserOutlined
                        radiusBg.all: 6
                    }

                    MosAvatar {
                        size: 20
                        iconSource: MosIcon.UserOutlined
                        radiusBg.all: 6
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('类型')
            desc: qsTr(`
支持三种类型：图片、图标以及字符型头像。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        iconSource: MosIcon.UserOutlined
                    }

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        textSource: 'U'
                    }

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        textSource: 'USER'
                    }

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        imageSource: 'https://avatars.githubusercontent.com/u/33405710?v=4'
                    }

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        textSource: 'U'
                        colorText: '#F56A00'
                        colorBg: '#FDE3CF'
                    }

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        iconSource: MosIcon.UserOutlined
                        colorBg: '#87D068'
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    iconSource: MosIcon.UserOutlined
                }

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    textSource: 'U'
                }

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    textSource: 'USER'
                }

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    imageSource: 'https://pic.616pic.com/ys_bnew_img/00/49/21/h2kBkdmny0.jpg'
                }

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    textSource: 'U'
                    colorText: '#F56A00'
                    colorBg: '#FDE3CF'
                }

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    iconSource: MosIcon.UserOutlined
                    colorBg: '#87D068'
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('自动调整字符型头像大小')
            desc: qsTr(`
通过 \`textSize\` 属性设置文本大小调整模式，支持的大小：\n
- 固定大小(默认) { MosAvatar.Size_Fixed }\n
- 自动计算大小 { MosAvatar.Size_Auto }\n
通过 \`textGap\` 属性设置字符距离左右两侧边界单位像素。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 40
                        textSource: changeButton.userList[changeButton.index]
                        colorBg: changeButton.colorList[changeButton.index]
                        textSize: MosAvatar.Size_Fixed
                    }

                    MosAvatar {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 40
                        textSource: changeButton.userList[changeButton.index]
                        colorBg: changeButton.colorList[changeButton.index]
                        textSize: MosAvatar.Size_Auto
                    }

                    MosButton {
                        id: changeButton
                        anchors.verticalCenter: parent.verticalCenter
                        text: qsTr('ChangeUser')
                        onClicked: {
                            index = (index + 1) % 4;
                        }
                        property int index: 0
                        property var userList: ['U', 'Lucy', 'Tom', 'Edward']
                        property var colorList: ['#f56a00', '#7265e6', '#ffbf00', '#00a2ae']
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    size: 40
                    textSource: changeButton.userList[changeButton.index]
                    colorBg: changeButton.colorList[changeButton.index]
                    textSize: MosAvatar.Size_Fixed
                }

                MosAvatar {
                    anchors.verticalCenter: parent.verticalCenter
                    size: 40
                    textSource: changeButton.userList[changeButton.index]
                    colorBg: changeButton.colorList[changeButton.index]
                    textSize: MosAvatar.Size_Auto
                }

                MosButton {
                    id: changeButton
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr('ChangeUser')
                    onClicked: {
                        index = (index + 1) % 4;
                    }
                    property int index: 0
                    property var userList: ['U', 'Lucy', 'Tom', 'Edward']
                    property var colorList: ['#f56a00', '#7265e6', '#ffbf00', '#00a2ae']
                }
            }
        }
    }
}
