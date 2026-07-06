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
# MosNetTcpManager TCP 网络通信管理器

\`MosNetTcpManager\` 是基于 \`QTcpSocket\` / \`QTcpServer\` / \`QSslSocket\` 的 QML 单例，支持 **客户端** 和 **服务器** 双模式，提供高性能 TCP 网络通信能力。

* **模块 { MosuiBasic }**
* **类型 { QML Singleton }**
* **C++ 单例 { MosNetTcpManager::instance() }**
* **底层 { QTcpSocket + QTcpServer + 独立 TCP 工作线程 }**
* **传输层 { TCP / TLS (SSL) }**

<br/>

### 架构设计

\`MosNetTcpManager\` 使用 **Worker-Thread 模式**，将所有网络 I/O 运行在独立的 \`MosNetTcpThread\` 线程中，通过 \`invokeOperation\` 模板进行跨线程调用，避免阻塞 UI 线程。

特性：
- **双模式**：Client（连接远程服务端）和 Server（监听接受多个客户端连接）
- **多连接管理**：Server 模式下支持并发多客户端，提供 peerList/peerNames/connectionCount 属性
- **自动重连**：Client 模式下支持指数退避自动重连（间隔 = min(reconnectInterval × 2^attempt, 60s)），含 ±10% 随机抖动
- **SSL/TLS 加密**：支持 CA 证书、本地证书+私钥（双向认证）、对等验证控制，证书文件变化自动监控刷新
- **高性能发送队列**：支持 partial write 和背压保护（队列上限 256 帧），异步冲刷
- **发送队列背压保护**：队列满时拒绝新数据，防止内存无限增长
- **lazyDecode 模式**：跳过 text/hex 自动转换，节省 CPU（适合纯二进制协议）
- **运行时参数同步**：tcpNoDelay / readBufferSize / lazyDecode / maxConnections 修改后即时生效
                       `)
        }

        MosDescription {
            title: qsTr('属性')
            desc: qsTr(`
属性名 | 类型 | 默认值 | 说明
------ | --- | --- | ---
host | string | \`""\` | 远程主机地址（Client 模式）
port | int | \`502\` | TCP 端口号（默认 Modbus TCP 端口）
mode | Mode | \`Client\` | 工作模式（Client=0 / Server=1）
isConnected | bool | \`false\` | 是否已连接（Client 模式）
state | State | \`Disconnected\` | 连接状态枚举（Disconnected/Connecting/Connected/Listening）
errorString | string | \`""\` | 最近错误文本
peerNames | QStringList | \`[]\` | 已连接对等体的标识列表（排序后）
peerList | QVariantList | \`[]\` | 已连接对等体的详细信息列表
hasConnections | bool | \`false\` | 是否存在活动连接
connectionCount | int | \`0\` | 当前活动连接数
autoReconnect | bool | \`false\` | 意外断线后是否自动重连（Client 模式）
reconnectInterval | int | \`5000\` | 重连基础间隔（毫秒），最小 1000
sslEnabled | bool | \`false\` | 是否启用 TLS/SSL 加密
sslCaCertPath | string | \`""\` | CA 证书文件路径
sslLocalCertPath | string | \`""\` | 本地证书文件路径（双向认证）
sslPrivateKeyPath | string | \`""\` | 私钥文件路径
sslPeerVerify | bool | \`true\` | 是否验证对等证书（自签名证书设为 false）
tcpNoDelay | bool | \`true\` | 禁用 Nagle 算法（低延迟）
readBufferSize | int | \`65536\` | 读取缓冲区大小（字节）
maxConnections | int | \`100\` | 最大连接数（Server 模式）
lazyDecode | bool | \`false\` | 是否跳过 text/hex 转换（适合纯二进制协议）

<br/>

### State 枚举值

值 | 说明
--- | ---
MosNetTcpManager.Disconnected (0) | 未连接/未监听
MosNetTcpManager.Connecting (1) | 正在连接（Client 模式）
MosNetTcpManager.Connected (2) | 已连接（Client 模式）
MosNetTcpManager.Listening (3) | 正在监听（Server 模式）

### Mode 枚举值

值 | 说明
--- | ---
MosNetTcpManager.Client (0) | 客户端模式（连接到远程服务器）
MosNetTcpManager.Server (1) | 服务器模式（监听接受客户端连接）

### peerList 条目结构

字段 | 类型 | 说明
--- | --- | ---
peerKey | string | 对等体唯一标识（格式 \`host:port\`）
peerAddress | string | 对等体地址
peerPort | int | 对等体端口
localAddress | string | 本地地址
localPort | int | 本地端口
isConnected | bool | 是否已连接
sslEncrypted | bool | SSL 是否已加密（SSL 模式下）

### 自动重连行为（Client 模式）

\`autoReconnect=true\` 时：意外断线后自动重连，采用指数退避策略：
\`delay = min(reconnectInterval × 2^attempt, 60s) ± 10% jitter\`

成功连接后 \`reconnectAttempt\` 重置为 0。主动调用 \`disconnectFromHost()\` 不会触发重连。
                       `)
        }

        MosDescription {
            title: qsTr('方法（客户端）')
            desc: qsTr(`
名称 | 返回值 | 说明
------ | --- | ---
connectToHost() | void | 使用当前 host/port 属性连接服务器
connectToHost(host, port) | void | 指定主机和端口连接服务器
disconnectFromHost() | void | 断开连接并停止自动重连

### connectToHost 行为

- 调用后自动设置 \`mode = Client\`
- 若已在 Server 模式 \`Listening\` 状态，返回错误
- 若已有连接，先断开旧连接再建立新连接
- 异步操作：调用返回不代表已连接，需监听 \`connected()\` 信号或 \`isConnected\` 属性
                       `)
        }

        MosDescription {
            title: qsTr('方法（服务器）')
            desc: qsTr(`
名称 | 返回值 | 说明
------ | --- | ---
startServer() | void | 使用当前 port 属性启动服务器
startServer(port) | void | 指定端口启动服务器
stopServer() | void | 停止服务器并断开所有客户端

### startServer 行为

- 调用后自动设置 \`mode = Server\`，\`state = Listening\`
- 监听所有 IPv4 地址（\`QHostAddress::AnyIPv4\`）
- 若已有客户端连接，返回错误
- \`maxConnections\` 限制同时接受的连接数（超限时拒绝并关闭新连接）
- SSL 模式下自动配置证书并启用加密
                       `)
        }

        MosDescription {
            title: qsTr('方法（数据发送）')
            desc: qsTr(`
名称 | 返回值 | 说明
------ | --- | ---
sendText(text) | bool | 发送 UTF-8 文本到默认对等体
sendTextToPeer(peerKey, text) | bool | 发送 UTF-8 文本到指定对等体
sendBytes(data) | bool | 发送原始字节到默认对等体
sendBytesToPeer(peerKey, data) | bool | 发送原始字节到指定对等体
sendHex(hexText) | bool | 发送十六进制数据到默认对等体
sendHexToPeer(peerKey, hexText) | bool | 发送十六进制数据到指定对等体

### 发送说明

- **Client 模式**："默认对等体" 即为当前连接的服务端
- **Server 模式**：推荐使用 \`...ToPeer\` 方法指定 peerKey；默认发送会使用当前 \`peerNames.first()\`
- **背压保护**：发送队列最多 256 帧，超限时返回 false 并设置 errorString
- **Partial Write**：大块数据自动分片写入，通过 bytesWritten 信号异步完成
- **空数据**：\`sendBytes(QByteArray())\` / \`sendBytesToPeer(peerKey, QByteArray())\` 直接返回 true，不执行任何写入
                       `)
        }

        MosDescription {
            title: qsTr('方法（连接管理 & 工具）')
            desc: qsTr(`
名称 | 返回值 | 说明
------ | --- | ---
disconnectPeer(peerKey) | void | 断开指定对等体（Server 模式）
clearError() | void | 清空 errorString
bytesToHex(data) | string | 将 QByteArray 转换为大写空格分隔的 HEX 字符串
bytesToText(data) | string | 将 QByteArray 转换为 UTF-8 文本
                       `)
        }

        MosDescription {
            title: qsTr('信号')
            desc: qsTr(`
名称 | 参数 | 说明
------ | --- | ---
connected() | | Client 连接成功
disconnected() | | Client 连接断开
dataReceived(data, text, hex) | QByteArray, string, string | 收到数据（默认对等体，lazyDecode 时 text/hex 为空）
dataReceivedFromPeer(peerKey, data, text, hex) | string, QByteArray, string, string | 收到数据（指定对等体）
bytesSent(peerKey, bytes) | string, qint64 | 字节已发送
peerConnected(peerKey) | string | 对等体已连接
peerDisconnected(peerKey) | string | 对等体已断开
errorOccurred(message) | string | 发生错误
errorOccurredFromPeer(peerKey, message) | string, string | 指定对等体发生错误

<br/>

### 属性变更信号

\`hostChanged()\`, \`portChanged()\`, \`modeChanged()\`,
\`isConnectedChanged()\`, \`stateChanged()\`, \`errorStringChanged()\`,
\`connectionsChanged()\`, \`autoReconnectChanged()\`, \`reconnectIntervalChanged()\`,
\`sslEnabledChanged()\`, \`sslCaCertPathChanged()\`, \`sslLocalCertPathChanged()\`,
\`sslPrivateKeyPathChanged()\`, \`sslPeerVerifyChanged()\`,
\`tcpNoDelayChanged()\`, \`readBufferSizeChanged()\`, \`maxConnectionsChanged()\`,
\`lazyDecodeChanged()\`
                       `)
        }

        MosDescription {
            title: qsTr('代码演示')
        }

        // ========== 示例 1: Client 模式基础连接 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
