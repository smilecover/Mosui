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

基于 \`QSerialPort\` 的 QML 单例，提供串口扫描、打开、关闭、多串口读写、错误状态和收发信号。

* **模块 { MosuiBasic }**
* **类型 { QML Singleton }**
* **C++ 单例 { MosSerialPortManager::instance() }**
* **底层 { QSerialPort }**

<br/>

### 多串口设计

\`MosSerialPortManager\` 内部按 \`portName\` 管理多个 \`QSerialPort\` 实例。QML 和 C++ 获取到的是同一个全局管理器，因此多个页面、后端解析器和工具面板可以同时监听同一份串口数据。

\`currentPortName\` 表示默认读写目标。\`writeText/writeHex/writeBytes\` 会写入当前串口；如果需要明确写入某个串口，使用 \`writeTextToPort/writeHexToPort/writeBytesToPort\`。

<br/>

### 支持的属性：

属性名 | 类型 | 描述
------ | --- | ---
portInfoList | QVariantList | 最近一次扫描得到的可用串口列表
isOpen | bool | 当前串口 \`currentPortName\` 是否打开
hasOpenPorts | bool | 是否存在任意已打开串口
openPortCount | int | 已打开串口数量
currentPortName | string | 当前默认读写串口名
openPortNames | QStringList | 所有已打开串口名
openPortList | QVariantList | 已打开串口详情列表
errorString | string | 最近一次错误文本

<br/>

### 支持的方法：

名称 | 返回值 | 描述
------ | --- | ---
refreshPorts() | QVariantList | 扫描系统可用串口，并更新 \`portInfoList\`
selectPort(portName) | bool | 设置当前默认串口，不会打开串口
isPortOpen(portName) | bool | 判断指定串口是否已打开
openPort(portName, baudRate, dataBits, parity, stopBits, flowControl) | bool | 打开或重新打开指定串口
closePort() | void | 关闭当前默认串口
closePort(portName) | void | 关闭指定串口
closeAllPorts() | void | 关闭全部串口
writeText(text) | bool | 向当前串口写 UTF-8 文本
writeTextToPort(portName, text) | bool | 向指定串口写 UTF-8 文本
writeHex(hexText) | bool | 向当前串口写 HEX 文本
writeHexToPort(portName, hexText) | bool | 向指定串口写 HEX 文本
writeBytes(data) | bool | 向当前串口写 QByteArray
writeBytesToPort(portName, data) | bool | 向指定串口写 QByteArray
bytesToHex(data) | string | 将 QByteArray 转为大写空格分隔 HEX 文本
clearError() | void | 清空错误状态

<br/>

### 支持的信号：

名称 | 描述
------ | ---
portInfoListChanged() | 可用串口列表变化
isOpenChanged() | 当前串口打开状态变化
currentPortNameChanged() | 当前默认串口变化
openPortsChanged() | 已打开串口集合变化
dataReceived(data, text, hex) | 任意串口收到数据
dataReceivedFromPort(portName, data, text, hex) | 指定来源串口收到数据
bytesWritten(bytes) | 任意串口写入完成
bytesWrittenFromPort(portName, bytes) | 指定串口写入完成
errorOccurred(message) | 任意串口发生错误
errorOccurredFromPort(portName, message) | 指定串口发生错误
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
当应用需要串口调试、设备通信、上位机协议解析、波形采集或同时连接多个设备时使用。

如果只连接一个设备，可以使用 \`openPort/writeHex/writeText/dataReceived\` 这组简化 API。

如果同时连接多个设备，优先使用带 \`ToPort\` 或 \`FromPort\` 后缀的接口，并根据 \`portName\` 区分数据来源。
                       `)
        }

        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
扫描串口并打开选中的端口。列表项包含 \`value\` 和 \`label\`，可以直接作为 \`MosSelect\` 的数据源。
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
                id: serialOpenExample

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
                        model: serialOpenExample.portOptions
                        placeholderText: qsTr("请选择串口")
                        enabled: !MosSerialPortManager.isOpen
                        currentIndex: {
                            for (let i = 0; i < serialOpenExample.portOptions.length; ++i) {
                                if (serialOpenExample.portOptions[i].value === serialOpenExample.selectedPortName)
                                    return i
                            }
                            return serialOpenExample.portOptions.length > 0 ? 0 : -1
                        }
                        onActivated: serialOpenExample.selectedPortName = currentValue
                    }

                    MosButton {
                        Layout.preferredWidth: 90
                        text: qsTr("刷新")
                        enabled: !MosSerialPortManager.isOpen
                        onClicked: serialOpenExample.refreshPorts()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    MosButton {
                        Layout.preferredWidth: 120
                        text: MosSerialPortManager.isOpen ? qsTr("关闭串口") : qsTr("打开串口")
                        type: MosSerialPortManager.isOpen ? MosButton.Type_Default : MosButton.Type_Primary
                        enabled: serialOpenExample.selectedPortName.length > 0 || MosSerialPortManager.isOpen
                        onClicked: {
                            if (MosSerialPortManager.isOpen)
                                MosSerialPortManager.closePort()
                            else
                                MosSerialPortManager.openPort(serialOpenExample.selectedPortName, 115200, 8, "none", "1", "none")
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
接收串口数据。单串口页面可以监听 \`dataReceived\`；多串口页面建议监听 \`dataReceivedFromPort\`，避免混淆不同设备的数据。
                       `)
            code: `
Connections {
    target: MosSerialPortManager

    function onDataReceived(data, text, hex) {
        console.log("RX:", hex)
    }

    function onDataReceivedFromPort(portName, data, text, hex) {
        console.log("RX from", portName, hex)
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

                    function onDataReceivedFromPort(portName, data, text, hex) {
                        receivePreview.text += "[" + portName + "] " + hex + "\\n"
                        receivePreview.scrollToEnd()
                    }
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
写入数据时，\`writeText/writeHex/writeBytes\` 使用当前串口；\`writeTextToPort/writeHexToPort/writeBytesToPort\` 可以明确指定串口。
                       `)
            code: `
// 写当前串口
MosSerialPortManager.writeText("AT\\r\\n")
MosSerialPortManager.writeHex("01 03 00 00 00 02 C4 0B")

// 写指定串口
MosSerialPortManager.writeTextToPort("COM3", "AT\\r\\n")
MosSerialPortManager.writeHexToPort("COM4", "AA 55 01 02")
            `
            exampleDelegate: RowLayout {
                width: parent ? parent.width : 760
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
                    onClicked: MosSerialPortManager.writeHex(sendInput.text)
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
        &MosSerialPortManager::dataReceivedFromPort,
        this,
        &YourParser::onSerialDataReceivedFromPort);

void YourParser::onSerialDataReceivedFromPort(const QString &portName,
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
            title: qsTr('多串口建议')
            desc: qsTr(`
- 单串口工具可以使用 \`isOpen/currentPortName/writeHex/dataReceived\`，代码最简洁。
- 多串口工具优先使用 \`hasOpenPorts/openPortCount/openPortNames/openPortList\` 表达整体状态。
- 多串口接收时优先监听 \`dataReceivedFromPort\`，并按 \`portName\` 分发到不同协议解析器。
- 多串口发送时优先使用 \`writeHexToPort/writeTextToPort/writeBytesToPort\`，避免当前串口切换导致写错设备。
- C++ 后端应直接连接 \`MosSerialPortManager::instance()\` 的信号，不需要从 QML 页面取数据。
                       `)
        }
    }
}
