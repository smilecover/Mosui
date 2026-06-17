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
# MosSpin 加载中\n
用于页面和区块的加载中状态。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Control }**\n
\n<br/>
\n### 支持的代理：\n
- **indicatorDelegate: Component** 指示器代理\n
- **indicatorItemDelegate: Component** 指示器子项代理，代理可访问属性：\n
  - \`index: int\` 指示器索引\n
  - \`itemSize: int\` 子项大小(等同于 \`indicatorSize\` )\n
- **tipDelegate: Component** 提示代理\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
spinSize | real | 24 | 内容项大小
indicatorSize | real | 7 | 指示器大小
indicatorItemCount | int | 4 | 指示项数量
spinning | bool | true | 是否为加载中状态
tip | string | '' | 提示文本
percent | string丨int | 'auto' | 进度百分比
colorTip | color | - | 提示文本颜色
colorIndicator | color | - | 指示器颜色
colorProgressBar | color | - | 进度条颜色
sizeHint | string | 'normal' | 尺寸提示
contentDescription | string | '' | 内容描述(提高可用性)
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
页面局部处于等待异步数据或正在渲染过程时，合适的加载动效会有效缓解用户的焦虑。
                       `)
        }

        ThemeToken {
            source: 'MosSpin'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosSpin.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('基本用法')
            desc: qsTr(`
一个简单的 loading 状态。
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    MosSpin { }
                }
            `
            exampleDelegate: Row {
                MosSpin { }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('各种大小')
            desc: qsTr(`
通过 \`sizeHint\` 属性设置尺寸。\n
小的用于文本加载，默认用于卡片容器级加载，大的用于页面级加载。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosSpin { sizeHint: 'small' }
                    MosSpin { sizeHint: 'normal' }
                    MosSpin { sizeHint: 'large' }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosSpin { sizeHint: 'small' }
                MosSpin { sizeHint: 'normal' }
                MosSpin { sizeHint: 'large' }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('卡片加载中')
            desc: qsTr(`
切换卡片加载中状态。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    Rectangle {
                        width: parent.width
                        height: 100
                        radius: 6
                        enabled: !loadingSwitch.checked
                        color: enabled ? MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBgHover, 0.5) :
                                         MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBg, 0.5)
                        border.color: enabled ? MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBorderHover, 0.5) :
                                                MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBorder, 0.5)

                        Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationMid } }

                        MosText {
                            x: 20
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'Alert message title\n\nFurther details about the context of this alert.'
                            color: enabled ? MosTheme.Primary.colorTextPrimary : MosTheme.Primary.colorTextQuaternary

                            Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationMid } }
                        }

                        MosSpin {
                            anchors.centerIn: parent
                            spinning: loadingSwitch.checked
                        }
                    }

                    Row {
                        spacing: 10

                        MosText {
                            text: 'Loading state：'
                        }

                        MosSwitch {
                            id: loadingSwitch
                            checked: false
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                Rectangle {
                    width: parent.width
                    height: 100
                    radius: 6
                    enabled: !loadingSwitch.checked
                    color: enabled ? MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBgHover, 0.5) :
                                     MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBg, 0.5)
                    border.color: enabled ? MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBorderHover, 0.5) :
                                            MosThemeFunctions.alpha(MosTheme.Primary.colorInfoBorder, 0.5)

                    Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationMid } }

                    MosText {
                        x: 20
                        anchors.verticalCenter: parent.verticalCenter
                        text: 'Alert message title\n\nFurther details about the context of this alert.'
                        color: enabled ? MosTheme.Primary.colorTextPrimary : MosTheme.Primary.colorTextQuaternary

                        Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationMid } }
                    }

                    MosSpin {
                        anchors.centerIn: parent
                        spinning: loadingSwitch.checked
                    }
                }

                Row {
                    spacing: 10

                    MosText {
                        text: 'Loading state：'
                    }

                    MosSwitch {
                        id: loadingSwitch
                        checked: false
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('自定义提示文案')
            desc: qsTr(`
通过 \`tip\` 属性设置提示文案。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosSpin { sizeHint: 'small'; tip: 'Loading' }
                    MosSpin { sizeHint: 'normal'; tip: 'Loading' }
                    MosSpin { sizeHint: 'large'; tip: 'Loading' }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosSpin { sizeHint: 'small'; tip: 'Loading' }
                MosSpin { sizeHint: 'normal'; tip: 'Loading' }
                MosSpin { sizeHint: 'large'; tip: 'Loading' }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('展示进度')
            desc: qsTr(`
通过 \`percent\` 属性设置进度百分比，设置为 \`'auto'\` 时显示为加载中，设置为 \`0~100\` 时显示为进度条。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    MosSwitch {
                        id: progressSwitch
                        checked: true
                        checkedText: 'Auto'
                        uncheckedText: 'Progress'
                        onCheckedChanged: {
                            if (checked) {
                                progressTimer.stop();
                            } else {
                                progressTimer.progress = 0;
                                progressTimer.restart();
                            }
                        }

                        Timer {
                            id: progressTimer
                            interval: 50
                            repeat: true
                            onTriggered: {
                                progress += 1;
                                if (progress >= 100)
                                    stop();
                            }
                            property real progress: 0
                        }
                    }

                    MosSpin {
                        sizeHint: 'small'
                        percent: progressSwitch.checked ? 'auto' : progressTimer.progress
                    }

                    MosSpin {
                        sizeHint: 'normal'
                        percent: progressSwitch.checked ? 'auto' : progressTimer.progress
                    }

                    MosSpin {
                        sizeHint: 'large'
                        percent: progressSwitch.checked ? 'auto' : progressTimer.progress
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                MosSwitch {
                    id: progressSwitch
                    checked: true
                    checkedText: 'Auto'
                    uncheckedText: 'Progress'
                    onCheckedChanged: {
                        if (checked) {
                            progressTimer.stop();
                        } else {
                            progressTimer.progress = 0;
                            progressTimer.restart();
                        }
                    }

                    Timer {
                        id: progressTimer
                        interval: 50
                        repeat: true
                        onTriggered: {
                            progress += 1;
                            if (progress >= 100)
                                stop();
                        }
                        property real progress: 0
                    }
                }

                MosSpin {
                    sizeHint: 'small'
                    percent: progressSwitch.checked ? 'auto' : progressTimer.progress
                }

                MosSpin {
                    sizeHint: 'normal'
                    percent: progressSwitch.checked ? 'auto' : progressTimer.progress
                }

                MosSpin {
                    sizeHint: 'large'
                    percent: progressSwitch.checked ? 'auto' : progressTimer.progress
                }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('自定义指示符')
            desc: qsTr(`
通过 \`indicatorDelegate\` 属性自定义指示符。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    Component {
                        id: myIndicator

                        MosIconText {
                            iconSize: parent.width
                            iconSource: MosIcon.LoadingOutlined
                            colorIcon: MosTheme.Primary.colorPrimary
                        }
                    }

                    MosSpin { sizeHint: 'small'; indicatorDelegate: myIndicator }
                    MosSpin { sizeHint: 'normal'; indicatorDelegate: myIndicator }
                    MosSpin { sizeHint: 'large'; indicatorDelegate: myIndicator }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                Component {
                    id: myIndicator

                    MosIconText {
                        iconSize: parent.width
                        iconSource: MosIcon.LoadingOutlined
                        colorIcon: MosTheme.Primary.colorPrimary
                    }
                }

                MosSpin { sizeHint: 'small'; indicatorDelegate: myIndicator }
                MosSpin { sizeHint: 'normal'; indicatorDelegate: myIndicator }
                MosSpin { sizeHint: 'large'; indicatorDelegate: myIndicator }
            }
        }

        CodeBox {
            width: parent.width
            async: false
            descTitle: qsTr('自定义指示符子项')
            desc: qsTr(`
通过 \`indicatorItemDelegate\` 属性自定义指示符子项。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Row {
                    spacing: 10

                    Component {
                        id: myIndicatorItem

                        MosIconText {
                            iconSize: itemSize
                            iconSource: MosIcon.SmileOutlined
                            colorIcon: colorArray[index]
                            property var colorArray: [
                                MosTheme.Primary.colorInfo,
                                MosTheme.Primary.colorSuccess,
                                MosTheme.Primary.colorWarning,
                                MosTheme.Primary.colorError,
                            ]
                        }
                    }

                    MosSpin { sizeHint: 'small'; indicatorItemDelegate: myIndicatorItem }
                    MosSpin { sizeHint: 'normal'; indicatorItemDelegate: myIndicatorItem }
                    MosSpin { sizeHint: 'large'; indicatorItemDelegate: myIndicatorItem }
                }
            `
            exampleDelegate: Row {
                spacing: 10

                Component {
                    id: myIndicatorItem

                    MosIconText {
                        iconSize: itemSize
                        iconSource: MosIcon.SmileOutlined
                        colorIcon: colorArray[index]
                        property var colorArray: [
                            MosTheme.Primary.colorInfo,
                            MosTheme.Primary.colorSuccess,
                            MosTheme.Primary.colorWarning,
                            MosTheme.Primary.colorError,
                        ]
                    }
                }

                MosSpin { sizeHint: 'small'; indicatorItemDelegate: myIndicatorItem }
                MosSpin { sizeHint: 'normal'; indicatorItemDelegate: myIndicatorItem }
                MosSpin { sizeHint: 'large'; indicatorItemDelegate: myIndicatorItem }
            }
        }
    }
}