**Client 模式**：连接到远程 TCP 服务器，发送文本并接收回显。
设置 host/port 后调用 \`connectToHost()\`，监听 \`isConnected\` 和 \`errorString\` 获取状态。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

ColumnLayout {
    Component.onCompleted: {
        MosNetTcpManager.host = "127.0.0.1"
        MosNetTcpManager.port = 9527
        MosNetTcpManager.mode = MosNetTcpManager.Client
    }

    // 连接状态
    MosText {
        text: {
            switch (MosNetTcpManager.state) {
            case MosNetTcpManager.Connected: return qsTr("已连接")
            case MosNetTcpManager.Connecting: return qsTr("连接中...")
            default: return qsTr("未连接")
            }
        }
    }

    // 错误信息
    MosText {
        text: MosNetTcpManager.errorString
        color: MosTheme.Primary.colorErrorText
        visible: text.length > 0
    }

    // 连接/断开按钮
    MosButton {
        text: MosNetTcpManager.isConnected ? qsTr("断开") : qsTr("连接")
        onClicked: {
            if (MosNetTcpManager.isConnected)
                MosNetTcpManager.disconnectFromHost()
            else
                MosNetTcpManager.connectToHost()
        }
    }

    // 发送数据
    RowLayout {
        MosInput { id: sendInput; Layout.fillWidth: true }
        MosButton {
            text: qsTr("发送")
            onClicked: MosNetTcpManager.sendText(sendInput.text)
        }
    }

    // 接收数据
    Connections {
        target: MosNetTcpManager
        function onDataReceived(data, text, hex) {
            console.log("收到:", text, "HEX:", hex)
        }
    }
}
            `
        }

        // ========== 示例 2: Server 模式多客户端 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
