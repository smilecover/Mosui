import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosModal {
    id: root

    title: "硬件状态监控"
    confirmText: ""
    cancelText: ""
    closable: true
    maskClosable: true
    implicitWidth: 1120
    implicitHeight: 660

    function lookupValue(key, fallback) {
        var all = K3data.k3data_all
        for (var gi = 0; gi < all.length; gi++) {
            var m = all[gi].metrics
            for (var mi = 0; mi < m.length; mi++) {
                if (m[mi].key === key)
                    return m[mi].value !== undefined ? String(m[mi].value) : fallback
            }
        }
        return fallback
    }
    function statusColor(s) {
        switch (s) {
        case "正常": return MosTheme.Primary.colorSuccess
        case "异常": return MosTheme.Primary.colorWarning
        case "故障": return MosTheme.Primary.colorError
        default: return MosTheme.Primary.colorTextTertiary
        }
    }
    function cellV(item) {
        if (!item || !item.n) return ""
        return item.k ? lookupValue(item.k, item.v) : item.v
    }

    // ═══ 数据 ═══
    property var aiData: [
        {n:"立管压力",k:"StandpipePressure",v:"15.1",s:"正常"},
        {n:"节流后压力",k:"ThrottledPressure",v:"1.1",s:"正常"},
        {n:"主通道压力",k:"MainChannelPressure",v:"5.1",s:"正常"},
        {n:"辅助通道压力",k:"AuxiliaryChannelPressure",v:"12.2",s:"正常"},
        {n:"节流前温度",k:"temp_jieliuqian",v:"11.9",s:"正常"},
        {n:"气源压力",k:"pres_air",v:"743.2",s:"正常"},
        {n:"液压站压力",k:"pres_yeyazhan",v:"1.33",s:"正常"},
        {n:"液压站温度",k:"temp_yeyazhan",v:"62.2",s:"异常"},
        {n:"井口压力1",k:"WellheadPressure",v:"15.1",s:"正常"},
        {n:"井口压力2",k:"AI_P_wellhead2",v:"1.1",s:"正常"},
        {n:"PV-101",k:"",v:"50%",s:"正常"},
        {n:"PV-102",k:"",v:"50%",s:"正常"},
        {n:"PV-103",k:"",v:"50%",s:"正常"},
        {n:"",k:"",v:"",s:""}
    ]
    property var diData: [
        {n:"平板阀1高位开关",k:"PlateValve1_Open",v:"Open",s:"正常"},
        {n:"平板阀1低位开关",k:"PlateValve1_Close",v:"Close",s:"正常"},
        {n:"平板阀2高位开关",k:"PlateValve2_Open",v:"Close",s:"正常"},
        {n:"平板阀2低位开关",k:"PlateValve2_Close",v:"Open",s:"故障"},
        {n:"平板阀3高位开关",k:"PlateValve3_Open",v:"Close",s:"正常"},
        {n:"平板阀3低位开关",k:"PlateValve3_Close",v:"Close",s:"正常"},
        {n:"油箱低液位报警",k:"Level_Low",v:"?",s:"?"},
        {n:"液压站中控开关",k:"CentralControlId",v:"?",s:"?"},
        {n:"DCS柜高温报警",k:"CabinetTemperatureHi",v:"?",s:"?"},
        {n:"液压泵接触器",k:"Contactor1",v:"?",s:"?"},
        {n:"电加热接触器",k:"Contactor2",v:"?",s:"?"},
        {n:"",k:"",v:"",s:""},{n:"",k:"",v:"",s:""},{n:"",k:"",v:"",s:""}
    ]
    property var aodoData: [
        {n:"节流阀1阀位",k:"AI_ValvePosition1",v:"50%",s:"正常"},
        {n:"节流阀2阀位",k:"AI_ValvePosition2",v:"50%",s:"正常"},
        {n:"节流阀3阀位",k:"AI_ValvePosition3",v:"50%",s:"正常"},
        {n:"YV-101平板阀开",k:"",v:"?",s:"?"},
        {n:"YV-101平板阀关",k:"",v:"?",s:"?"},
        {n:"YV-102平板阀开",k:"",v:"?",s:"?"},
        {n:"YV-102平板阀关",k:"",v:"?",s:"?"},
        {n:"YV-103平板阀开",k:"",v:"?",s:"?"},
        {n:"YV-103平板阀关",k:"",v:"?",s:"?"},
        {n:"液压泵启停",k:"",v:"?",s:"?"},
        {n:"电加热装置启停",k:"",v:"?",s:"?"},
        {n:"",k:"",v:"",s:""},{n:"",k:"",v:"",s:""},{n:"",k:"",v:"",s:""}
    ]
    property var otherData: [
        {n:"CPU",k:"",v:"Run",s:"正常"},
        {n:"质量流量计流量",k:"OutletFlow",v:"?",s:"故障"},
        {n:"质量流量计密度",k:"OutletDensity",v:"?",s:"?"},
        {n:"质量流量计温度",k:"AI_T_EH",v:"?",s:"?"},
        {n:"BV-101",k:"",v:"50%",s:"正常"},
        {n:"BV-102",k:"",v:"50%",s:"正常"},
        {n:"BV-103",k:"",v:"50%",s:"正常"},
        {n:"比例阀1故障信号",k:"PropValve1_Fault",v:"?",s:"?"},
        {n:"比例阀2故障信号",k:"PropValve2_Fault",v:"?",s:"?"},
        {n:"比例阀3故障信号",k:"PropValve3_Fault",v:"?",s:"?"},
        {n:"",k:"",v:"",s:""},{n:"",k:"",v:"",s:""},{n:"",k:"",v:"",s:""},{n:"",k:"",v:"",s:""}
    ]

    // ═══ 反应式模型（增量更新） ═══
    property var tableModel: []
    property var tableView: null

    function buildRow(i) {
        var ai = root.aiData[i]||{n:"",v:"",s:""}, di = root.diData[i]||{n:"",v:"",s:""}
        var ao = root.aodoData[i]||{n:"",v:"",s:""}, ot = root.otherData[i]||{n:"",v:"",s:""}
        return { key:"r"+i,
            aiN:ai.n, aiV:root.cellV(ai), aiS:ai.s,
            diN:di.n, diV:root.cellV(di), diS:di.s,
            aoN:ao.n, aoV:root.cellV(ao), aoS:ao.s,
            otN:ot.n, otV:root.cellV(ot), otS:ot.s }
    }

    function initTableModel() {
        var rows = []
        for (var i = 0; i < 14; i++) rows.push(buildRow(i))
        root.tableModel = rows
    }

    function refreshChangedRows() {
        var tbl = root.tableView
        if (!tbl || !root.tableModel.length) return
        for (var i = 0; i < 14; i++) {
            var nr = buildRow(i)
            var or = root.tableModel[i]
            var dirty = !or
            if (!dirty) {
                for (var k in nr) { if (nr[k] !== or[k]) { dirty = true; break } }
            }
            if (dirty) {
                root.tableModel[i] = nr
                tbl.setRow(i, nr)
            }
        }
    }

    Component.onCompleted: initTableModel()

    Connections {
        target: K3data
        function onK3data_allChanged() { root.refreshChangedRows() }
    }

    // ═══ 委托 ═══
    Component {
        id: nameDelegate

        MosText {
            text: cellData || ""
            color: MosTheme.Primary.colorTextPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            leftPadding: 6
            rightPadding: 6
            elide: Text.ElideRight
        }
    }

    Component {
        id: valueDelegate

        MosText {
            text: cellData || ""
            color: MosTheme.Primary.colorPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            font.bold: true
            leftPadding: 4
            rightPadding: 4
        }
    }

    Component {
        id: statusDelegate

        Item {
            id: statusCell

            property string statusText: cellData || ""
            readonly property color indicatorColor: root.statusColor(statusText)

            Row {
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    width: 7
                    height: 7
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 4
                    color: statusCell.indicatorColor
                }

                MosText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: statusCell.statusText
                    color: statusCell.indicatorColor
                    font.pixelSize: 13
                }
            }
        }
    }

    // ═══ 表格组件 ═══
    Component {
        id: tableComponent
        MosTableView {
            showColumnHeader: true; showRowHeader: false
            alternatingRow: true; columnResizable: false; rowResizable: false
            minimumRowHeight: 32; defaultColumnHeaderHeight: 32
            colorColumnHeaderBg: MosThemeFunctions.alpha(MosTheme.Primary.colorPrimary, 0.14)
            colorColumnHeaderTitle: MosTheme.Primary.colorTextPrimary
            colorCellBg: "transparent"
            colorCellOddBg: MosTheme.Primary.colorFillQuaternary
            colorGridLine: MosTheme.Primary.colorSplit
            showColumnGrid: true
            showRowGrid: true
            radiusBg: MosRadius { all: 0 }

            columns: [
                { title:"模块名", dataIndex:"aiN", delegate:nameDelegate,   width:128 },
                { title:"测量值", dataIndex:"aiV", delegate:valueDelegate,  width:62 },
                { title:"状态",   dataIndex:"aiS", delegate:statusDelegate, width:82 },
                { title:"模块名", dataIndex:"diN", delegate:nameDelegate,   width:128 },
                { title:"测量值", dataIndex:"diV", delegate:valueDelegate,  width:62 },
                { title:"状态",   dataIndex:"diS", delegate:statusDelegate, width:82 },
                { title:"模块名", dataIndex:"aoN", delegate:nameDelegate,   width:128 },
                { title:"测量值", dataIndex:"aoV", delegate:valueDelegate,  width:62 },
                { title:"状态",   dataIndex:"aoS", delegate:statusDelegate, width:82 },
                { title:"模块名", dataIndex:"otN", delegate:nameDelegate,   width:128 },
                { title:"测量值", dataIndex:"otV", delegate:valueDelegate,  width:62 },
                { title:"状态",   dataIndex:"otS", delegate:statusDelegate, width:82 }
            ]

            // 反应式绑定：tableModel 变化 → onInitModelChanged → rebuild display
            initModel: root.tableModel
        }
    }

    // ═══════════════════════════════════════════
    //  内容
    // ═══════════════════════════════════════════
    contentDelegate: Item {
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight - 10

        MosFrame {
            anchors.fill: parent
            anchors.margins: 16
            padding: 0
            colorBg: MosTheme.Primary.colorFillQuaternary
            colorBorder: MosTheme.Primary.colorSplit
            borderWidth: 1
            radiusBg: MosRadius { all: 10 }
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // 页面说明
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    Layout.leftMargin: 18
                    Layout.rightMargin: 18
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 3
                        Layout.preferredHeight: 30
                        Layout.alignment: Qt.AlignVCenter
                        radius: 2
                        color: MosTheme.Primary.colorPrimary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        MosLabel {
                            Layout.fillWidth: true
                            text: "PLC I/O 实时状态"
                            colorText: MosTheme.Primary.colorTextPrimary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        MosLabel {
                            Layout.fillWidth: true
                            text: "监测模拟量、数字量及执行器信号，数据随控制器状态自动刷新"
                            colorText: MosTheme.Primary.colorTextSecondary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 12
                        }
                    }

                    MosLabel {
                        text: "4 个模块组  ·  实时刷新"
                        colorText: MosTheme.Primary.colorTextTertiary
                        colorBg: "transparent"
                        colorBorder: "transparent"
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: MosTheme.Primary.colorSplit
                }

                // 模块标题行
                Row {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38

                    Repeater {
                        model: ["AI 模拟量输入", "DI 数字量输入", "AO/DO 输出", "其他信号"]

                        MosFrame {
                            id: moduleHeader
                            required property string modelData

                            width: parent.width / 4
                            height: 38
                            padding: 0
                            colorBg: MosThemeFunctions.alpha(MosTheme.Primary.colorPrimary, 0.20)
                            colorBorder: MosTheme.Primary.colorSplit
                            radiusBg: MosRadius { all: 0 }

                            MosLabel {
                                anchors.centerIn: parent
                                text: moduleHeader.modelData
                                colorText: MosTheme.Primary.colorTextPrimary
                                colorBg: "transparent"
                                colorBorder: "transparent"
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                }

                // 表格主体 — 占满剩余空间
                Loader {
                    id: tableLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 420
                    sourceComponent: tableComponent
                    onItemChanged: root.tableView = item
                }

                // 状态图例与操作
                MosFrame {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    padding: 0
                    colorBg: MosThemeFunctions.alpha(MosTheme.Primary.colorTextBase, 0.025)
                    colorBorder: MosTheme.Primary.colorSplit
                    borderWidth: 1
                    radiusBg: MosRadius { all: 0 }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        spacing: 14

                        MosLabel {
                            text: "状态图例"
                            colorText: MosTheme.Primary.colorTextTertiary
                            colorBg: "transparent"
                            colorBorder: "transparent"
                            font.pixelSize: 12
                        }

                        Repeater {
                            model: [
                                { label: "正常", color: MosTheme.Primary.colorSuccess },
                                { label: "异常", color: MosTheme.Primary.colorWarning },
                                { label: "故障", color: MosTheme.Primary.colorError }
                            ]

                            Row {
                                id: legendItem
                                required property var modelData

                                spacing: 6

                                Rectangle {
                                    width: 7
                                    height: 7
                                    anchors.verticalCenter: parent.verticalCenter
                                    radius: 4
                                    color: legendItem.modelData.color
                                }

                                MosText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: legendItem.modelData.label
                                    color: MosTheme.Primary.colorTextSecondary
                                    font.pixelSize: 12
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        MosIconButton {
                            Layout.preferredWidth: 88
                            Layout.preferredHeight: 34
                            text: "退出"
                            iconSource: MosIcon.IcoMoonExit
                            font.pixelSize: 13
                            type: MosButton.Type_Default
                            onClicked: root.close()
                        }
                    }
                }
            }
        }
    }
}
