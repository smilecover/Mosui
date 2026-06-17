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
# MosTabView 标签页\n
通过选项卡标签切换内容的组件。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Control }**\n
\n<br/>
\n### 支持的代理：\n
- **addButtonDelegate: Component** 添加按钮的代理\n
- **highlightDelegate: Component** 高亮项(当前标签背景)代理\n
- **tabDelegate: Component** 标签代理，代理可访问属性：\n
  - \`index: int\` 模型数据索引\n
  - \`model: var\` 模型数据\n
- **contentDelegate: Component** 内容代理，代理可访问属性：\n
  - \`index: int\` 模型数据索引\n
  - \`model: var\` 模型数据\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
initModel | array | true | 标签页初始模型
count | int | true | 当前标签页数量
currentIndex | int | true | 当前标签页索引(更改该值可切换页)
tabType | enum | MosTabView.Type_Default | 标签类型(来自 MosTabView)
tabSize | enum | MosTabView.Size_Auto | 标签大小(来自 MosTabView)
tabPosition | enum | MosTabView.Position_Top | 标签位置(来自 MosTabView)
tabAlign | enum | MosTabView.Align_Left | 标签文本对齐(来自 MosTabView)
tabAddable | bool | false | 标签是否可新增
tabCentered | bool | false | 标签是否居中
tabCardMovable | bool | true | 标签卡片是否可移动(tabType == Type_Card*生效)
defaultTabWidth | int | 80 | 默认标签宽度
defaultTabHeight | int | - | 默认标签高度
defaultTabSpacing | int | 2 | 默认标签间隔
defaultTabIconSpacing | int | 2 | 默认标签图标间隔
defaultTabLeftPadding | int | 8 | 默认标签左填充
defaultTabRightPadding | int | 8 | 默认标签右填充
defaultHighlightWidth | int | 30丨20 | 默认高亮条宽度半径(tabType == Type_Default生效)
colorTabCardBg | color | - | 卡片标签背景颜色
colorTabCardBgActive | color | - | 卡片标签选中背景颜色
colorTabCardBorder | color | - | 卡片标签边框颜色
colorTabCardBorderActive | color | - | 卡片标签选中边框颜色
radiusTabBg | [MosRadius](internal://MosRadius) | - | 标签背景圆角(tabType == Type_Card*生效)
addTabCallback | function() | - | 添加标签回调(点击+按钮时调用)
closeTabCallback | function(index, data) | - | 关闭标签回调(点击x按钮时调用)
\n<br/>
\n### 模型支持的属性：\n
属性名 | 类型 | 可选/必选 | 描述
------ | --- | :---: | ---
key | string | 可选 | 本标签页的键
title | string | 可选 | 本标签的标题
iconSource | int丨string | 可选 | 本标签的图标源
iconSize | int | 可选 | 本标签的图标大小
iconSpacing | bool | 可选 | 本标签图标和文本的间隔
tabWidth | int | 可选 | 本标签宽度
tabHeight | int | 可选 | 本标签高度
editable | bool | 可选 | 本标签是否可编辑
contentDelegate | var | 可选 | 本菜单项内容代理(将覆盖contentDelegate)
\n<br/>
\n### 支持的函数：\n
- \`setCurrentIndex(index: int)\` 设置当前的索引为 \`index\`\n
- \`flick(index: int)\` 等同于调用 \`Flickable.flick()\` \n
- \`positionViewAtBeginning(index: int)\` 等同于调用 \`ListView.positionViewAtBeginning()\` \n
- \`positionViewAtIndex(index: int, mode: int)\` 等同于调用 \`ListView.positionViewAtIndex()\` \n
- \`positionViewAtEnd(index: int)\` 等同于调用 \`ListView.positionViewAtEnd()\` \n
- \`Object get(index: int)\` 获取 \`index\` 处的模型数据 \n
- \`set(index: int, object: Object)\` 设置 \`index\` 处的模型数据为 \`object\` \n
- \`setProperty(index: int, propertyName: string, value: any)\` 设置 \`index\` 处的模型数据属性名 \`propertyName\` 值为 \`value\` \n
- \`move(from: int, to: int, count: int = 1)\` 将 \`count\` 个模型数据从 \`from\` 位置移动到 \`to\` 位置 \n
- \`insert(index: int, object: Object)\` 插入标签 \`object\` 到 \`index\` 处 \n
- \`append(object: Object)\` 在末尾添加标签 \`object\` \n
- \`remove(index: int, count: int = 1)\` 删除 \`index\` 处 \`count\` 个模型数据 \n
- \`clear()\`清空所有标签和内容 \n
                       `)
        }

        Description {
            title: qsTr('何时使用')
            desc: qsTr(`
提供平级的区域将大块内容进行收纳和展现，保持界面整洁。\n
**MosuiBasic** 依次提供了三级选项卡，分别用于不同的场景。\n
- 卡片式的页签，提供可关闭的样式，常用于容器顶部。\n
- 既可用于容器顶部，也可用于容器内部，是最通用的 Tabs。\n
- [MosRadio](internal://MosRadio) 可作为更次级的页签来使用。\n
                       `)
        }

        ThemeToken {
            source: 'MosTabView'
            historySource: 'https://github.com/mengps/MosuiBasic/blob/master/src/imports/MosTabView.qml'
        }

        Description {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`initModel\` 属性设置初始标签页的模型{需为list}，标签项支持的属性有：\n
- { key: 本标签页的键 }\n
- { title: 本标签的标题 }\n
- { iconSource: 本标签的图标源 }\n
- { iconSize: 本标签的图标大小 }\n
- { iconSpacing: 本标签图标和文本的间隔 }\n
- { tabWidth: 本标签宽度 }\n
- { tabHeight: 本标签高度 }\n
- { editable: 本标签是否可编辑(tabType == Type_CardEditable时生效) }\n
通过 \`tabPosition\` 属性设置标签位置，支持的位置：\n
- 标签在上方(默认){ MosTabView.Position_Top }\n
- 标签在下方{ MosTabView.Position_Bottom }\n
- 标签在左方{ MosTabView.Position_Left }\n
- 标签在右方{ MosTabView.Position_Right }\n
通过 \`tabSize\` 属性设置标签大小计算方式，支持的方式：\n
- 自动计算标签大小(取决于文本大小){ MosTabView.Size_Auto }\n
- 固定标签大小(取决于 tabWidth 和 defaultTabWidth){ MosTabView.Size_Fixed }\n
通过 \`tabAddable\` 属性设置标签列表是否可新增\n
通过 \`tabCentered\` 属性设置标签列表是否居中\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosRadioBlock {
                        id: positionRadio1
                        initCheckedIndex: 0
                        model: [
                            { label: qsTr('上'), value: MosTabView.Position_Top },
                            { label: qsTr('下'), value: MosTabView.Position_Bottom },
                            { label: qsTr('左'), value: MosTabView.Position_Left },
                            { label: qsTr('右'), value: MosTabView.Position_Right }
                        ]
                    }

                    Row {
                        spacing: 10
    
                        MosText { text: qsTr('是否可新增') }
    
                        MosSwitch {
                            id: addableSwitch
                            checkedText: qsTr('是')
                            uncheckedText: qsTr('否')
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 10

                        MosText { text: qsTr('是否居中') }

                        MosSwitch {
                            id: isCenterSwitch
                            checkedText: qsTr('是')
                            uncheckedText: qsTr('否')
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 10

                        MosText { text: qsTr('标签大小') }

                        MosSwitch {
                            id: sizeSwitch
                            checkedText: qsTr('固定')
                            uncheckedText: qsTr('自动')
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MosTabView {
                        id: defaultTabView
                        width: parent.width
                        height: 200
                        defaultTabWidth: 40
                        tabPosition: positionRadio1.currentCheckedValue
                        tabSize: sizeSwitch.checked ? MosTabView.Size_Fixed : MosTabView.Size_Auto
                        tabAddable: addableSwitch.checked
                        tabCentered: isCenterSwitch.checked
                        addTabCallback:
                            () => {
                                append({
                                           title: 'New Tab ' + (count + 1),
                                           content: 'Content of Tab Content ',
                                           contentColor: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.24).toString()
                                       });
                                currentIndex = count - 1;
                                positionViewAtEnd();
                            }
                        contentDelegate: Rectangle {
                            color: model.contentColor

                            MosText {
                                anchors.centerIn: parent
                                text: model.content + (index + 1)
                            }
                        }
                        initModel: [
                            {
                                key: '1',
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab 1',
                                content: 'Content of Tab Content ',
                                contentColor: '#60ff0000'
                            },
                            {
                                key: '2',
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab 2',
                                content: 'Content of Tab Content ',
                                contentColor: '#6000ff00'
                            },
                            {
                                key: '3',
                                title: 'Tab 3',
                                content: 'Content of Tab Content ',
                                contentColor: '#600000ff'
                            }
                        ]
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosRadioBlock {
                    id: positionRadio1
                    initCheckedIndex: 0
                    model: [
                        { label: qsTr('上'), value: MosTabView.Position_Top },
                        { label: qsTr('下'), value: MosTabView.Position_Bottom },
                        { label: qsTr('左'), value: MosTabView.Position_Left },
                        { label: qsTr('右'), value: MosTabView.Position_Right }
                    ]
                }

                Row {
                    spacing: 10

                    MosText { text: qsTr('是否可新增') }

                    MosSwitch {
                        id: addableSwitch
                        checkedText: qsTr('是')
                        uncheckedText: qsTr('否')
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 10

                    MosText { text: qsTr('是否居中')  }

                    MosSwitch {
                        id: isCenterSwitch
                        checkedText: qsTr('是')
                        uncheckedText: qsTr('否')
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 10

                    MosText { text: qsTr('标签大小') }

                    MosSwitch {
                        id: sizeSwitch
                        checkedText: qsTr('固定')
                        uncheckedText: qsTr('自动')
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MosTabView {
                    id: defaultTabView
                    width: parent.width
                    height: 200
                    defaultTabWidth: 40
                    tabPosition: positionRadio1.currentCheckedValue
                    tabSize: sizeSwitch.checked ? MosTabView.Size_Fixed : MosTabView.Size_Auto
                    tabAddable: addableSwitch.checked
                    tabCentered: isCenterSwitch.checked
                    addTabCallback:
                        () => {
                            append({
                                       title: 'New Tab ' + (count + 1),
                                       content: 'Content of Tab Content ',
                                       contentColor: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.24).toString()
                                   });
                            currentIndex = count - 1;
                            positionViewAtEnd();
                        }
                    contentDelegate: Rectangle {
                        color: model.contentColor

                        MosText {
                            anchors.centerIn: parent
                            text: model.content + (index + 1)
                        }
                    }
                    initModel: [
                        {
                            key: '1',
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab 1',
                            content: 'Content of Tab Content ',
                            contentColor: '#60ff0000'
                        },
                        {
                            key: '2',
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab 2',
                            content: 'Content of Tab Content ',
                            contentColor: '#6000ff00'
                        },
                        {
                            key: '3',
                            title: 'Tab 3',
                            content: 'Content of Tab Content ',
                            contentColor: '#600000ff'
                        }
                    ]
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`tabType\` 属性设置标签类型，支持的类型：\n
- 默认标签(默认){ MosTabView.Type_Default }\n
- 卡片标签{ MosTabView.Type_Card }\n
- 可编辑卡片标签{ MosTabView.Type_CardEditable }\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosRadioBlock {
                        id: positionRadio2
                        initCheckedIndex: 0
                        model: [
                            { label: qsTr('上'), value: MosTabView.Position_Top },
                            { label: qsTr('下'), value: MosTabView.Position_Bottom },
                            { label: qsTr('左'), value: MosTabView.Position_Left },
                            { label: qsTr('右'), value: MosTabView.Position_Right }
                        ]
                    }

                    Row {
                        spacing: 10

                        MosText { text: qsTr('是否可新增') }

                        MosSwitch {
                            id: addableSwitch2
                            checkedText: qsTr('是')
                            uncheckedText: qsTr('否')
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 10

                        MosText { text: qsTr('是否居中') }

                        MosSwitch {
                            id: isCenterSwitch2
                            checkedText: qsTr('是')
                            uncheckedText: qsTr('否')
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 10

                        MosText { text: qsTr('标签大小') }

                        MosSwitch {
                            id: sizeSwitch2
                            checkedText: qsTr('固定')
                            uncheckedText: qsTr('自动')
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: 10

                        MosText { text: qsTr('是否可编辑') }

                        MosSwitch {
                            id: typeSwitch
                            checkedText: qsTr('是')
                            uncheckedText: qsTr('否')
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MosTabView {
                        id: cardTabView
                        width: parent.width
                        height: 200
                        defaultTabWidth: 50
                        tabPosition: positionRadio2.currentCheckedValue
                        tabSize: sizeSwitch2.checked ? MosTabView.Size_Fixed : MosTabView.Size_Auto
                        tabType: typeSwitch.checked ? MosTabView.Type_CardEditable :  MosTabView.Type_Card
                        tabAddable: addableSwitch2.checked
                        tabCentered: isCenterSwitch2.checked
                        addTabCallback:
                            () => {
                                append({
                                           title: 'New Tab ' + (count + 1),
                                           content: 'Content of Tab Content ',
                                           contentColor: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.24).toString()
                                       });
                                currentIndex = count - 1;
                                positionViewAtEnd();
                            }
                        contentDelegate: Rectangle {
                            color: model.contentColor

                            MosText {
                                anchors.centerIn: parent
                                text: model.content + (index + 1)
                            }
                        }
                        initModel: [
                            {
                                key: '1',
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab 1',
                                content: 'Content of Card Tab Content ',
                                contentColor: '#60ff0000'
                            },
                            {
                                key: '2',
                                editable: false,
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab 2',
                                content: 'Content of Card Tab Content ',
                                contentColor: '#6000ff00'
                            },
                            {
                                key: '3',
                                title: 'Tab 3',
                                content: 'Content of Card Tab Content ',
                                contentColor: '#600000ff'
                            }
                        ]
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosRadioBlock {
                    id: positionRadio2
                    initCheckedIndex: 0
                    model: [
                        { label: qsTr('上'), value: MosTabView.Position_Top },
                        { label: qsTr('下'), value: MosTabView.Position_Bottom },
                        { label: qsTr('左'), value: MosTabView.Position_Left },
                        { label: qsTr('右'), value: MosTabView.Position_Right }
                    ]
                }

                Row {
                    spacing: 10

                    MosText { text: qsTr('是否可新增') }

                    MosSwitch {
                        id: addableSwitch2
                        checkedText: qsTr('是')
                        uncheckedText: qsTr('否')
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 10

                    MosText {
                        text: qsTr('是否居中')
                        font {
                            family: MosTheme.Primary.fontPrimaryFamily
                            pixelSize: MosTheme.Primary.fontPrimarySize
                        }
                        color: MosTheme.Primary.colorTextBase
                    }

                    MosSwitch {
                        id: isCenterSwitch2
                        checkedText: qsTr('是')
                        uncheckedText: qsTr('否')
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 10

                    MosText { text: qsTr('标签大小') }

                    MosSwitch {
                        id: sizeSwitch2
                        checkedText: qsTr('固定')
                        uncheckedText: qsTr('自动')
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    spacing: 10

                    MosText { text: qsTr('是否可编辑') }

                    MosSwitch {
                        id: typeSwitch
                        checkedText: qsTr('是')
                        uncheckedText: qsTr('否')
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MosTabView {
                    id: cardTabView
                    width: parent.width
                    height: 200
                    defaultTabWidth: 50
                    tabPosition: positionRadio2.currentCheckedValue
                    tabSize: sizeSwitch2.checked ? MosTabView.Size_Fixed : MosTabView.Size_Auto
                    tabType: typeSwitch.checked ? MosTabView.Type_CardEditable :  MosTabView.Type_Card
                    tabAddable: addableSwitch2.checked
                    tabCentered: isCenterSwitch2.checked
                    addTabCallback:
                        () => {
                            append({
                                       title: 'New Tab ' + (count + 1),
                                       content: 'Content of Tab Content ',
                                       contentColor: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.24).toString()
                                   });
                            currentIndex = count - 1;
                            positionViewAtEnd();
                        }
                    contentDelegate: Rectangle {
                        color: model.contentColor

                        MosText {
                            anchors.centerIn: parent
                            text: model.content + (index + 1)
                        }
                    }
                    initModel: [
                        {
                            key: '1',
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab 1',
                            content: 'Content of Card Tab Content ',
                            contentColor: '#60ff0000'
                        },
                        {
                            key: '2',
                            editable: false,
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab 2',
                            content: 'Content of Card Tab Content ',
                            contentColor: '#6000ff00'
                        },
                        {
                            key: '3',
                            title: 'Tab 3',
                            content: 'Content of Card Tab Content ',
                            contentColor: '#600000ff'
                        }
                    ]
                }
            }
        }

        CodeBox {
            width: parent.width
            descTitle: qsTr(`高级定制`)
            desc: qsTr(`
通过 \`initModel.contentDelegate\` 属性设置单独的内容代理。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosTabView {
                        id: customTabView
                        width: parent.width
                        height: 220
                        tabSize: MosTabView.Size_Auto
                        tabType: MosTabView.Type_Card
                        initModel: [
                            {
                                key: '1',
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab CheckBoxes',
                                contentDelegate: delegate1
                            },
                            {
                                key: '2',
                                editable: false,
                                iconSource: MosIcon.CreditCardOutlined,
                                title: 'Tab Inputs',
                                contentDelegate: delegate2
                            },
                        ]

                        Component {
                            id: delegate1

                            Rectangle {
                                color: MosTheme.Primary.colorBgBase

                                Column {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5

                                    Repeater {
                                        model: 6

                                        MosCheckBox { text: 'CheckBox ' + (index + 1) }
                                    }
                                }
                            }
                        }

                        Component {
                            id: delegate2

                            Rectangle {
                                color: MosTheme.Primary.colorBgBase

                                Column {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 5

                                    Repeater {
                                        model: 5

                                        Row {
                                            spacing: 10

                                            MosText { anchors.verticalCenter: parent.verticalCenter; text: 'Input ' + (index + 1) }
                                            MosInput { width: 120 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosTabView {
                    id: customTabView
                    width: parent.width
                    height: 220
                    tabSize: MosTabView.Size_Auto
                    tabType: MosTabView.Type_Card
                    initModel: [
                        {
                            key: '1',
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab CheckBoxes',
                            contentDelegate: delegate1
                        },
                        {
                            key: '2',
                            editable: false,
                            iconSource: MosIcon.CreditCardOutlined,
                            title: 'Tab Inputs',
                            contentDelegate: delegate2
                        },
                    ]

                    Component {
                        id: delegate1

                        Rectangle {
                            color: MosTheme.Primary.colorBgBase

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                Repeater {
                                    model: 6

                                    MosCheckBox { text: 'CheckBox ' + (index + 1) }
                                }
                            }
                        }
                    }

                    Component {
                        id: delegate2

                        Rectangle {
                            color: MosTheme.Primary.colorBgBase

                            Column {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                Repeater {
                                    model: 5

                                    Row {
                                        spacing: 10

                                        MosText { anchors.verticalCenter: parent.verticalCenter; text: 'Input ' + (index + 1) }
                                        MosInput { width: 120 }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