**Server 模式**：启动 TCP 服务器，接受多个客户端连接，向指定客户端发送数据。
通过 \`peerList\` 获取所有连接的客户端信息，使用 \`peerKey\` 区分不同客户端。
                       `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

ColumnLayout {
    Component.onCompleted: {
        MosNetTcpManager.mode = MosNetTcpManager.Server
        MosNetTcpManager.port = 9527
        MosNetTcpManager.maxConnections = 10
        MosNetTcpManager.startServer()
    }

    // 服务器状态
    MosText {
        text: MosNetTcpManager.state === MosNetTcpManager.Listening
              ? qsTr("监听中（端口 %1）").arg(MosNetTcpManager.port)
              : qsTr("已停止")
    }

    // 客户端列表
    Repeater {
        model: MosNetTcpManager.peerList
        delegate: MosText {
            text: qsTr("客户端 %1 (%2)")
                .arg(modelData.peerKey)
                .arg(modelData.peerAddress)
        }
    }

    // 新客户端连接通知
    Connections {
        target: MosNetTcpManager
        function onPeerConnected(peerKey) {
            console.log("新客户端:", peerKey)
        }
        function onPeerDisconnected(peerKey) {
            console.log("客户端断开:", peerKey)
        }
        function onDataReceivedFromPeer(peerKey, data, text, hex) {
            console.log("来自", peerKey, ":", text)
        }
    }

    // 停止服务器
    MosButton {
        text: qsTr("停止服务器")
        onClicked: MosNetTcpManager.stopServer()
    }
}
            `
        }

        // ========== 示例 3: 自动重连 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
**自动重连**：Client 模式下启用 \`autoReconnect\`，断线后自动以指数退避策略重连。
重连期间 \`state\` 在 Disconnected 和 Connecting 之间切换。
                       `)
            code: `
import QtQuick
import MosuiBasic

Item {
    Component.onCompleted: {
        MosNetTcpManager.host = "192.168.1.100"
        MosNetTcpManager.port = 502
        MosNetTcpManager.autoReconnect = true
        MosNetTcpManager.reconnectInterval = 5000  // 基础间隔 5s
        MosNetTcpManager.connectToHost()
    }

    Connections {
        target: MosNetTcpManager
        function onConnected() {
            console.log("连接成功")
        }
        function onDisconnected() {
            console.log("断开，自动重连中...")
        }
        function onErrorOccurred(message) {
            console.warn("错误:", message)
        }
    }
}
            `
        }

        // ========== 示例 4: SSL/TLS 加密连接 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
