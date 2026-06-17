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
# MosSpace 间距\n
布局并设置组件之间的间距/圆角。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Loader }**\n
\n<br/>
\n### 支持的代理：\n
- 无\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
type | enum | MosSpace.Type_Compact | 间距类型(来自 MosSpace)
layout | string | '' | 布局类型
autoCombineRadius | bool | true | 是否自动组合圆角
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
\n其他属性来自 **Row/RowLayout/Column/ColumnLayout/Grid/GridLayout** \n
\n**注意** 覆盖问题请使用 \`z: active ? 1 : 0\` 或类似的方案解决\n
\n**注意** 自动组合圆角无法正确处理 Repeater 创建的项，此时应关闭 \`autoCombineRadius\` 并手动设置圆角\n
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
- MosSpace 当用户需要简化布局和组合组件时使用，自动为子元素计算间距和圆角，其本身是原生固定布局(Row* Column* Grid*)的容器。\n
                       `)
        }

        ThemeToken {
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosSpace.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('基本用法')
            desc: qsTr(`
通过 \`layout\` 属性设置实例化布局(设置一次)，设置完成后和原生布局一样使用即可。\n
\`layout\` 支持的值有：'Row' 'RowLayout' 'Column' 'ColumnLayout' 'Grid' 'GridLayout' \n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 15

                    Row {
                        MosText {
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'ButtonType: '
                        }
                        MosRadioBlock {
                            id: buttonTypeRadio
                            initCheckedIndex: 0
                            model: [
                                { label: 'Default', value: MosButton.Type_Default },
                                { label: 'Outlined', value: MosButton.Type_Outlined },
                                { label: 'Dashed', value: MosButton.Type_Dashed },
                                { label: 'Primary', value: MosButton.Type_Primary },
                                { label: 'Filled', value: MosButton.Type_Filled },
                            ]
                        }
                    }

                    Row {
                        MosText {
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'LayoutDirection: '
                        }
                        MosRadioBlock {
                            id: layoutDirectionRadio
                            initCheckedIndex: 0
                            model: [
                                { label: 'LeftToRight', value: Qt.LeftToRight },
                                { label: 'RightToLeft', value: Qt.RightToLeft },
                            ]
                        }
                    }

                    Row {
                        MosText {
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'Space: '
                        }
                        MosSlider {
                            id: spaceSlider
                            width: 200
                            height: 30
                            min: -1
                            max: 100
                            value: -1
                        }
                    }

                    MosSpace {
                        layout: 'Row'
                        spacing: spaceSlider.currentValue
                        layoutDirection: layoutDirectionRadio.currentCheckedValue

                        MosIconButton {
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.LikeOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Like' }
                        }

                        MosIconButton {
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.CommentOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Comment' }
                        }

                        MosIconButton {
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.StarOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Star' }
                        }

                        MosIconButton {
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.HeartOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Heart' }
                        }

                        MosIconButton {
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.ShareAltOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Share' }
                        }

                        MosIconButton {
                            enabled: false
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.DownloadOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Download' }
                        }

                        MosIconButton {
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.EllipsisOutlined
                            onClicked: contextMenu.open();

                            MosContextMenu {
                                id: contextMenu
                                y: parent.height + 2
                                menu.leftPadding: 4
                                menu.rightPadding: 4
                                menu.topPadding: 4
                                menu.bottomPadding: 4
                                defaultMenuWidth: 110
                                initModel: [
                                    { key: '1', label: 'Report', iconSource: MosIcon.WarningOutlined, },
                                    { key: '2', label: 'Mail', iconSource: MosIcon.MailOutlined },
                                    { key: '3', label: 'Mobile', iconSource: MosIcon.MobileOutlined },
                                ]
                                onClickMenu: close();
                                Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);
                            }
                        }
                    }

                    MosSpace {
                        layout: 'Row'
                        spacing: spaceSlider.currentValue
                        layoutDirection: layoutDirectionRadio.currentCheckedValue

                        MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button1' }
                        MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button2' }
                        MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button3' }
                        MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button4' }

                        MosIconButton {
                            enabled: false
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.DownloadOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Download' }
                        }

                        MosIconButton {
                            type: buttonTypeRadio.currentCheckedValue
                            iconSource: MosIcon.DownloadOutlined
                            MosToolTip { showArrow: true; visible: parent.hovered; text: 'Download' }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 15

                Row {
                    MosText {
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                        text: 'ButtonType: '
                    }
                    MosRadioBlock {
                        id: buttonTypeRadio
                        initCheckedIndex: 0
                        model: [
                            { label: 'Default', value: MosButton.Type_Default },
                            { label: 'Outlined', value: MosButton.Type_Outlined },
                            { label: 'Dashed', value: MosButton.Type_Dashed },
                            { label: 'Primary', value: MosButton.Type_Primary },
                            { label: 'Filled', value: MosButton.Type_Filled },
                        ]
                    }
                }

                Row {
                    MosText {
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                        text: 'LayoutDirection: '
                    }
                    MosRadioBlock {
                        id: layoutDirectionRadio
                        initCheckedIndex: 0
                        model: [
                            { label: 'LeftToRight', value: Qt.LeftToRight },
                            { label: 'RightToLeft', value: Qt.RightToLeft },
                        ]
                    }
                }

                Row {
                    MosText {
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                        text: 'Space: '
                    }
                    MosSlider {
                        id: spaceSlider
                        width: 200
                        height: 30
                        min: -1
                        max: 100
                        value: -1
                    }
                }

                MosSpace {
                    layout: 'Row'
                    spacing: spaceSlider.currentValue
                    layoutDirection: layoutDirectionRadio.currentCheckedValue

                    MosIconButton {
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.LikeOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Like' }
                    }

                    MosIconButton {
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.CommentOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Comment' }
                    }

                    MosIconButton {
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.StarOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Star' }
                    }

                    MosIconButton {
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.HeartOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Heart' }
                    }

                    MosIconButton {
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.ShareAltOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Share' }
                    }

                    MosIconButton {
                        enabled: false
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.DownloadOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Download' }
                    }

                    MosIconButton {
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.EllipsisOutlined
                        onClicked: contextMenu.open();

                        MosContextMenu {
                            id: contextMenu
                            y: parent.height + 2
                            menu.leftPadding: 4
                            menu.rightPadding: 4
                            menu.topPadding: 4
                            menu.bottomPadding: 4
                            defaultMenuWidth: 110
                            initModel: [
                                { key: '1', label: 'Report', iconSource: MosIcon.WarningOutlined, },
                                { key: '2', label: 'Mail', iconSource: MosIcon.MailOutlined },
                                { key: '3', label: 'Mobile', iconSource: MosIcon.MobileOutlined },
                            ]
                            onClickMenu: close();
                            Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);
                        }
                    }
                }

                MosSpace {
                    layout: 'Row'
                    spacing: spaceSlider.currentValue
                    layoutDirection: layoutDirectionRadio.currentCheckedValue

                    MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button1' }
                    MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button2' }
                    MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button3' }
                    MosButton { type: buttonTypeRadio.currentCheckedValue; text: 'Button4' }

                    MosIconButton {
                        enabled: false
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.DownloadOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Download' }
                    }

                    MosIconButton {
                        type: buttonTypeRadio.currentCheckedValue
                        iconSource: MosIcon.DownloadOutlined
                        MosToolTip { showArrow: true; visible: parent.hovered; text: 'Download' }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('列布局')
            desc: qsTr(`
layout === 'Column/ColumnLayout' 用法，等同于使用原生 \`Column/ColumnLayout\`。\n
                       `)
            code: `
                import QtQuick
                import QtQuick.Layouts
                import MosuiBasic

                Row {
                    spacing: 15

                    MosSpace {
                        layout: 'Column'

                        MosButton { text: 'Button1' }
                        MosButton { text: 'Button2' }
                        MosButton { text: 'Button3' }
                    }

                    MosSpace {
                        layout: 'Column'

                        MosButton { type: MosButton.Type_Dashed; text: 'Button1' }
                        MosButton { type: MosButton.Type_Dashed; text: 'Button2' }
                        MosButton { type: MosButton.Type_Dashed; text: 'Button3' }
                    }

                    MosSpace {
                        layout: 'Column'

                        MosButton { type: MosButton.Type_Primary; text: 'Button1' }
                        MosButton { type: MosButton.Type_Primary; text: 'Button2' }
                        MosButton { type: MosButton.Type_Primary; text: 'Button3' }
                    }
                }
            `
            exampleDelegate: Row {
                spacing: 15

                MosSpace {
                    layout: 'Column'

                    MosButton { text: 'Button1' }
                    MosButton { text: 'Button2' }
                    MosButton { text: 'Button3' }
                }

                MosSpace {
                    layout: 'Column'

                    MosButton { type: MosButton.Type_Dashed; text: 'Button1' }
                    MosButton { type: MosButton.Type_Dashed; text: 'Button2' }
                    MosButton { type: MosButton.Type_Dashed; text: 'Button3' }
                }

                MosSpace {
                    layout: 'Column'

                    MosButton { type: MosButton.Type_Primary; text: 'Button1' }
                    MosButton { type: MosButton.Type_Primary; text: 'Button2' }
                    MosButton { type: MosButton.Type_Primary; text: 'Button3' }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('网格布局')
            desc: qsTr(`
layout === 'Grid/GridLayout' 用法，等同于使用原生 \`Grid/GridLayout\`。\n
\`MosSpace\` 会自动组合子组件，使它们看起来像一个整体。\n
                       `)
            code: `
                import QtQuick
                import QtQuick.Layouts
                import MosuiBasic

                Column {
                    spacing: 15

                    Row {
                        MosText {
                            width: 120
                            anchors.verticalCenter: parent.verticalCenter
                            text: 'LayoutDirection: '
                        }
                        MosRadioBlock {
                            id: layoutDirectionRadio2
                            initCheckedIndex: 0
                            model: [
                                { label: 'LeftToRight', value: Qt.LeftToRight },
                                { label: 'RightToLeft', value: Qt.RightToLeft },
                            ]
                        }
                    }

                    MosSpace {
                        layout: 'GridLayout'
                        rows: 3
                        columns: 3
                        layoutDirection: layoutDirectionRadio2.currentCheckedValue

                        MosButton { Layout.preferredWidth: 100; z: hovered ? 1 : 0; type: MosButton.Type_Primary; text: 'Button1' }
                        MosButton { Layout.preferredWidth: 100; z: hovered ? 1 : 0; text: 'Button2' }
                        MosIconButton { Layout.fillWidth: true; z: hovered ? 1 : 0; iconSource: MosIcon.LikeOutlined }

                        MosSelect {
                            Layout.preferredWidth: 100
                            z: active ? 1 : 0
                            currentIndex: 0
                            model: [
                                { label: 'Between' },
                                { label: 'Except' },
                            ]
                        }
                        MosInput {
                            Layout.preferredWidth: 150
                            Layout.columnSpan: 2
                            z: hovered ? 1 : 0
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: '$'
                            colorBg: MosTheme.Primary.colorFillPrimary
                            verticalAlignment: MosLabel.AlignVCenter
                            horizontalAlignment : MosLabel.AlignHCenter
                        }
                        MosInput {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 100
                            z: hovered ? 1 : 0
                            text: '1,000,000'
                        }
                        MosIconButton {
                            Layout.fillWidth: true
                            z: hovered ? 1 : 0
                            iconSource: MosIcon.SearchOutlined
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 15

                Row {
                    MosText {
                        width: 120
                        anchors.verticalCenter: parent.verticalCenter
                        text: 'LayoutDirection: '
                    }
                    MosRadioBlock {
                        id: layoutDirectionRadio2
                        initCheckedIndex: 0
                        model: [
                            { label: 'LeftToRight', value: Qt.LeftToRight },
                            { label: 'RightToLeft', value: Qt.RightToLeft },
                        ]
                    }
                }

                MosSpace {
                    layout: 'GridLayout'
                    rows: 3
                    columns: 3
                    layoutDirection: layoutDirectionRadio2.currentCheckedValue

                    MosButton { Layout.preferredWidth: 100; z: hovered ? 1 : 0; type: MosButton.Type_Primary; text: 'Button1' }
                    MosButton { Layout.preferredWidth: 100; z: hovered ? 1 : 0; text: 'Button2' }
                    MosIconButton { Layout.fillWidth: true; z: hovered ? 1 : 0; iconSource: MosIcon.LikeOutlined }

                    MosSelect {
                        Layout.preferredWidth: 100
                        z: active ? 1 : 0
                        currentIndex: 0
                        model: [
                            { label: 'Between' },
                            { label: 'Except' },
                        ]
                    }
                    MosInput {
                        Layout.preferredWidth: 150
                        Layout.columnSpan: 2
                        z: active ? 1 : 0
                    }

                    MosLabel {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: '$'
                        colorBg: MosTheme.Primary.colorFillPrimary
                        verticalAlignment: MosLabel.AlignVCenter
                        horizontalAlignment : MosLabel.AlignHCenter
                    }
                    MosInput {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 100
                        z: active ? 1 : 0
                        text: '1,000,000'
                    }
                    MosIconButton {
                        Layout.fillWidth: true
                        z: hovered ? 1 : 0
                        iconSource: MosIcon.SearchOutlined
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr('常见组合')
            desc: qsTr(`
一些常见的组合例子。\n
                       `)
            code: `
                import QtQuick
                import QtQuick.Layouts
                import MosuiBasic

                Column {
                    spacing: 10

                    MosSpace {
                        layout: 'Row'

                        MosInput { width: 100; text: '0571' }
                        MosInput { width: 150; text: '26888888' }
                    }

                    MosSpace {
                        layout: 'Row'

                        MosInput { text: 'https://github.com/mengps/MosuiBasic' }
                        MosButton { type: MosButton.Type_Primary; text: 'Submit' }
                    }

                    MosSpace {
                        layout: 'Row'

                        MosInput { text: 'https://github.com/mengps/MosuiBasic' }
                        MosIconButton { iconSource: MosIcon.CopyOutlined }
                    }

                    MosSpace {
                        layout: 'Row'

                        MosSelect { model: [{ label: 'Jiangsu' }, { label: 'Hubei' }] }
                        MosInput { width: 300; text: 'Pukou District, Nanjing' }
                    }

                    MosSpace {
                        layout: 'Row'

                        MosMultiSelect { width: 300; options: [{ label: 'Jiangsu' }, { label: 'Hubei' }] }
                        MosInput { width: 300; text: 'Pukou District, Nanjing' }
                    }

                    MosSpace {
                        layout: 'Row'

                        MosInput { width: 200; text: 'input content' }
                        MosDateTimePicker { width: 200; placeholderText: 'Please select date' }
                    }

                    MosSpace {
                        layout: 'RowLayout'

                        MosDateTimePicker { Layout.preferredWidth: 200; placeholderText: 'Please select start date' }
                        MosLabel { Layout.fillHeight: true; text: '  =>  '; verticalAlignment: MosLabel.AlignVCenter }
                        MosDateTimePicker { Layout.preferredWidth: 200; placeholderText: 'Please select end date' }
                    }

                    MosSpace {
                        layout: 'Row'

                        MosInput { width: 200; text: 'input content' }
                        MosColorPicker { }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosSpace {
                    layout: 'Row'

                    MosInput { width: 100; text: '0571' }
                    MosInput { width: 150; text: '26888888' }
                }

                MosSpace {
                    layout: 'Row'

                    MosInput { text: 'https://github.com/mengps/MosuiBasic' }
                    MosButton { type: MosButton.Type_Primary; text: 'Submit' }
                }

                MosSpace {
                    layout: 'Row'

                    MosInput { text: 'https://github.com/mengps/MosuiBasic' }
                    MosIconButton { iconSource: MosIcon.CopyOutlined }
                }

                MosSpace {
                    layout: 'Row'

                    MosSelect { model: [{ label: 'Jiangsu' }, { label: 'Hubei' }] }
                    MosInput { width: 300; text: 'Pukou District, Nanjing' }
                }

                MosSpace {
                    layout: 'Row'

                    MosMultiSelect { width: 300; options: [{ label: 'Jiangsu' }, { label: 'Hubei' }] }
                    MosInput { width: 300; text: 'Pukou District, Nanjing' }
                }

                MosSpace {
                    layout: 'Row'

                    MosInput { width: 200; text: 'input content' }
                    MosDateTimePicker { width: 200; placeholderText: 'Please select date' }
                }

                MosSpace {
                    layout: 'RowLayout'

                    MosDateTimePicker { Layout.preferredWidth: 200; placeholderText: 'Please select start date' }
                    MosLabel { Layout.fillHeight: true; text: '  =>  '; verticalAlignment: MosLabel.AlignVCenter }
                    MosDateTimePicker { Layout.preferredWidth: 200; placeholderText: 'Please select end date' }
                }

                MosSpace {
                    layout: 'Row'

                    MosInput { width: 200; text: 'input content' }
                    MosColorPicker { }
                }
            }
        }
    }
}
