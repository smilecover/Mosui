import QtQuick
import MosuiBasic


QtObject {
    id: root
    // 菜单栏
    property int menuType: 0
    // 首页动画
    property int currentBackground: 0

    // 雨滴
    property real rainAmount: 0.5
    property real refraction: 0.9

    // 串口
    property var serialPortOptions: []

    property string controlSerialPortName: ""
    property int controlSerialBaudRate: 9600
    property int controlSerialDataBits: 8
    property string controlSerialParity: "none"
    property string controlSerialStopBits: "1"
    property string controlSerialFlowControl: "none"
    property bool controlSerialOpen: false

    property string waveSerialPortName: ""
    property int waveSerialBaudRate: 115200
    property bool waveSerialOpen: false

    function hasPort(portName) {
        for (let i = 0; i < serialPortOptions.length; ++i) {
            if (serialPortOptions[i].value === portName)
                return true
        }
        return false
    }

    function firstAvailablePort(excludedPortName) {
        for (let i = 0; i < serialPortOptions.length; ++i) {
            const portName = serialPortOptions[i].value
            if (portName !== excludedPortName && !MosSerialPortManager.isPortOpen(portName))
                return portName
        }
        for (let i = 0; i < serialPortOptions.length; ++i) {
            if (serialPortOptions[i].value !== excludedPortName)
                return serialPortOptions[i].value
        }
        return serialPortOptions.length > 0 ? serialPortOptions[0].value : ""
    }

    function refreshSerialPorts(groupName) {
        serialPortOptions = MosSerialPortManager.refreshPorts()

        if (groupName === "wave") {
            if (waveSerialPortName.length === 0 || !hasPort(waveSerialPortName))
                waveSerialPortName = firstAvailablePort(controlSerialPortName)
        } else if (groupName === "control") {
            if (controlSerialPortName.length === 0 || !hasPort(controlSerialPortName))
                controlSerialPortName = firstAvailablePort(waveSerialPortName)
        } else {
            if (controlSerialPortName.length === 0 || !hasPort(controlSerialPortName))
                controlSerialPortName = firstAvailablePort(waveSerialPortName)
            if (waveSerialPortName.length === 0 || !hasPort(waveSerialPortName))
                waveSerialPortName = firstAvailablePort(controlSerialPortName)
        }

        updateSerialConnectionStates()
        return serialPortOptions
    }

    function updateSerialConnectionStates() {
        controlSerialOpen = controlSerialPortName.length > 0
                && MosSerialPortManager.isPortOpen(controlSerialPortName)
        waveSerialOpen = waveSerialPortName.length > 0
                && MosSerialPortManager.isPortOpen(waveSerialPortName)
        syncConnectedPortConfig("control")
        syncConnectedPortConfig("wave")
    }

    function syncConnectedPortConfig(groupName) {
        const portName = groupName === "wave" ? waveSerialPortName : controlSerialPortName
        if (portName.length === 0 || !MosSerialPortManager.isPortOpen(portName))
            return

        const openPorts = MosSerialPortManager.openPortList
        for (let i = 0; i < openPorts.length; ++i) {
            if (openPorts[i].portName !== portName)
                continue

            if (groupName === "wave") {
                waveSerialBaudRate = openPorts[i].baudRate
            } else {
                controlSerialBaudRate = openPorts[i].baudRate
                controlSerialDataBits = openPorts[i].dataBits
                controlSerialParity = parityName(openPorts[i].parity)
                controlSerialStopBits = stopBitsName(openPorts[i].stopBits)
                controlSerialFlowControl = flowControlName(openPorts[i].flowControl)
            }
            return
        }
    }

    function parityName(value) {
        if (value === 2)
            return "even"
        if (value === 3)
            return "odd"
        if (value === 4)
            return "space"
        if (value === 5)
            return "mark"
        return "none"
    }

    function stopBitsName(value) {
        if (value === 2)
            return "2"
        if (value === 3)
            return "1.5"
        return "1"
    }

    function flowControlName(value) {
        if (value === 1)
            return "hardware"
        if (value === 2)
            return "software"
        return "none"
    }

    function openControlSerialPort() {
        const ok = MosSerialPortManager.openPort(
                    controlSerialPortName,
                    controlSerialBaudRate,
                    controlSerialDataBits,
                    controlSerialParity,
                    controlSerialStopBits,
                    controlSerialFlowControl)
        updateSerialConnectionStates()
        return ok
    }

    function closeControlSerialPort() {
        if (controlSerialPortName.length > 0)
            MosSerialPortManager.closePort(controlSerialPortName)
        updateSerialConnectionStates()
    }

    function toggleControlSerialPort() {
        updateSerialConnectionStates()
        if (controlSerialOpen) {
            closeControlSerialPort()
            return true
        }
        return openControlSerialPort()
    }

    function openWaveSerialPort() {
        const previousPortName = MosSerialPortManager.currentPortName
        const ok = MosSerialPortManager.openPort(waveSerialPortName, waveSerialBaudRate, 8, "none", "1", "none")
        if (ok
                && previousPortName.length > 0
                && previousPortName !== waveSerialPortName
                && MosSerialPortManager.isPortOpen(previousPortName)) {
            MosSerialPortManager.selectPort(previousPortName)
        }
        updateSerialConnectionStates()
        return ok
    }

    function closeWaveSerialPort() {
        if (waveSerialPortName.length > 0)
            MosSerialPortManager.closePort(waveSerialPortName)
        updateSerialConnectionStates()
    }

    function toggleWaveSerialPort() {
        updateSerialConnectionStates()
        if (waveSerialOpen) {
            closeWaveSerialPort()
            return true
        }
        return openWaveSerialPort()
    }

    property Connections serialConnections: Connections {
        target: MosSerialPortManager

        function onOpenPortsChanged() {
            root.updateSerialConnectionStates()
        }
    }

}