**SSL/TLS 加密**：Client/Server 模式均支持 SSL。设置证书路径后启用 \`sslEnabled\`。
证书文件变化时缓存自动失效并重新加载（\`QFileSystemWatcher\` 监控）。
                       `)
            code: `
import QtQuick
import MosuiBasic

Item {
    Component.onCompleted: {
        // Client SSL 连接
        MosNetTcpManager.mode = MosNetTcpManager.Client
        MosNetTcpManager.host = "secure-server.example.com"
        MosNetTcpManager.port = 443
        MosNetTcpManager.sslEnabled = true
        MosNetTcpManager.sslCaCertPath = "/path/to/ca-cert.pem"
        MosNetTcpManager.sslPeerVerify = true      // 验证服务端证书
        MosNetTcpManager.connectToHost()
    }

    // Server SSL（双向认证）
    function startSecureServer() {
        MosNetTcpManager.mode = MosNetTcpManager.Server
        MosNetTcpManager.sslEnabled = true
        MosNetTcpManager.sslLocalCertPath = "/path/to/server-cert.pem"
        MosNetTcpManager.sslPrivateKeyPath = "/path/to/server-key.pem"
        MosNetTcpManager.sslCaCertPath = "/path/to/ca-cert.pem"
        MosNetTcpManager.startServer(8443)
    }
}
            `
        }

        // ========== 示例 5: 高性能二进制协议（lazyDecode） ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
