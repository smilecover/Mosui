pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MosuiBasic

MosRectangle {
    id: sampPage
    anchors.fill: parent
    color: "transparent"

    readonly property color textStrong: MosTheme.Primary.colorTextPrimary
    readonly property color textMuted: MosTheme.Primary.colorTextSecondary
    readonly property color textSubtle: MosTheme.Primary.colorTextTertiary
    readonly property color panelBorder: MosTheme.Primary.colorSplit
    readonly property color panelBg: "transparent"
    readonly property color fieldBg: "transparent"
    readonly property real epsilon: 0.000001
    readonly property bool narrowLayout: width < 560
    readonly property bool compactLayout: width < 780
    readonly property int pageMargin: width < 520 ? 10 : width < 900 ? 14 : 20
    readonly property int panelMargin: width < 520 ? 12 : 20
    readonly property int panelGap: width < 520 ? 10 : 14
    readonly property int fieldHeight: width < 520 ? 34 : 36
    readonly property int buttonHeight: width < 520 ? 36 : 40

    property int loadPhase: 0
    property int selectedCorrectionIndex: 0
    property real aRealValue: 0
    property real aSampleValue: 0
    property real bRealValue: 0
    property real bSampleValue: 0
    property real coefficientA: 1
    property real coefficientB: 0
    property real storedCoefficientA: 1
    property real storedCoefficientB: 0
    property real queryCoefficientA: 1
    property real queryCoefficientB: 0
    property bool queryFromDsp: false

    readonly property var correctionTypes: [
        { label: "直流电压", value: "dcVoltage", unit: "V", accent: "#2f8dff" },
        { label: "半母线电压", value: "halfBusVoltage", unit: "V", accent: "#28c7d8" },
        { label: "交流电压有效值", value: "acVoltageRms", unit: "V", accent: "#b88cff" },
        { label: "直流电流", value: "dcCurrent", unit: "A", accent: "#37d6a3" },
        { label: "交流电流有效值", value: "acCurrentRms", unit: "A", accent: "#ff8a4c" }
    ]

    function optionIndex(options, value) {
        for (let i = 0; i < options.length; ++i) {
            if (options[i].value === value)
                return i
        }
        return options.length > 0 ? 0 : -1
    }

    function currentType() {
        if (selectedCorrectionIndex < 0 || selectedCorrectionIndex >= correctionTypes.length)
            return correctionTypes[0]
        return correctionTypes[selectedCorrectionIndex]
    }

    function selectedUnit() {
        return currentType().unit
    }

    function selectedAccent() {
        return currentType().accent
    }

    function canCalculate() {
        return Math.abs(bSampleValue - aSampleValue) > epsilon
    }

    function calculatedA() {
        if (!canCalculate())
            return coefficientA
        return (bRealValue - aRealValue) / (bSampleValue - aSampleValue)
    }

    function calculatedB() {
        if (!canCalculate())
            return coefficientB
        return aRealValue - calculatedA() * aSampleValue
    }

    function formatNumber(value, precision) {
        if (!isFinite(value))
            return "--"
        return Number(value).toFixed(precision)
    }

    function calculateCorrection() {
        if (!canCalculate())
            return false
        coefficientA = calculatedA()
        coefficientB = calculatedB()
        return true
    }

    function saveCorrection() {
        storedCoefficientA = coefficientA
        storedCoefficientB = coefficientB
    }

    function queryCorrection() {
        const typeKey = currentType().value
        const data = TpInvcontroldata.calibrationData
        if (data && data[typeKey] !== undefined) {
            const coeff = data[typeKey]
            queryCoefficientA = (coeff.a !== undefined) ? Number(coeff.a) : 1
            queryCoefficientB = (coeff.b !== undefined) ? Number(coeff.b) : 0
            queryFromDsp = true
        } else {
            queryCoefficientA = storedCoefficientA
            queryCoefficientB = storedCoefficientB
            queryFromDsp = false
        }
    }

    Timer {
        interval: 60
        repeat: true
        running: sampPage.loadPhase < 3
        triggeredOnStart: true
        onTriggered: sampPage.loadPhase += 1
    }

    component SectionPanel: MosRectangle {
        id: sectionPanel
        default property alias content: panelBody.data
        property string title: ""
        property string subtitle: ""
        property color accentColor: MosTheme.Primary.colorPrimary

        Layout.minimumWidth: 0
        implicitHeight: sectionLayout.implicitHeight + 2
        radius: 10
        color: sampPage.panelBg
        border.width: 1
        border.color: sampPage.panelBorder
        clip: true

        ColumnLayout {
            id: sectionLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 0

            GridLayout {
                Layout.fillWidth: true
                Layout.minimumHeight: headerTextColumn.implicitHeight + 22
                Layout.leftMargin: sampPage.panelMargin
                Layout.rightMargin: sampPage.panelMargin
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                columns: width < 360 ? 1 : 2
                columnSpacing: 10
                rowSpacing: 6

                MosRectangle {
                    Layout.preferredWidth: 5
                    Layout.preferredHeight: 18
                    Layout.alignment: Qt.AlignVCenter
                    radius: 3
                    color: sectionPanel.accentColor
                }

                ColumnLayout {
                    id: headerTextColumn
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 1

                    MosText {
                        Layout.fillWidth: true
                        text: sectionPanel.title
                        color: sampPage.textStrong
                        font.pixelSize: 16
                        font.bold: true
                        wrapMode: Text.Wrap
                    }

                    MosText {
                        Layout.fillWidth: true
                        visible: text.length > 0
                        text: sectionPanel.subtitle
                        color: sampPage.textSubtle
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }

            MosDivider {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                colorSplit: MosTheme.Primary.colorSplit
            }

            ColumnLayout {
                id: panelBody
                Layout.fillWidth: true
                Layout.leftMargin: sampPage.panelMargin
                Layout.rightMargin: sampPage.panelMargin
                Layout.topMargin: 16
                Layout.bottomMargin: 18
                spacing: sampPage.panelGap
            }
        }
    }

    component LazyLoader: Loader {
        asynchronous: true
        active: false
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.preferredHeight: item && item.implicitHeight > 0 ? item.implicitHeight : 96
        Layout.minimumHeight: active ? 0 : 1
    }

    property Component selectorComponent: SectionPanel {
        title: "线性校正"
        subtitle: "真实值 = 校正系数A × 采样值 + 校正系数B"
        accentColor: sampPage.selectedAccent()

        GridLayout {
            Layout.fillWidth: true
            columns: width < 1080 ? 1 : 2
            columnSpacing: sampPage.panelGap
            rowSpacing: sampPage.panelGap

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 8

                MosText {
                    text: "校正类型"
                    color: sampPage.textMuted
                    font.pixelSize: 12
                }

                MosSelect {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.preferredHeight: 38
                    model: sampPage.correctionTypes
                    currentIndex: sampPage.selectedCorrectionIndex
                    clearEnabled: false
                    colorBg: sampPage.fieldBg
                    colorBorder: sampPage.panelBorder
                    colorText: sampPage.textStrong
                    radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                    onActivated: sampPage.selectedCorrectionIndex = currentIndex
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: formulaLayout.implicitHeight + 24
                radius: 8
                color: MosTheme.Primary.colorFillQuaternary
                border.width: 1
                border.color: MosTheme.Primary.colorSplit

                ColumnLayout {
                    id: formulaLayout
                    anchors.fill: parent
                    anchors.margins: sampPage.narrowLayout ? 10 : 12
                    spacing: 6

                    MosText {
                        Layout.fillWidth: true
                        text: "校正公式"
                        color: sampPage.textMuted
                        font.pixelSize: 12
                    }

                    MosText {
                        Layout.fillWidth: true
                        text: "真实值 = " + sampPage.formatNumber(sampPage.coefficientA, 6)
                              + " × 采样值 + " + sampPage.formatNumber(sampPage.coefficientB, 6)
                        color: sampPage.textStrong
                        font.family: "Consolas"
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                    }

                    MosText {
                        Layout.fillWidth: true
                        text: "当前对象：" + sampPage.currentType().label + " / 单位 " + sampPage.selectedUnit()
                        color: sampPage.textSubtle
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    property Component pointsComponent: Item {
        implicitHeight: pointsGrid.implicitHeight

        GridLayout {
            id: pointsGrid
            anchors.left: parent.left
            anchors.right: parent.right
            columns: sampPage.compactLayout ? 1 : 2
            columnSpacing: sampPage.panelGap
            rowSpacing: sampPage.panelGap

            SectionPanel {
                Layout.fillWidth: true
                title: "A 点"
                subtitle: "低点或第一个标定点"
                accentColor: "#2f8dff"

                Repeater {
                    model: [
                        { label: "A点真实值", propertyName: "aRealValue" },
                        { label: "A点采样值", propertyName: "aSampleValue" }
                    ]

                    delegate: GridLayout {
                        id: aPointField
                        required property var modelData

                        Layout.fillWidth: true
                        columns: width < 360 ? 1 : 2
                        columnSpacing: 12
                        rowSpacing: 6

                        MosText {
                            Layout.fillWidth: aPointField.columns === 1
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: aPointField.columns === 1 ? aPointField.width : Math.min(112, Math.max(82, aPointField.width * 0.32))
                            Layout.alignment: Qt.AlignVCenter
                            text: aPointField.modelData.label
                            color: sampPage.textMuted
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        MosInputNumber {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredHeight: sampPage.fieldHeight
                            value: sampPage[aPointField.modelData.propertyName]
                            precision: 6
                            step: 0.1
                            min: -999999999
                            max: 999999999
                            useKeyboard: true
                            colorBg: sampPage.fieldBg
                            colorBorder: sampPage.panelBorder
                            colorText: sampPage.textStrong
                            suffix: " " + sampPage.selectedUnit()
                            showHandler: false
                            radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                            inputFont.family: "Consolas"
                            inputFont.pixelSize: 13
                            onValueChanged: sampPage[aPointField.modelData.propertyName] = value
                        }
                    }
                }
            }

            SectionPanel {
                Layout.fillWidth: true
                title: "B 点"
                subtitle: "高点或第二个标定点"
                accentColor: "#37d6a3"

                Repeater {
                    model: [
                        { label: "B点真实值", propertyName: "bRealValue" },
                        { label: "B点采样值", propertyName: "bSampleValue" }
                    ]

                    delegate: GridLayout {
                        id: bPointField
                        required property var modelData

                        Layout.fillWidth: true
                        columns: width < 360 ? 1 : 2
                        columnSpacing: 12
                        rowSpacing: 6

                        MosText {
                            Layout.fillWidth: bPointField.columns === 1
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: bPointField.columns === 1 ? bPointField.width : Math.min(112, Math.max(82, bPointField.width * 0.32))
                            Layout.alignment: Qt.AlignVCenter
                            text: bPointField.modelData.label
                            color: sampPage.textMuted
                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        MosInputNumber {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredHeight: sampPage.fieldHeight
                            value: sampPage[bPointField.modelData.propertyName]
                            precision: 6
                            step: 0.1
                            min: -999999999
                            max: 999999999
                            useKeyboard: true
                            colorBg: sampPage.fieldBg
                            colorBorder: sampPage.panelBorder
                            colorText: sampPage.textStrong
                            suffix: " " + sampPage.selectedUnit()
                            showHandler: false
                            radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                            inputFont.family: "Consolas"
                            inputFont.pixelSize: 13
                            onValueChanged: sampPage[bPointField.modelData.propertyName] = value
                        }
                    }
                }
            }
        }
    }

    property Component resultsComponent: SectionPanel {
        title: "校正结果"
        subtitle: sampPage.canCalculate() ? "可计算并写入校正系数" : "A/B 两点采样值不能相同"
        accentColor: sampPage.canCalculate() ? MosTheme.Primary.colorSuccessText : MosTheme.Primary.colorWarningText

        GridLayout {
            Layout.fillWidth: true
            columns: sampPage.compactLayout ? 1 : 2
            columnSpacing: sampPage.panelGap
            rowSpacing: sampPage.panelGap

            MosRectangle {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: resultColumn.implicitHeight + 24
                radius: 8
                color: MosTheme.Primary.colorFillQuaternary
                border.width: 1
                border.color: MosTheme.Primary.colorSplit

                ColumnLayout {
                    id: resultColumn
                    anchors.fill: parent
                    anchors.margins: sampPage.narrowLayout ? 10 : 12
                    spacing: 9

                    RowLayout {
                        Layout.fillWidth: true
                        MosText {
                            Layout.fillWidth: true
                            text: "计算结果"
                            color: sampPage.textMuted
                            font.pixelSize: 12
                        }
                        MosTag {
                            text: sampPage.canCalculate() ? "READY" : "WAIT"
                            presetColor: sampPage.canCalculate() ? "green" : "orange"
                            radiusBg.all: 10
                        }
                    }

                    Repeater {
                        model: [
                            { label: "校正系数A", value: sampPage.coefficientA },
                            { label: "校正系数B", value: sampPage.coefficientB }
                        ]

                        delegate: GridLayout {
                            id: resultValueRow
                            required property var modelData
                            Layout.fillWidth: true
                            columns: width < 330 ? 1 : 2
                            columnSpacing: 12
                            rowSpacing: 4

                            MosText {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                text: resultValueRow.modelData.label
                                color: sampPage.textMuted
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            MosText {
                                Layout.fillWidth: resultValueRow.columns === 1
                                Layout.minimumWidth: 0
                                text: sampPage.formatNumber(resultValueRow.modelData.value, 8)
                                color: sampPage.textStrong
                                font.family: "Consolas"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: resultValueRow.columns === 1 ? Text.AlignLeft : Text.AlignRight
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            MosRectangle {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: queryColumn.implicitHeight + 24
                radius: 8
                color: MosTheme.Primary.colorFillQuaternary
                border.width: 1
                border.color: MosTheme.Primary.colorSplit

                ColumnLayout {
                    id: queryColumn
                    anchors.fill: parent
                    anchors.margins: sampPage.narrowLayout ? 10 : 12
                    spacing: 9

                    RowLayout {
                        Layout.fillWidth: true
                        MosText {
                            Layout.fillWidth: true
                            text: "查询结果"
                            color: sampPage.textMuted
                            font.pixelSize: 12
                        }
                        MosTag {
                            visible: sampPage.queryFromDsp
                            text: "DSP"
                            presetColor: "green"
                            radiusBg.all: 10
                        }
                        MosTag {
                            visible: !sampPage.queryFromDsp
                            text: "本地"
                            presetColor: "orange"
                            radiusBg.all: 10
                        }
                    }

                    Repeater {
                        model: [
                            { label: "校正系数A", value: sampPage.queryCoefficientA },
                            { label: "校正系数B", value: sampPage.queryCoefficientB }
                        ]

                        delegate: GridLayout {
                            id: queryValueRow
                            required property var modelData
                            Layout.fillWidth: true
                            columns: width < 330 ? 1 : 2
                            columnSpacing: 12
                            rowSpacing: 4

                            MosText {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                text: queryValueRow.modelData.label
                                color: sampPage.textMuted
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }

                            MosText {
                                Layout.fillWidth: queryValueRow.columns === 1
                                Layout.minimumWidth: 0
                                text: sampPage.formatNumber(queryValueRow.modelData.value, 8)
                                color: sampPage.textStrong
                                font.family: "Consolas"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: queryValueRow.columns === 1 ? Text.AlignLeft : Text.AlignRight
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            columns: width < 900 ? 1 : 3
            columnSpacing: 10
            rowSpacing: 10

            MosButton {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: sampPage.buttonHeight
                text: "校正计算"
                enabled: sampPage.canCalculate()
                type: MosButton.Type_Primary
                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                font.bold: true
                onClicked: sampPage.calculateCorrection()
            }

            MosButton {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: sampPage.buttonHeight
                text: "存储校正参数"
                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                colorBg: "transparent"
                colorBorder: MosTheme.Primary.colorBorder
                colorText: sampPage.textStrong
                onClicked: sampPage.saveCorrection()
            }

            MosButton {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredHeight: sampPage.buttonHeight
                text: "校正参数查询"
                radiusBg.all: MosTheme.Primary.radiusPrimaryLG
                colorBg: "transparent"
                colorBorder: MosTheme.Primary.colorBorder
                colorText: sampPage.textStrong
                onClicked: sampPage.queryCorrection()
            }
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, contentColumn.implicitHeight + 24)
        clip: true

        ScrollBar.vertical: MosScrollBar {
            anchors.right: parent.right
        }

        ColumnLayout {
            id: contentColumn
            width: flickable.width
            spacing: 14

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: titleRow.implicitHeight + 18

                GridLayout {
                    id: titleRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: sampPage.pageMargin
                    anchors.rightMargin: sampPage.pageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    columns: width < 420 ? 1 : 2
                    columnSpacing: 10
                    rowSpacing: 6

                    MosText {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: "线性校正"
                        color: sampPage.textStrong
                        font.pixelSize: sampPage.narrowLayout ? 20 : 24
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    MosTag {
                        Layout.alignment: titleRow.columns === 1 ? (Qt.AlignLeft | Qt.AlignVCenter) : (Qt.AlignRight | Qt.AlignVCenter)
                        text: sampPage.currentType().label
                        colorBg: MosTheme.Primary.colorPrimaryBg
                        colorBorder: MosTheme.Primary.colorPrimaryBorder
                        colorText: MosTheme.Primary.colorPrimaryText
                        radiusBg.all: implicitHeight / 2
                    }
                }
            }

            LazyLoader {
                Layout.leftMargin: sampPage.pageMargin
                Layout.rightMargin: sampPage.pageMargin
                active: sampPage.loadPhase >= 1
                sourceComponent: sampPage.selectorComponent
            }

            LazyLoader {
                Layout.leftMargin: sampPage.pageMargin
                Layout.rightMargin: sampPage.pageMargin
                active: sampPage.loadPhase >= 2
                sourceComponent: sampPage.pointsComponent
            }

            LazyLoader {
                Layout.leftMargin: sampPage.pageMargin
                Layout.rightMargin: sampPage.pageMargin
                Layout.bottomMargin: 20
                active: sampPage.loadPhase >= 3
                sourceComponent: sampPage.resultsComponent
            }
        }
    }
}
