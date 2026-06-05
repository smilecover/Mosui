pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle {
    id: tpinvFault
    color: "transparent"
    anchors.fill: parent

    property real faultValue: 0

    // 从后端 hex 故障码同步到数值
    function syncFaultFromBackend() {
        const parsed = parseHex(TpInvcontroldata.faultCode)
        if (faultValue !== parsed)
            faultValue = parsed
    }
    readonly property color textStrong: MosTheme.Primary.colorTextPrimary
    readonly property color textMuted: MosTheme.Primary.colorTextSecondary
    readonly property color borderColor: MosTheme.Primary.colorSplit
    readonly property var faultItems: [
        { bit: 0, label: "A相慢速过压" },
        { bit: 1, label: "B相慢速过压" },
        { bit: 2, label: "C相慢速过压" },
        { bit: 3, label: "直流慢速过压" },
        { bit: 4, label: "半母线慢速过压" },
        { bit: 5, label: "A相慢速过流" },
        { bit: 6, label: "B相慢速过流" },
        { bit: 7, label: "C相慢速过流" },
        { bit: 8, label: "直流慢速过流" },
        { bit: 9, label: "功率管过温" },
        { bit: 10, label: "辅源过温" },
        { bit: 11, label: "2.5V偏置电压高" },
        { bit: 12, label: "1.65V偏置电压高" },
        { bit: 13, label: "2.5V偏置电压低" },
        { bit: 14, label: "1.65V偏置电压低" },
        { bit: 15, label: "A相快速过压" },
        { bit: 16, label: "B相快速过压" },
        { bit: 17, label: "C相快速过压" },
        { bit: 18, label: "直流快速过压" },
        { bit: 19, label: "半母线快速过压" },
        { bit: 20, label: "A相快速过流" },
        { bit: 21, label: "B相快速过流" },
        { bit: 22, label: "C相快速过流" },
        { bit: 23, label: "直流快速过流" },
        { bit: 24, label: "硬件过流" },
        { bit: 25, label: "通信故障" },
        { bit: 26, label: "预留" },
        { bit: 27, label: "预留" },
        { bit: 28, label: "预留" },
        { bit: 29, label: "预留" },
        { bit: 30, label: "预留" },
        { bit: 31, label: "预留" }
    ]
    readonly property int faultBitCount: faultItems.length

    function maxFaultValue() {
        return Math.pow(2, faultBitCount) - 1;
    }

    function clampFaultValue(value) {
        if (!isFinite(value)) {
            return 0;
        }
        return Math.max(0, Math.min(maxFaultValue(), Math.floor(value)));
    }

    function padLeft(text, length, fill) {
        text = String(text);
        while (text.length < length) {
            text = fill + text;
        }
        return text;
    }

    function hexText(value) {
        return "0x" + padLeft(clampFaultValue(value).toString(16).toUpperCase(), Math.ceil(faultBitCount / 4), "0");
    }

    function binText(value) {
        return padLeft(clampFaultValue(value).toString(2), faultBitCount, "0");
    }

    function activeFaultCount() {
        var count = 0;
        for (var i = 0; i < faultBitCount; ++i) {
            if (isBitActive(i)) {
                ++count;
            }
        }
        return count;
    }

    function isBitActive(bit) {
        var weight = Math.pow(2, bit);
        return Math.floor(clampFaultValue(faultValue) / weight) % 2 === 1;
    }

    function toggleFaultBit(bit) {
        var weight = Math.pow(2, bit);
        setFaultValue(isBitActive(bit) ? faultValue - weight : faultValue + weight);
    }

    function parseDec(text) {
        return Number(String(text).replace(/[^0-9]/g, ""));
    }

    function parseHex(text) {
        var value = String(text).replace(/^0x/i, "").replace(/[^0-9a-fA-F]/g, "");
        return parseInt(value === "" ? "0" : value, 16);
    }

    function parseBin(text) {
        var value = String(text).replace(/[^01]/g, "").slice(0, faultBitCount);
        return parseInt(value === "" ? "0" : value, 2);
    }

    function setFaultValue(value) {
        faultValue = clampFaultValue(value);
    }

    Component.onCompleted: syncFaultFromBackend()

    Connections {
        target: TpInvcontroldata
        function onKeyMetricsChanged() { syncFaultFromBackend() }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        ScrollBar.vertical: MosScrollBar { anchors.right: parent.right }

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 10

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: titleRow.implicitHeight

                RowLayout {
                    id: titleRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    MosIconText {
                        Layout.alignment: Qt.AlignVCenter
                        iconSource: 0xe851
                        iconSize: MosTheme.Primary.fontPrimarySize+22
                        font.bold: true
                    }
                    MosText {
                        Layout.alignment: Qt.AlignVCenter
                        text: "故障码分析仪"
                        font.pixelSize: MosTheme.Primary.fontPrimarySize+22
                        font.bold: true
                    }
                    MosTag{
                        Layout.alignment: Qt.AlignTop
                        radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                        text: tpinvFault.faultBitCount + "-bit 实时解析"
                        colorText: MosTheme.Primary.colorTextBase
                        presetColor: "geekblue"
                    }
                }

            }
            MosText {
                Layout.alignment: Qt.AlignHCenter
                text: "每一位故障独立监控 · 点击卡片快速切换状态"
                font.pixelSize: MosTheme.Primary.fontPrimarySize
            }
            MosCard {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.topMargin: 26
                Layout.minimumWidth: 500
                borderWidth: 1
                colorBg: MosTheme.Primary.colorFillQuaternary
                colorBorder: MosTheme.Primary.colorPrimaryBorder
                radiusBg.all: 28
                titleDelegate: Item { implicitHeight: 0 }
                coverDelegate: Item { implicitHeight: 0 }

                bodyDelegate: Item {
                    implicitHeight: faultCardBody.implicitHeight + 48

                    ColumnLayout {
                        id: faultCardBody
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 28
                        spacing: 24

                        GridLayout {
                            Layout.fillWidth: true
                            columns: width < 760 ? 1 : 3
                            columnSpacing: 24
                            rowSpacing: 16

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 220
                                spacing: 8

                                RowLayout {
                                    spacing: 6
                                    MosText {
                                        text: "🔢"
                                        color: MosTheme.Primary.colorPrimaryText
                                        font.pixelSize: 13
                                    }
                                    MosText {
                                        text: "十进制 (DEC)"
                                        color: tpinvFault.textMuted
                                        font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                                    }
                                }

                                MosInput {
                                    id: decInput
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    verticalAlignment: Text.AlignVCenter
                                    text: String(tpinvFault.faultValue)
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    colorBg: "transparent"
                                    colorText: tpinvFault.textStrong
                                    onTextEdited: tpinvFault.setFaultValue(tpinvFault.parseDec(text))
                                    bgDelegate: MosRectangle {
                                        color: decInput.activeFocus ? MosTheme.Primary.colorFillPrimary : decInput.hovered ? MosTheme.Primary.colorFillQuaternary : "transparent"
                                        border.color: decInput.activeFocus ? MosTheme.Primary.colorPrimaryBorder : decInput.hovered ? MosTheme.Primary.colorBorder : tpinvFault.borderColor
                                        border.width: decInput.activeFocus ? 2 : 1
                                        radius: 20

                                        Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                                        Behavior on border.color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 220
                                spacing: 8

                                RowLayout {
                                    spacing: 6
                                    MosText {
                                        text: "🧬"
                                        color: MosTheme.Primary.colorInfoText
                                        font.pixelSize: 13
                                    }
                                    MosText {
                                        text: "十六进制 (HEX)"
                                        color: tpinvFault.textMuted
                                        font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                                    }
                                }

                                MosInput {
                                    id: hexInput
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    verticalAlignment: Text.AlignVCenter
                                    text: tpinvFault.hexText(tpinvFault.faultValue)
                                    colorBg: "transparent"
                                    colorText: tpinvFault.textStrong
                                    onTextEdited: tpinvFault.setFaultValue(tpinvFault.parseHex(text))
                                    bgDelegate: MosRectangle {
                                        color: hexInput.activeFocus ? MosTheme.Primary.colorFillPrimary : hexInput.hovered ? MosTheme.Primary.colorFillQuaternary : "transparent"
                                        border.color: hexInput.activeFocus ? MosTheme.Primary.colorPrimaryBorder : hexInput.hovered ? MosTheme.Primary.colorBorder : tpinvFault.borderColor
                                        border.width: hexInput.activeFocus ? 2 : 1
                                        radius: 20

                                        Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                                        Behavior on border.color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 260
                                spacing: 8

                                RowLayout {
                                    spacing: 6
                                    MosText {
                                        text: "⚡"
                                        color: MosTheme.Primary.colorWarningText
                                        font.pixelSize: 13
                                    }
                                    MosText {
                                        text: "二进制 (BIN / " + tpinvFault.faultBitCount + "位)"
                                        color: tpinvFault.textMuted
                                        font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                                    }
                                }

                                MosInput {
                                    id: binInput
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    verticalAlignment: Text.AlignVCenter
                                    text: tpinvFault.binText(tpinvFault.faultValue)
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    colorBg: "transparent"
                                    colorText: tpinvFault.textStrong
                                    font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                                    onTextEdited: tpinvFault.setFaultValue(tpinvFault.parseBin(text))
                                    bgDelegate: MosRectangle {
                                        color: binInput.activeFocus ? MosTheme.Primary.colorFillPrimary : binInput.hovered ? MosTheme.Primary.colorFillQuaternary : "transparent"
                                        border.color: binInput.activeFocus ? MosTheme.Primary.colorPrimaryBorder : binInput.hovered ? MosTheme.Primary.colorBorder : tpinvFault.borderColor
                                        border.width: binInput.activeFocus ? 2 : 1
                                        radius: 20

                                        Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                                        Behavior on border.color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                                    }
                                }
                            }
                        }
                        MosRectangle {
                            width: childrenRect.width+ 2
                            height: childrenRect.height + 2
                            radius: 26
                            color: "transparent"
                            border.color: MosTheme.Primary.colorSplit
                            border.width: 1
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                Column {
                                    id: guzero
                                    Layout.leftMargin: 15
                                    spacing:-2
                                    MosText {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: tpinvFault.activeFaultCount()
                                        color: tpinvFault.textStrong
                                        font.pixelSize: 28
                                        font.bold: true
                                    }

                                    MosText {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "活跃故障"
                                        color: tpinvFault.textMuted
                                        font.pixelSize: MosTheme.Primary.fontPrimarySize - 4
                                    }
                                }
                                MosButton {
                                    Layout.preferredWidth: 112
                                    Layout.preferredHeight: 38
                                    text: "✕ 全部清零"
                                    radiusBg.all: 19
                                    colorBorder: down ? MosTheme.Primary.colorPrimaryBorderActive : hovered ? MosTheme.Primary.colorPrimaryBorderHover : MosTheme.Primary.colorBorder
                                    colorText: tpinvFault.textStrong
                                    font.bold: true
                                    onClicked: tpinvFault.setFaultValue(0)
                                }


                                MosButton {
                                    Layout.preferredWidth: 132
                                    Layout.preferredHeight: 38
                                    Layout.rightMargin: 12
                                    text: "📋 复制故障码"
                                    type: MosButton.Type_Primary
                                    radiusBg.all: 19
                                    colorBg: down ? "#1f55d8" : hovered ? '#00377dff' : "#246bfe"
                                    colorBorder: down ? "#1f55d8" : hovered ? "#6ba0ff" : "#246bfe"
                                    font.bold: true
                                    onClicked: MosApi.setClipboardText(tpinvFault.hexText(tpinvFault.faultValue))
                                }

                            }
                        }
                    }
                }
            }
            MosRectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.topMargin: 10
                Layout.preferredHeight: 44
                color: "transparent"
                border.color: MosTheme.Primary.colorPrimaryBorder
                radius: 28
                border.width: 1
                RowLayout {
                    anchors.centerIn: parent
                    anchors.margins: 10
                    spacing: 6
                    MosText {
                        Layout.alignment: Qt.AlignVCenter
                        text: "📡"
                        color: MosTheme.Primary.colorPrimaryText
                        font.pixelSize: 13
                    } 
                    MosText {
                        Layout.alignment: Qt.AlignVCenter
                        text: "当前故障位流 |"
                        color: tpinvFault.textMuted
                        font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                    }
                    MosText {
                        Layout.alignment: Qt.AlignVCenter
                        text: tpinvFault.binText(tpinvFault.faultValue)
                        color: tpinvFault.textStrong
                        font.pixelSize: MosTheme.Primary.fontPrimarySize - 2
                    }
                }
            }
            MosRectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.topMargin: 18
                Layout.preferredHeight: faultGrid.implicitHeight + 20
                color: "transparent"

                GridLayout {
                    id: faultGrid
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    columns: width < 760 ? 1 : width < 1120 ? 2 : 4
                    columnSpacing: 12
                    rowSpacing: 12

                    Repeater {
                        model: tpinvFault.faultItems

                        delegate: MosRectangle {
                            id: faultBitCard
                            required property var modelData

                            readonly property bool active: tpinvFault.isBitActive(modelData.bit)
                            readonly property bool highlighted: active || hoverHandler.hovered

                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            radius: 18
                            color: active ? MosTheme.Primary.colorPrimaryBg : hoverHandler.hovered ? MosTheme.Primary.colorFillPrimary : "transparent"
                            border.width: 1
                            border.color: active ? MosTheme.Primary.colorPrimaryBorder : hoverHandler.hovered ? MosTheme.Primary.colorBorder : tpinvFault.borderColor

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 12

                                MosRectangle {
                                    Layout.preferredWidth: 14
                                    Layout.preferredHeight: 14
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 7
                                    color: faultBitCard.active ? "#ff7a18" : "#2a4a78"
                                }

                                MosText {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: faultBitCard.modelData.label
                                    color: faultBitCard.highlighted ? tpinvFault.textStrong : tpinvFault.textMuted
                                    font.pixelSize: MosTheme.Primary.fontPrimarySize - 1
                                    font.bold: faultBitCard.highlighted
                                    elide: Text.ElideRight
                                }

                                MosTag {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "bit" + faultBitCard.modelData.bit
                                    presetColor: "geekblue"
                                    radiusBg.all: 10
                                    colorText: tpinvFault.textMuted
                                }

                                MosTag {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: faultBitCard.active ? "1" : "0"
                                    presetColor: faultBitCard.active ? "orange" : "geekblue"
                                    radiusBg.all: 10
                                    colorText: faultBitCard.active ? MosTheme.Primary.colorWarningText : tpinvFault.textMuted
                                }
                            }

                            HoverHandler {
                                id: hoverHandler
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: tpinvFault.toggleFaultBit(faultBitCard.modelData.bit)
                            }

                            Behavior on color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                            Behavior on border.color { ColorAnimation { duration: MosTheme.Primary.durationFast } }
                        }
                    }
                }
            }
        }
    }
}