**lazyDecode 模式**：适合 Modbus、PLC 等纯二进制协议。跳过 text/hex 自动转换以减少 CPU 开销。
收到数据时 \`dataReceived\` 的 text 和 hex 参数为空，需要时手动调用 \`bytesToHex()\` / \`bytesToText()\`。
                       `)
            code: `
import QtQuick
import MosuiBasic

Item {
    Component.onCompleted: {
        MosNetTcpManager.host = "192.168.1.10"
        MosNetTcpManager.port = 502
        MosNetTcpManager.tcpNoDelay = true       // 禁用 Nagle，低延迟
        MosNetTcpManager.readBufferSize = 131072  // 128KB 缓冲
        MosNetTcpManager.lazyDecode = true        // 不自动转 text/hex
        MosNetTcpManager.connectToHost()
    }

    Connections {
        target: MosNetTcpManager
        function onDataReceived(data, text, hex) {
            // lazyDecode 时 text 和 hex 为空
            // 手动解析二进制协议
            if (data.length >= 8) {
                let funcCode = data[1]
                let regAddr  = (data[2] << 8) | data[3]
                console.log("Modbus 功能码:", funcCode, "寄存器:", regAddr)
            }
        }
    }

    // 发送 Modbus 读取请求
    function sendModbusRead(slaveId, startAddr, count) {
        let buf = new ArrayBuffer(8)
        let view = new DataView(buf)
        // ... 填充 Modbus 帧 ...
        // 或使用 sendHex("0103000000044409")
    }
}
            `
        }

        // ========== 示例 6: 性能调优 ==========
        CodeBox {
            width: parent.width
            desc: qsTr(`
**性能调优**：组合使用 \`tcpNoDelay\`、\`readBufferSize\`、\`lazyDecode\` 和 \`sendBytes\` 获得最佳吞吐量。
运行时修改参数通过 \`applySettings\` 即时同步到所有已连接 socket。
                       `)
            code: `
import QtQuick
import MosuiBasic

Item {
    Component.onCompleted: {
        // 高吞吐量配置
        MosNetTcpManager.host = "192.168.1.100"
        MosNetTcpManager.port = 502
        MosNetTcpManager.tcpNoDelay = true        // 低延迟
        MosNetTcpManager.readBufferSize = 262144   // 256KB 缓冲
        MosNetTcpManager.lazyDecode = true         // 跳过 text/hex 转换
        MosNetTcpManager.connectToHost()
    }

    // 批量发送大数据
    function sendBatchData(sizeKb) {
        let data = new ArrayBuffer(sizeKb * 1024)
        MosNetTcpManager.sendBytes(data)
    }

    // 运行时动态调整缓冲大小
    function adjustBufferSize(newSize) {
        MosNetTcpManager.readBufferSize = newSize  // 自动同步到 socket
    }
}
            `
        }

        MosDescription {
            title: qsTr('逐项用法示例')
            desc: qsTr(`
下面按公开 API 拆分独立示例。每个示例只展示一个用法重点，便于复制到实际页面中组合使用。
            `)
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**属性配置示例**：连接或监听前先设置地址、端口、模式、重连、SSL 和性能参数。所有属性属于同一个全局单例，跨页面共享。
            `)
            code: `
import QtQuick
import MosuiBasic

Item {
    Component.onCompleted: {
        MosNetTcpManager.mode = MosNetTcpManager.Client
        MosNetTcpManager.host = "127.0.0.1"
        MosNetTcpManager.port = 9527

        MosNetTcpManager.autoReconnect = true
        MosNetTcpManager.reconnectInterval = 5000

        MosNetTcpManager.tcpNoDelay = true
        MosNetTcpManager.readBufferSize = 64 * 1024
        MosNetTcpManager.lazyDecode = false

        MosNetTcpManager.maxConnections = 100
        MosNetTcpManager.sslEnabled = false
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**connectToHost()**：使用当前 \`host\` / \`port\` 发起 Client 连接。调用后并不代表已经连接成功，需要监听 \`connected()\`、\`state\` 或 \`isConnected\`。
            `)
            code: `
MosNetTcpManager.host = "192.168.1.100"
MosNetTcpManager.port = 502
MosNetTcpManager.connectToHost()

Connections {
    target: MosNetTcpManager
    function onConnected() {
        console.log("TCP connected")
    }
    function onErrorOccurred(message) {
        console.warn("TCP error:", message)
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**connectToHost(host, port)**：在调用时直接指定远端地址和端口。方法会把有效参数同步回 \`host\` / \`port\` 属性，适合表单提交。
            `)
            code: `
import QtQuick
import QtQuick.Layouts
import MosuiBasic

RowLayout {
    MosInput {
        id: hostInput
        Layout.fillWidth: true
        text: "192.168.1.100"
        placeholderText: qsTr("服务器地址")
    }

    MosInputInteger {
        id: portInput
        Layout.preferredWidth: 96
        value: 502
        min: 1
        max: 65535
    }

    MosButton {
        text: qsTr("连接")
        enabled: hostInput.text.trim().length > 0
        onClicked: {
            MosNetTcpManager.clearError()
            MosNetTcpManager.connectToHost(hostInput.text, portInput.value)
        }
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**disconnectFromHost()**：主动断开 Client 连接，并停止本次连接的自动重连。主动断开后如果还要连接，需要重新调用 \`connectToHost()\`。
            `)
            code: `
MosButton {
    text: MosNetTcpManager.isConnected ? qsTr("断开连接") : qsTr("连接")
    onClicked: {
        if (MosNetTcpManager.isConnected)
            MosNetTcpManager.disconnectFromHost()
        else
            MosNetTcpManager.connectToHost()
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**startServer()**：使用当前 \`port\` 启动 Server。成功后 \`state\` 变为 \`Listening\`，并开始接受客户端连接。
            `)
            code: `
MosNetTcpManager.mode = MosNetTcpManager.Server
MosNetTcpManager.port = 9527
MosNetTcpManager.maxConnections = 10
MosNetTcpManager.startServer()

console.log("state:", MosNetTcpManager.state)
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**startServer(port)**：用指定端口启动 Server，并把端口写回 \`port\` 属性。端口必须在 1 到 65535 之间。
            `)
            code: `
function listenOn(port) {
    MosNetTcpManager.autoReconnect = false
    MosNetTcpManager.startServer(port)
}

listenOn(9527)
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**stopServer()**：停止监听并断开所有客户端。调用后 \`peerList\`、\`peerNames\`、\`connectionCount\` 会刷新。
            `)
            code: `
MosButton {
    text: qsTr("停止服务器")
    enabled: MosNetTcpManager.state === MosNetTcpManager.Listening
    onClicked: MosNetTcpManager.stopServer()
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**peerList / peerNames**：Server 模式查看客户端列表。\`peerKey\` 通常是 \`host:port\`，用于向指定客户端发送或断开连接。
            `)
            code: `
ColumnLayout {
    MosText {
        text: qsTr("连接数：%1").arg(MosNetTcpManager.connectionCount)
    }

    Repeater {
        model: MosNetTcpManager.peerList
        delegate: MosText {
            text: modelData.peerKey
                  + "  remote=" + modelData.peerAddress + ":" + modelData.peerPort
                  + "  encrypted=" + modelData.sslEncrypted
        }
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**sendText(text)**：向默认对等体发送 UTF-8 文本。Client 模式下默认对等体就是当前服务器；Server 多客户端场景建议使用 \`sendTextToPeer()\`。
            `)
            code: `
function sendLine(text) {
    if (!MosNetTcpManager.sendText(text + "\\r\\n"))
        console.warn(MosNetTcpManager.errorString)
}

sendLine("PING")
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**sendTextToPeer(peerKey, text)**：向指定对等体发送 UTF-8 文本。Server 模式推荐优先使用，避免默认对等体变化导致消息发错对象。
            `)
            code: `
function replyToPeer(peerKey) {
    const ok = MosNetTcpManager.sendTextToPeer(peerKey, "ACK\\r\\n")
    if (!ok)
        console.warn("send failed:", MosNetTcpManager.errorString)
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**sendHex(hexText)**：把十六进制文本转为字节后发送到默认对等体。支持空格、逗号、分号、换行和 \`0x\` 前缀；清理后必须是偶数长度的合法 HEX。
            `)
            code: `
const ok = MosNetTcpManager.sendHex("01 03 00 00 00 02 C4 0B")
if (!ok)
    console.warn(MosNetTcpManager.errorString)
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**sendHexToPeer(peerKey, hexText)**：向指定对等体发送 HEX 数据。适合 Server 同时连接多个设备时，按 \`peerKey\` 下发二进制命令。
            `)
            code: `
function readRegisters(peerKey) {
    const hex = "01 03 00 00 00 02 C4 0B"
    if (!MosNetTcpManager.sendHexToPeer(peerKey, hex))
        console.warn(MosNetTcpManager.errorString)
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**sendBytes(data)**：向默认对等体发送原始字节，适合自定义二进制协议。空字节数组会直接返回 \`true\`，不会写 socket。
            `)
            code: `
function sendBinaryFrame() {
    const frame = new Uint8Array([0xAA, 0x55, 0x01, 0x02])
    if (!MosNetTcpManager.sendBytes(frame))
        console.warn(MosNetTcpManager.errorString)
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**sendBytesToPeer(peerKey, data)**：向指定对等体发送原始字节。底层发送队列最大 256 帧，队列满时返回 \`false\` 并写入 \`errorString\`。
            `)
            code: `
function sendBinaryToFirstPeer() {
    if (MosNetTcpManager.peerNames.length === 0)
        return

    const peerKey = MosNetTcpManager.peerNames[0]
    const payload = new Uint8Array([0x10, 0x20, 0x30, 0x40])

    if (!MosNetTcpManager.sendBytesToPeer(peerKey, payload))
        console.warn(MosNetTcpManager.errorString)
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**disconnectPeer(peerKey)**：断开指定对等体，主要用于 Server 模式踢掉某个客户端。成功后连接列表会刷新，并触发 \`peerDisconnected(peerKey)\`。
            `)
            code: `
Repeater {
    model: MosNetTcpManager.peerNames

    delegate: MosButton {
        required property string modelData
        text: qsTr("断开 ") + modelData
        onClicked: MosNetTcpManager.disconnectPeer(modelData)
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**clearError()**：清空最近一次错误文本。适合用户再次操作前隐藏上一条错误提示。
            `)
            code: `
MosText {
    text: MosNetTcpManager.errorString
    color: MosTheme.Primary.colorErrorText
    visible: text.length > 0
}

MosButton {
    text: qsTr("清除错误")
    visible: MosNetTcpManager.errorString.length > 0
    onClicked: MosNetTcpManager.clearError()
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**bytesToHex(data) / bytesToText(data)**：把收到的 \`QByteArray\` 转为可显示内容。\`lazyDecode=true\` 时信号里的 \`text\` / \`hex\` 为空，可在需要展示时手动转换。
            `)
            code: `
Connections {
    target: MosNetTcpManager

    function onDataReceived(data, text, hex) {
        const displayText = text.length > 0 ? text : MosNetTcpManager.bytesToText(data)
        const displayHex = hex.length > 0 ? hex : MosNetTcpManager.bytesToHex(data)

        console.log("TEXT:", displayText)
        console.log("HEX:", displayHex)
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**Client 信号监听**：Client 页面通常监听连接、断开、接收、发送完成和错误这几类信号。
            `)
            code: `
Connections {
    target: MosNetTcpManager

    function onConnected() {
        console.log("连接成功")
    }

    function onDisconnected() {
        console.log("连接断开")
    }

    function onDataReceived(data, text, hex) {
        console.log("收到:", text, hex)
    }

    function onBytesSent(peerKey, bytes) {
        console.log("已向", peerKey, "写入", bytes, "字节")
    }

    function onErrorOccurred(message) {
        console.warn("TCP 错误:", message)
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**Server 信号监听**：Server 页面用 \`peerConnected()\` / \`peerDisconnected()\` 维护在线列表，用 \`dataReceivedFromPeer()\` 区分数据来源。
            `)
            code: `
Connections {
    target: MosNetTcpManager

    function onPeerConnected(peerKey) {
        console.log("客户端上线:", peerKey)
    }

    function onPeerDisconnected(peerKey) {
        console.log("客户端离线:", peerKey)
    }

    function onDataReceivedFromPeer(peerKey, data, text, hex) {
        console.log("来自", peerKey, ":", text, hex)
        MosNetTcpManager.sendTextToPeer(peerKey, "ACK\\r\\n")
    }

    function onErrorOccurredFromPeer(peerKey, message) {
        console.warn("客户端错误:", peerKey, message)
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**自动重连用法**：仅 Client 模式生效。意外断线后按指数退避重连；主动调用 \`disconnectFromHost()\` 不会触发重连。
            `)
            code: `
MosNetTcpManager.host = "192.168.1.100"
MosNetTcpManager.port = 502
MosNetTcpManager.autoReconnect = true
MosNetTcpManager.reconnectInterval = 5000
MosNetTcpManager.connectToHost()

Connections {
    target: MosNetTcpManager
    function onDisconnected() {
        if (MosNetTcpManager.autoReconnect)
            console.log("等待自动重连")
    }
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**SSL/TLS Client 用法**：先设置证书和验证策略，再发起连接。生产环境建议保持 \`sslPeerVerify=true\`。
            `)
            code: `
MosNetTcpManager.mode = MosNetTcpManager.Client
MosNetTcpManager.host = "secure-server.example.com"
MosNetTcpManager.port = 443

MosNetTcpManager.sslEnabled = true
MosNetTcpManager.sslCaCertPath = "C:/certs/ca.pem"
MosNetTcpManager.sslPeerVerify = true

MosNetTcpManager.connectToHost()
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**SSL/TLS Server 用法**：服务端至少需要本地证书和私钥；双向认证时再配置 CA 并开启对等验证。
            `)
            code: `
MosNetTcpManager.mode = MosNetTcpManager.Server
MosNetTcpManager.sslEnabled = true
MosNetTcpManager.sslLocalCertPath = "C:/certs/server.pem"
MosNetTcpManager.sslPrivateKeyPath = "C:/certs/server-key.pem"

// 双向认证时配置 CA；普通单向 TLS 可不填
MosNetTcpManager.sslCaCertPath = "C:/certs/ca.pem"
MosNetTcpManager.sslPeerVerify = true

MosNetTcpManager.startServer(8443)
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**性能参数运行时调整**：\`tcpNoDelay\`、\`readBufferSize\`、\`lazyDecode\` 会同步到已有 socket；\`maxConnections\` 运行时修改只影响后续新连接。
            `)
            code: `
function switchToLowLatency() {
    MosNetTcpManager.tcpNoDelay = true
    MosNetTcpManager.readBufferSize = 64 * 1024
    MosNetTcpManager.lazyDecode = false
}

function switchToHighThroughput() {
    MosNetTcpManager.tcpNoDelay = false
    MosNetTcpManager.readBufferSize = 1024 * 1024
    MosNetTcpManager.lazyDecode = true
}

function allowMoreClients() {
    MosNetTcpManager.maxConnections = 500
}
            `
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
**C++ 后端用法**：协议解析器可以直接连接同一个单例信号，不需要从 QML 页面转发数据。
            `)
            code: `
