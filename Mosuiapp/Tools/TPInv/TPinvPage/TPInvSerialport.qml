import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle{
    id: serialportPage
    color: "transparent"

    property Component leftItemcontrols: Item{
        id : leftItem
        MosRectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: MosTheme.Primary.colorSplit
            border.width: 1
        }

        ColumnLayout{
            anchors.fill: parent
            spacing: 0
            anchors.margins: 0
            MosGroupBox {
                label: Text { text: "串口设置"; color: MosTheme.Primary.colorTextPrimary }
                title: "串口设置"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: colContent1.implicitHeight + 30

                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }

                Column {
                    id: colContent1
                    anchors.topMargin: 50
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 5
                    anchors.margins: 0
                    Repeater {
                        model: [
                            {
                                name: "端口",
                                modelSelect: [
                                    { value: 'COM1', label: 'COM1' },
                                    { value: 'COM2', label: 'COM2' },
                                    { value: 'COM3', label: 'COM3' },
                                ]
                            },
                            {
                                name: "波特率",
                                modelSelect: [
                                    { value: '9600', label: '9600' },
                                    { value: '115200', label: '115200' },
                                ]
                            },
                            {
                                name: "数据位",
                                modelSelect: [
                                    { value: '8', label: '8' },
                                    { value: '7', label: '7' },
                                ]
                            },
                            {
                                name: "校验位",
                                modelSelect: [
                                    { value: 'none', label: '无' },
                                    { value: 'even', label: '偶' },
                                    { value: 'odd', label: '奇' },

                                ]
                            },
                            {
                                name: "停止位",
                                modelSelect: [
                                    { value: '1', label: '1' },
                                    { value: '2', label: '2' },
                                ]
                            },
                            {
                                name: "流控",
                                modelSelect: [
                                    { value: 'none', label: '无' },
                                    { value: 'hardware', label: '硬件' },
                                    { value: 'software', label: '软件' },
                                ]
                            }

                        ]

                        delegate: RowLayout {
                            spacing: 10
                            width: parent.width
                            

                            MosText {
                                text: modelData.name
                                Layout.topMargin: {
                                    if (index === 0) {
                                        return 20
                                    } else {
                                        return 0
                                    }
                                }
                                Layout.preferredWidth: 60
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }

                            MosSelect {
                                Layout.fillWidth: true
                                Layout.topMargin: {
                                    if (index === 0) {
                                        return 20
                                    } else {
                                        return 0
                                    }
                                }
                                model: modelData.modelSelect
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                        }
                    }
                }
            }
            MosGroupBox {
                label: Text { text: "接收设置"; color: MosTheme.Primary.colorTextPrimary }
                title: "接收设置"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: colContent2.implicitHeight + 30

                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                ColumnLayout {
                    id: colContent2
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10
                    anchors.margins: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        ButtonGroup { id: colContent2Group}
                        Repeater {
                            model: [
                                { value: 'ASCII', label: 'ASCII' },
                                { value: 'HEX', label: 'HEX' },
                            ]

                            delegate: MosRadio {
                                Layout.alignment: {
                                    if (index == 0) {
                                        Qt.AlignLeft | Qt.AlignVCenter
                                    } else {
                                        Qt.AlignRight | Qt.AlignVCenter
                                    }
                                }
                                checked: index === 0
                                Layout.fillWidth: true
                                text: modelData.label
                                ButtonGroup.group: colContent2Group
                                Layout.leftMargin: index === 0 ? 20 : 0
                                Layout.rightMargin: index === 1 ? 20 : 0
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 20
                        spacing: parent.spacing
                        Repeater{
                            model: [
                                { value: '0', label: '自动换行' },
                                { value: '1', label: '自动发送' },
                                { value: '2', label: '显示时间' },
                            ]
                            delegate: MosCheckBox {
                                text: modelData.label
                                Layout.leftMargin: 20
                            }
                        }
                    }
                }
            }
            MosGroupBox {
                label: Text { text: "发送设置"; color: MosTheme.Primary.colorTextPrimary }
                title: "发送设置"
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: colContent3.implicitHeight + 30

                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                ColumnLayout {
                    id: colContent3
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10
                    anchors.margins: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 20
                        ButtonGroup { id: colContent3Group}
                        Repeater {
                            model: [
                                { value: 'ASCII', label: 'ASCII' },
                                { value: 'HEX', label: 'HEX' },
                            ]
                            delegate: MosRadio {
                                Layout.alignment: {
                                    if (index == 0) {
                                        Qt.AlignLeft | Qt.AlignVCenter
                                    } else {
                                        Qt.AlignRight | Qt.AlignVCenter
                                    }
                                }
                                checked: index === 0
                                Layout.fillWidth: true
                                text: modelData.label
                                ButtonGroup.group: colContent3Group
                                Layout.leftMargin: index === 0 ? 20 : 0
                                Layout.rightMargin: index === 1 ? 20 : 0
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        MosCheckBox {
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            Layout.leftMargin: 20
                            Layout.fillWidth: true
                            text: '自动发送'
                        }
                        MosInputInteger {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            value: 100
                            Layout.minimumWidth: implicitWidth + 20
                            step: 10
                            Layout.rightMargin: 20
                            Layout.fillWidth: true
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 20
                        spacing: parent.spacing
                        Repeater{

                            model: [
                                { name: "指令数量" , value: 10 },
                                { name: "指令字节数" , value: 20},
                                { name: "指令间隔" , value: 500}
                            ]
                            delegate: RowLayout {
                                spacing: 10
                                MosText {
                                    text: modelData.name
                                    Layout.preferredWidth: 60
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 20
                                }
                                MosInputInteger {
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    value: modelData.value
                                    Layout.rightMargin: 20
                                    Layout.minimumWidth: implicitWidth + 20
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    property Component rightItemcontrols: Item{
        id : rightItem
        anchors.fill: parent
        MosRectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: MosTheme.Primary.colorFillPrimary
        }
        ColumnLayout{
            anchors.fill: parent
            spacing: 0
            anchors.margins: 0
            MosGroupBox {
                label: Text { text: "数据接收区"; color: MosTheme.Primary.colorTextPrimary }
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                MosTextArea {
                    id: serialportTextArea
                    anchors.fill: parent
                    anchors.margins: 0
                    autoSize: true
                    readOnly: true
                    colorBg: "transparent"
                    colorBorder: MosTheme.Primary.colorSplit
                    placeholderText: '数据接收区'
                }
                
            }
            MosGroupBox {
                label: Text { text: "数据发送编辑区"; color: MosTheme.Primary.colorTextPrimary }
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                background: MosRectangle {
                    color: "transparent"
                    border.color: MosTheme.Primary.colorSplit
                    border.width: 1
                }
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    anchors.margins: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    MosTableView {
                        id: myCmdTable
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // 列定义：和你的 Byte0~Byte7 对应
                        columns: [
                            { dataIndex: "cmd", title: "", width: 60 },
                            { dataIndex: "Byte0", title: "Byte0", width: 100 },
                            { dataIndex: "Byte1", title: "Byte1", width: 100 },
                            { dataIndex: "Byte2", title: "Byte2", width: 100 },
                            { dataIndex: "Byte3", title: "Byte3", width: 100 },
                            { dataIndex: "Byte4", title: "Byte4", width: 100 },
                            { dataIndex: "Byte5", title: "Byte5", width: 100 },
                            { dataIndex: "Byte6", title: "Byte6", width: 100 },
                            { dataIndex: "Byte7", title: "Byte7", width: 100 }
                        ]

                        // 关键：初始化所有单元格为空
                        initModel: [
                            { key: "Cmd0", cmd: "Cmd0", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" },
                            { key: "Cmd1", cmd: "Cmd1", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" },
                            { key: "Cmd2", cmd: "Cmd2", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" },
                            { key: "Cmd3", cmd: "Cmd3", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" },
                            { key: "Cmd4", cmd: "Cmd4", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" },
                            { key: "Cmd5", cmd: "Cmd5", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" },
                            { key: "Cmd6", cmd: "Cmd6", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" },
                            { key: "Cmd7", cmd: "Cmd7", Byte0: "", Byte1: "", Byte2: "", Byte3: "", Byte4: "", Byte5: "", Byte6: "", Byte7: "" }
                        ]
                    }
 
                }

                














            }
        }










    }

    Loader {
        id: leftLoader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: parent.width/4
        active: true
        sourceComponent: serialportPage.leftItemcontrols
    }

    Loader {
        id: rightLoader
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: leftLoader.right
        active: true
        sourceComponent: serialportPage.rightItemcontrols
    }

}