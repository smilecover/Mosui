import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

import '../../Controls'

Flickable {
    contentHeight: column.height
    ScrollBar.vertical: MosScrollBar { anchors.right: parent.right }

    Column {
        id: column
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 15
        spacing: 30

        MosDescription {
            desc: qsTr(`
# MosSerialPortManager 串口管理器

\`MosSerialPortManager\` 是基于 \`QSerialPort\` 的 QML 单例，用于串口扫描、单串口/多串口连接、读写数据、错误上报和 C++ 后端共享串口数据。

* **模块 { MosuiBasic }**
* **类型 { QML Singleton }**
* **C++ 单例 { MosSerialPortManager::instance() }**
* **底层 { QSerialPort + 独立串口线程 }**

<br/>

### 设计要点

\`MosSerialPortManager\` 内部按 \`portName\` 管理多个 \`QSerialPort\` 实例。QML 页面、C++ 协议解析器、波形采集器拿到的是同一个全局管理器，因此可以在不同页面同时监听同一份串口数据。

\`currentPortName\` 是默认读写目标。\`SendText/SendHex/SendBytes\` 写当前串口；多设备场景应优先使用 \`SendTextToPort/SendHexToPort/SendBytesToPort\`，避免当前串口切换导致写错设备。

\`isOpen\` 只表示 \`currentPortName\` 当前是否打开；如果需要表达整体连接状态，使用 \`hasOpenPorts/openPortCount/openPortNames/openPortList\`。
                       `)
        }

        MosDescription {
            title: qsTr('属性')
            desc: qsTr(`
属性名 | 类型 | 说明
------ | --- | ---
portInfoList | QVariantList | 最近一次 \`refreshPorts()\` 扫描到的可用串口列表
isOpen | bool | 当前默认串口 \`currentPortName\` 是否打开
hasOpenPorts | bool | 是否存在任意已打开串口
openPortCount | int | 已打开串口数量
currentPortName | string | 当前默认读写串口名
openPortNames | QStringList | 所有已打开串口名，按名称排序
openPortList | QVariantList | 已打开串口详情列表
errorString | string | 最近一次错误文本

<br/>

### portInfoList 项字段

字段名 | 类型 | 说明
------ | --- | ---
value | string | 串口名，等同于 \`portName\`，可直接作为 \`MosSelect.valueRole\`
label | string | 展示文本。若有描述，格式为 \`COM3 (USB Serial)\`
portName | string | 串口名，例如 \`COM3\`
systemLocation | string | 系统路径
description | string | 设备描述
manufacturer | string | 厂商
serialNumber | string | 序列号
vendorIdentifier | int | USB VID，存在时才有
productIdentifier | int | USB PID，存在时才有

<br/>

### openPortList 项字段

字段名 | 类型 | 说明
------ | --- | ---
portName | string | 串口名
isOpen | bool | 该串口是否打开
baudRate | int | 当前波特率
dataBits | int | 当前数据位
parity | int | Qt 的 \`QSerialPort::Parity\` 枚举值
stopBits | int | Qt 的 \`QSerialPort::StopBits\` 枚举值
flowControl | int | Qt 的 \`QSerialPort::FlowControl\` 枚举值
errorString | string | 该串口最近错误文本
                       `)
        }

        MosDescription {
            title: qsTr('方法')
            desc: qsTr(`
名称 | 返回值 | 说明
------ | --- | ---
refreshPorts() | QVariantList | 扫描系统可用串口，更新并返回 \`portInfoList\`
selectPort(portName) | bool | 设置 \`currentPortName\`，不会打开串口
isPortOpen(portName) | bool | 判断指定串口是否已打开
openPort(portName, baudRate, dataBits, parity, stopBits, flowControl) | bool | 打开或重新打开指定串口，并将其设为当前串口
closePort() | void | 关闭当前默认串口
closePort(portName) | void | 关闭指定串口
closeAllPorts() | void | 关闭全部串口
SendText(text) | bool | 向当前串口写 UTF-8 文本
SendTextToPort(portName, text) | bool | 向指定串口写 UTF-8 文本
SendHex(hexText) | bool | 向当前串口写 HEX 数据
SendHexToPort(portName, hexText) | bool | 向指定串口写 HEX 数据
SendBytes(data) | bool | 向当前串口写 \`QByteArray\`
SendBytesToPort(portName, data) | bool | 向指定串口写 \`QByteArray\`
bytesToHex(data) | string | 将 \`QByteArray\` 转为大写、空格分隔 HEX 文本
clearError() | void | 清空 \`errorString\`

<br/>

### openPort 参数

参数 | 建议值 | 说明
--- | --- | ---
baudRate | \`9600\`, \`115200\` | 直接传整数
dataBits | \`5\`, \`6\`, \`7\`, \`8\` | 非 5-8 时默认按 8 位处理
parity | \`"none"\`, \`"even"\`, \`"odd"\`, \`"mark"\`, \`"space"\` | 不匹配时按 \`none\`
stopBits | \`"1"\`, \`"1.5"\`, \`"2"\` | 不匹配时按 1 位
flowControl | \`"none"\`, \`"hardware"\`, \`"software"\` | 不匹配时按 \`none\`

\`SendHex/SendHexToPort\` 支持空格、逗号、分号、换行和 \`0x\` 前缀；清理后必须是偶数长度的合法十六进制字符，否则返回 \`false\` 并写入 \`errorString\`。
                       `)
        }

        MosDescription {
            title: qsTr('信号')
            desc: qsTr(`
名称 | 说明
------ | ---
portInfoListChanged() | 可用串口列表变化
isOpenChanged() | 当前串口打开状态变化
currentPortNameChanged() | 当前默认串口变化
errorStringChanged() | 错误文本变化
openPortsChanged() | 已打开串口集合变化
ReceiveData(data, text, hex) | 任意串口收到数据，适合单串口工具
ReceiveDataFromPort(portName, data, text, hex) | 指定来源串口收到数据，适合多串口工具
BytesSent(bytes) | 任意串口写入完成
BytesSentFromPort(portName, bytes) | 指定串口写入完成
errorOccurred(message) | 任意串口发生错误
errorOccurredFromPort(portName, message) | 指定串口发生错误

\`data\` 是原始字节，适合协议解析；\`text\` 是 UTF-8 文本视图；\`hex\` 是大写空格分隔 HEX 文本。资源错误会自动关闭对应串口，并触发 \`openPortsChanged()\`。
                       `)
        }

        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
扫描串口并打开选中的端口。单串口页面可以直接使用 \`isOpen/currentPortName/SendHex/ReceiveData\` 这一组简化接口。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

ColumnLayout {
    property var portOptions: []
    property string selectedPortName: ""

    Component.onCompleted: refreshPorts()

    function refreshPorts() {
        portOptions = MosSerialPortManager.refreshPorts()
        selectedPortName = portOptions.length > 0 ? portOptions[0].value : ""
    }

    MosSelect {
        Layout.fillWidth: true
        model: portOptions
        enabled: !MosSerialPortManager.isOpen
        onActivated: selectedPortName = currentValue
    }

    MosButton {
        text: MosSerialPortManager.isOpen ? qsTr("关闭串口") : qsTr("打开串口")
        enabled: selectedPortName.length > 0 || MosSerialPortManager.isOpen
        onClicked: {
            if (MosSerialPortManager.isOpen)
                MosSerialPortManager.closePort()
            else
                MosSerialPortManager.openPort(selectedPortName, 115200, 8, "none", "1", "none")
        }
    }
}
            `
            exampleDelegate: ColumnLayout {
                id: singlePortExample

                width: parent ? parent.width : 760
                spacing: 10

                property var portOptions: []
                property string selectedPortName: ""

                Component.onCompleted: refreshPorts()

                function refreshPorts() {
                    portOptions = MosSerialPortManager.refreshPorts()
                    let selectedStillExists = false
                    for (let i = 0; i < portOptions.length; ++i) {
                        if (portOptions[i].value === selectedPortName) {
                            selectedStillExists = true
                            break
                        }
                    }
                    if (portOptions.length > 0 && !selectedStillExists)
                        selectedPortName = portOptions[0].value
                    else if (portOptions.length === 0)
                        selectedPortName = ""
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MosSelect {
                        Layout.fillWidth: true
                        model: singlePortExample.portOptions
                        placeholderText: qsTr("请选择串口")
                        enabled: !MosSerialPortManager.isOpen
                        currentIndex: {
                            for (let i = 0; i < singlePortExample.portOptions.length; ++i) {
                                if (singlePortExample.portOptions[i].value === singlePortExample.selectedPortName)
                                    return i
                            }
                            return singlePortExample.portOptions.length > 0 ? 0 : -1
                        }
                        onActivated: singlePortExample.selectedPortName = currentValue
                    }

                    MosButton {
                        Layout.preferredWidth: 90
                        text: qsTr("刷新")
                        enabled: !MosSerialPortManager.isOpen
                        onClicked: singlePortExample.refreshPorts()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MosButton {
                        Layout.preferredWidth: 120
                        text: MosSerialPortManager.isOpen ? qsTr("关闭串口") : qsTr("打开串口")
                        type: MosSerialPortManager.isOpen ? MosButton.Type_Default : MosButton.Type_Primary
                        enabled: singlePortExample.selectedPortName.length > 0 || MosSerialPortManager.isOpen
                        onClicked: {
                            if (MosSerialPortManager.isOpen)
                                MosSerialPortManager.closePort()
                            else
                                MosSerialPortManager.openPort(singlePortExample.selectedPortName, 115200, 8, "none", "1", "none")
                        }
                    }

                    MosText {
                        Layout.fillWidth: true
                        text: MosSerialPortManager.currentPortName.length > 0
                              ? qsTr("当前：") + MosSerialPortManager.currentPortName
                              : qsTr("未选择串口")
                        color: MosTheme.Primary.colorTextSecondary
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
多串口页面应使用 \`isPortOpen(portName)\` 判断单个串口状态，并用 \`openPortList/openPortNames\` 展示整体连接状态。
                       `)
            code: `
ColumnLayout {
    property var portOptions: []
    property string selectedPortName: ""

    Component.onCompleted: portOptions = MosSerialPortManager.refreshPorts()

    MosSelect {
        Layout.fillWidth: true
        model: portOptions
        onActivated: selectedPortName = currentValue
    }

    RowLayout {
        MosButton {
            text: MosSerialPortManager.isPortOpen(selectedPortName) ? qsTr("关闭该串口") : qsTr("打开该串口")
            enabled: selectedPortName.length > 0
            onClicked: {
                if (MosSerialPortManager.isPortOpen(selectedPortName))
                    MosSerialPortManager.closePort(selectedPortName)
                else
                    MosSerialPortManager.openPort(selectedPortName, 115200, 8, "none", "1", "none")
            }
        }

        MosButton {
            text: qsTr("关闭全部")
            enabled: MosSerialPortManager.hasOpenPorts
            onClicked: MosSerialPortManager.closeAllPorts()
        }
    }

    Repeater {
        model: MosSerialPortManager.openPortList
        delegate: MosText {
            text: modelData.portName + "  " + modelData.baudRate + "bps"
        }
    }
}
            `
            exampleDelegate: ColumnLayout {
                id: multiPortExample

                width: parent ? parent.width : 760
                spacing: 10

                property var portOptions: []
                property string selectedPortName: ""

                Component.onCompleted: refreshPorts()

                function refreshPorts() {
                    portOptions = MosSerialPortManager.refreshPorts()
                    if (portOptions.length > 0 && selectedPortName.length === 0)
                        selectedPortName = portOptions[0].value
                    if (portOptions.length === 0)
                        selectedPortName = ""
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MosSelect {
                        Layout.fillWidth: true
                        model: multiPortExample.portOptions
                        placeholderText: qsTr("选择要操作的串口")
                        currentIndex: {
                            for (let i = 0; i < multiPortExample.portOptions.length; ++i) {
                                if (multiPortExample.portOptions[i].value === multiPortExample.selectedPortName)
                                    return i
                            }
                            return multiPortExample.portOptions.length > 0 ? 0 : -1
                        }
                        onActivated: multiPortExample.selectedPortName = currentValue
                    }

                    MosButton {
                        Layout.preferredWidth: 90
                        text: qsTr("刷新")
                        onClicked: multiPortExample.refreshPorts()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MosButton {
                        Layout.preferredWidth: 130
                        text: MosSerialPortManager.isPortOpen(multiPortExample.selectedPortName) ? qsTr("关闭该串口") : qsTr("打开该串口")
                        enabled: multiPortExample.selectedPortName.length > 0
                        type: MosSerialPortManager.isPortOpen(multiPortExample.selectedPortName) ? MosButton.Type_Default : MosButton.Type_Primary
                        onClicked: {
                            if (MosSerialPortManager.isPortOpen(multiPortExample.selectedPortName))
                                MosSerialPortManager.closePort(multiPortExample.selectedPortName)
                            else
                                MosSerialPortManager.openPort(multiPortExample.selectedPortName, 115200, 8, "none", "1", "none")
                        }
                    }

                    MosButton {
                        Layout.preferredWidth: 110
                        text: qsTr("设为当前")
                        enabled: multiPortExample.selectedPortName.length > 0
                        onClicked: MosSerialPortManager.selectPort(multiPortExample.selectedPortName)
                    }

                    MosButton {
                        Layout.preferredWidth: 110
                        text: qsTr("关闭全部")
                        enabled: MosSerialPortManager.hasOpenPorts
                        onClicked: MosSerialPortManager.closeAllPorts()
                    }
                }

                MosText {
                    Layout.fillWidth: true
                    text: qsTr("已打开：") + MosSerialPortManager.openPortCount
                          + qsTr(" 个  当前：")
                          + (MosSerialPortManager.currentPortName.length > 0 ? MosSerialPortManager.currentPortName : qsTr("无"))
                    color: MosTheme.Primary.colorTextSecondary
                }

                Repeater {
                    model: MosSerialPortManager.openPortList

                    delegate: MosRectangle {
                        required property var modelData

                        width: multiPortExample.width
                        height: 34
                        radius: 6
                        color: "transparent"
                        border.color: MosTheme.Primary.colorSplit

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10

                            MosText {
                                Layout.fillWidth: true
                                text: modelData.portName + "  " + modelData.baudRate + "bps"
                                color: MosTheme.Primary.colorTextPrimary
                                verticalAlignment: Text.AlignVCenter
                            }

                            MosButton {
                                Layout.preferredWidth: 76
                                text: qsTr("关闭")
                                onClicked: MosSerialPortManager.closePort(modelData.portName)
                            }
                        }
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
接收串口数据。单串口工具可以监听 \`ReceiveData\`；多串口工具应监听 \`ReceiveDataFromPort\`，并按 \`portName\` 分发。
                       `)
            code: `
Connections {
    target: MosSerialPortManager

    function onReceiveData(data, text, hex) {
        console.log("RX current/any:", hex)
    }

    function onReceiveDataFromPort(portName, data, text, hex) {
        console.log("RX from", portName, hex)
    }

    function onErrorOccurredFromPort(portName, message) {
        console.warn(portName, message)
    }
}
            `
            exampleDelegate: ColumnLayout {
                width: parent ? parent.width : 760
                spacing: 8

                MosText {
                    text: qsTr("最近接收")
                    color: MosTheme.Primary.colorTextPrimary
                    font.bold: true
                }

                MosTextArea {
                    id: receivePreview
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    readOnly: true
                    autoSize: true
                    colorBg: "transparent"
                    placeholderText: qsTr("打开串口后，收到的数据会显示在这里")
                }

                Connections {
                    target: MosSerialPortManager

                    function onReceiveDataFromPort(portName, data, text, hex) {
                        receivePreview.text += "[" + portName + "] HEX " + hex + "\\n"
                        receivePreview.scrollToEnd()
                    }

                    function onErrorOccurredFromPort(portName, message) {
                        receivePreview.text += "[" + portName + "] ERROR " + message + "\\n"
                        receivePreview.scrollToEnd()
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
写入数据时，\`SendText/SendHex/SendBytes\` 使用当前串口；\`SendTextToPort/SendHexToPort/SendBytesToPort\` 可以明确指定串口。\`SendHex\` 返回 \`false\` 时可读取 \`errorString\`。
                       `)
            code: `
// 写当前串口
MosSerialPortManager.SendText("AT\\r\\n")
MosSerialPortManager.SendHex("01 03 00 00 00 02 C4 0B")

// 写指定串口
MosSerialPortManager.SendTextToPort("COM3", "AT\\r\\n")
MosSerialPortManager.SendHexToPort("COM4", "AA 55 01 02")

// QByteArray 转 HEX 文本
const hex = MosSerialPortManager.bytesToHex(data)
            `
            exampleDelegate: ColumnLayout {
                width: parent ? parent.width : 760
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MosInput {
                        id: sendInput
                        Layout.fillWidth: true
                        placeholderText: qsTr("HEX 数据，例如：AA 55 01 02")
                        colorBg: "transparent"
                    }

                    MosButton {
                        Layout.preferredWidth: 110
                        text: qsTr("发送 HEX")
                        type: MosButton.Type_Primary
                        enabled: MosSerialPortManager.isOpen && sendInput.text.length > 0
                        onClicked: {
                            if (!MosSerialPortManager.SendHex(sendInput.text))
                                sendErrorText.text = MosSerialPortManager.errorString
                        }
                    }
                }

                MosText {
                    id: sendErrorText
                    Layout.fillWidth: true
                    text: MosSerialPortManager.errorString
                    color: MosTheme.Primary.colorErrorText
                    visible: text.length > 0
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
C++ 后端可以直接连接同一个单例，不需要从 QML 页面转发数据。这样协议解析器、波形处理器和界面可以并行监听串口。
                       `)
            code: `
#include "MosSerialPortManager.h"

auto manager = MosSerialPortManager::instance();

connect(manager,
        &MosSerialPortManager::ReceiveDataFromPort,
        this,
        &YourParser::onSerialReceiveDataFromPort);

connect(manager,
        &MosSerialPortManager::errorOccurredFromPort,
        this,
        &YourParser::onSerialErrorFromPort);

void YourParser::onSerialReceiveDataFromPort(const QString &portName,
                                              const QByteArray &data,
                                              const QString &text,
                                              const QString &hex)
{
    Q_UNUSED(text)
    Q_UNUSED(hex)

    // portName 区分 COM1 / COM2 ...
    // data 是原始串口字节，适合做协议解析
}
            `
        }

        MosDescription {
            title: qsTr('使用建议')
            desc: qsTr(`
- 单串口工具可以使用 \`isOpen/currentPortName/SendHex/ReceiveData\`，代码最简洁。
- 多串口工具优先使用 \`isPortOpen(portName)\` 判断单个串口，使用 \`hasOpenPorts/openPortCount/openPortNames/openPortList\` 表达整体状态。
- 多串口接收时优先监听 \`ReceiveDataFromPort\`，并按 \`portName\` 分发到不同协议解析器。
- 多串口发送时优先使用 \`SendHexToPort/SendTextToPort/SendBytesToPort\`，避免当前串口切换导致写错设备。
- \`selectPort(portName)\` 只切换默认目标，不会打开串口；\`openPort(...)\` 成功后会自动把该串口设为当前串口。
- 串口资源错误会自动关闭对应串口并更新 \`openPortList\`，界面应监听 \`openPortsChanged\` 或直接绑定相关属性。
- C++ 后端应直接连接 \`MosSerialPortManager::instance()\` 的信号，不需要从 QML 页面取数据。
                       `)
        }
    }
}