#include "MosNetTcpManager.h"
#include <QDebug>

auto manager = MosNetTcpManager::instance();

connect(manager,
        &MosNetTcpManager::dataReceivedFromPeer,
        this,
        &YourParser::onTcpDataReceivedFromPeer);

void YourParser::onTcpDataReceivedFromPeer(const QString &peerKey,
                                           const QByteArray &data,
                                           const QString &text,
                                           const QString &hex)
{
    Q_UNUSED(text)
    Q_UNUSED(hex)

    // 按业务协议解析 data，peerKey 用于区分来源连接
    qDebug() << "TCP RX" << peerKey << data.toHex(' ');
}
            `
        }

        MosDescription {
            title: qsTr('使用建议')
            desc: qsTr(`
- Client 页面优先绑定 \`state/isConnected/errorString\`，不要假设 \`connectToHost()\` 调用后立即连接成功。
- Server 多客户端页面优先使用 \`peerList\` 展示详情，发送数据优先使用 \`...ToPeer(peerKey, ...)\`。
- 文本协议用 \`sendText/sendTextToPeer\`；二进制协议用 \`sendHex/sendHexToPeer\` 或 \`sendBytes/sendBytesToPeer\`。
- HEX 输入允许分隔符和 \`0x\` 前缀，但清理后必须是偶数长度；失败时显示 \`errorString\`。
- 高频二进制场景开启 \`lazyDecode\`，只在日志或调试界面需要展示时调用 \`bytesToHex()\`。
- 主动调用 \`disconnectFromHost()\` 不会自动重连；需要恢复连接时再次调用 \`connectToHost()\`。
- SSL 证书加载失败、端口非法、队列满、peer 不存在等都会写入 \`errorString\`，建议统一监听 \`errorOccurred()\`。
            `)
        }
    }
}
