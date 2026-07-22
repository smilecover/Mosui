pragma ComponentBehavior: Bound
import QtQuick
import MosuiBasic

Item {
    id: root
    clip: true

    property real designWidth: 1340
    property real designHeight: 650
    property real viewportPadding: 8

    property string valveAValue: "70.0%"
    property string valveBValue: "60.0%"
    property string valveCValue: "20.0%"

    property string mainPressure: "0MPa"
    property string auxiliaryPressure: "0MPa"
    property string pipePressure: "0MPa"
    property string branchPressure: "0MPa"

    function asset(name) {
        return "qrc:/" + name
    }

    MosRectangle {
        anchors.fill: parent
        color: "#07090d"
        opacity: 0.82
    }

    Item {
        id: viewport
        anchors.fill: parent
        anchors.margins: root.viewportPadding
        clip: true
    }

    Item {
        id: scene
        width: root.designWidth
        height: root.designHeight
        x: (root.width - width * scale) / 2
        y: (root.height - height * scale) / 2
        scale: Math.max(0.1, Math.min(Math.max(1, root.width - root.viewportPadding * 2) / width,
                                      Math.max(1, root.height - root.viewportPadding * 2) / height))
        transformOrigin: Item.TopLeft

        PipeImage { x: 332; y: 597; width: 70; height: 14; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 337; y: 303; width: 79; height: 16; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 379; y: 549; width: 45; height: 62; source: root.asset("pipe_choke.png") }
        PipeImage { x: 414; y: 597; width: 45; height: 14; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 890; y: 327; width: 14; height: 115; source: root.asset("pipe_vertical.png") }

        ValvePanel {
            x: 456
            y: 34
            title: "节流阀C"
            valueText: root.valveCValue
            frameHeight: 120
            progressX: 1
            progressWidth: 488
            progressHeight: 70
            progressY: 5
            fillX: 6
            fillY: 7
            fillHeight: 65
            controlsX: 8
            controlsY: 74

        }

        ValvePanel {
            x: 638
            y: 168
            title: "节流阀A"
            valueText: root.valveAValue
            frameHeight: 120
            progressX: 1
            progressWidth: 488
            progressHeight: 70
            progressY: 5
            fillX: 6
            fillY: 7
            fillHeight: 65
            controlsX: 8
            controlsY: 74
        }

        ValvePanel {
            x: 500
            y: 500
            title: "节流阀B"
            valueText: root.valveBValue
            frameHeight: 120
            progressX: 1
            progressY: 5
            progressWidth: 488
            progressHeight: 70
            fillX: 6
            fillY: 7
            fillHeight: 65
            controlsX: 8
            controlsY: 74
    
        }

        PipeImage { x: 462; y: 327; width: 16; height: 255; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 210; y: 209; width: 206; height: 15; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 41; y: 255; width: 54; height: 15; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 572; y: 231; width: 16; height: 214; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 135; y: 450; width: 168; height: 15; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 111; y: 271; width: 15; height: 177; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 326; y: 451; width: 1003; height: 15; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 374; y: 162; width: 44; height: 62; source: root.asset("pipe_choke.png") }
        PipeImage { x: 95; y: 255; width: 30; height: 30; source: root.asset("pipe_joint_blue.png") }
        PipeImage { x: 267; y: 154; width: 34; height: 56; source: root.asset("pipe_meter.png") }
        PipeImage { x: 91; y: 324; width: 40; height: 40; source: root.asset("pipe_sdv_closed.png"); clickable: true }
        PipeImage { x: 109; y: 434; width: 30; height: 30; source: root.asset("pipe_joint_red.png") }
        PipeImage { x: 242; y: 540; width: 81; height: 28; source: root.asset("pipe_valve.png"); clickable: true }
        PipeImage { x: 241; y: 344; width: 81; height: 28; source: root.asset("pipe_valve.png"); clickable: true }
        PipeImage { x: 710; y: 329; width: 14; height: 115; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 791; y: 394; width: 31; height: 56; source: root.asset("pipe_actuator.png"); clickable: true }
        PipeImage { x: 709; y: 301; width: 30; height: 30; source: root.asset("pipe_elbow.png"); rotation: 180 }
        PipeImage { x: 875; y: 300; width: 30; height: 30; source: root.asset("pipe_joint_blue.png") }
        PipeImage { x: 785; y: 301; width: 48; height: 50; source: root.asset("pipe_vibration.png"); clickable: true }
        PipeImage { x: 821; y: 300; width: 54; height: 14; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 739; y: 301; width: 58; height: 14; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 127; y: 287; width: 81; height: 28; source: root.asset("pipe_valve.png"); clickable: true }
        PipeImage { x: 1242; y: 394; width: 31; height: 56; source: root.asset("pipe_actuator.png"); clickable: true }
        PipeImage { x: 1066; y: 329; width: 14; height: 54; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 1065; y: 301; width: 30; height: 30; source: root.asset("pipe_elbow.png"); rotation: 180 }
        PipeImage { x: 1095; y: 301; width: 58; height: 14; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 1000; y: 377; width: 195; height: 122; source: root.asset("pipe_separator.png") }
        PipeImage { x: 447; y: 581; width: 30; height: 30; source: root.asset("pipe_elbow.png") }
        PipeImage { x: 447; y: 304; width: 30; height: 30; source: root.asset("pipe_joint_blue.png") }
        PipeImage { x: 411; y: 209; width: 152; height: 15; source: root.asset("pipe_horizontal.png") }
        PipeImage { x: 557; y: 209; width: 30; height: 30; source: root.asset("pipe_joint_blue.png") }
        PipeImage { x: 194; y: 312; width: 16; height: 140; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 194; y: 230; width: 16; height: 60; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 308; y: 331; width: 15; height: 16; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 307; y: 369; width: 15; height: 76; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 308; y: 565; width: 15; height: 17; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 308; y: 581; width: 30; height: 30; source: root.asset("pipe_elbow.png"); rotation: 90 }
        PipeImage { x: 444; y: 495; width: 40; height: 40; source: root.asset("pipe_sdv_closed.png"); clickable: true }
        PipeImage { x: 443; y: 360; width: 40; height: 40; source: root.asset("pipe_sdv_closed.png"); clickable: true }
        PipeImage { x: 551; y: 317; width: 40; height: 40; source: root.asset("pipe_sdv_closed.png"); clickable: true }
        PipeImage { x: 376; y: 433; width: 40; height: 40; source: root.asset("pipe_sdv_open.png"); clickable: true }
        PipeImage { x: 53; y: 99; width: 34; height: 70; source: root.asset("pipe_meter.png"); rotation: 90 }
        PipeImage { x: 242; y: 394; width: 31; height: 56; source: root.asset("pipe_meter.png") }
        PipeImage { x: 506; y: 397; width: 32; height: 56; source: root.asset("pipe_meter.png") }
        PipeImage { x: 185; y: 442; width: 30; height: 30; source: root.asset("pipe_sensor.png") }
        PipeImage { x: 453; y: 442; width: 30; height: 30; source: root.asset("pipe_sensor.png") }
        PipeImage { x: 564; y: 439; width: 30; height: 30; source: root.asset("pipe_sensor.png") }
        PipeImage { x: 185; y: 201; width: 30; height: 30; source: root.asset("pipe_sensor.png") }
        PipeImage { x: 700; y: 442; width: 30; height: 30; source: root.asset("pipe_sensor.png") }
        PipeImage { x: 308; y: 303; width: 30; height: 30; source: root.asset("pipe_elbow.png"); rotation: 180 }

        Readout { x: 248; y: 124; text: root.mainPressure }
        Readout { x: 486; y: 373; text: root.auxiliaryPressure }
        Readout { x: 49; y: 88; text: root.pipePressure }
        Readout { x: 222; y: 373; text: root.branchPressure }

        PipeImage { x: 308; y: 473; width: 15; height: 70; source: root.asset("pipe_vertical.png") }
        PipeImage { x: 300; y: 443; width: 30; height: 30; source: root.asset("pipe_sensor.png") }
        PipeImage { x: 9; y: 58; width: 50; height: 583; source: root.asset("pipe_well.png") }
        PipeImage { x: 880; y: 439; width: 30; height: 30; source: root.asset("pipe_sensor.png") }
        PipeImage { x: 870; y: 354; width: 40; height: 40; source: root.asset("pipe_sdv_closed.png"); clickable: true }
        PipeImage { x: 690; y: 356; width: 40; height: 40; source: root.asset("pipe_sdv_closed.png"); clickable: true }
        PipeImage { x: 379; y: 255; width: 45; height: 62; source: root.asset("pipe_choke.png") }
        PipeImage { x: 414; y: 303; width: 33; height: 16; source: root.asset("pipe_horizontal.png") }

    }

    component PipeImage: MosImage {
        property bool clickable: false

        smooth: true
        mipmap: true
        asynchronous: true
        fillMode: Image.Stretch
        previewEnabled: false
        hoverCursorShape: clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        transformOrigin: Item.Center

        MouseArea {
            anchors.fill: parent
            enabled: parent.clickable
            hoverEnabled: parent.clickable
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    component Readout: MosText {
        width: 100
        height: 25
        color: "white"
        font.family: "Microsoft YaHei"
        font.pixelSize: 20
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    component PanelIcon: MosButton {
        id: panelIcon

        property alias source: icon.source
        property real iconRotation: 0
        colorBorder : "#ff1d6597"

        width: 35
        height: 40
        padding: 0
        text: ""
        colorBg  : "#c0c0c0"
        radiusBg: MosRadius {all: 0}

        contentItem: MosImage {
            id: icon
            smooth: true
            mipmap: true
            fillMode: Image.PreserveAspectFit
            previewEnabled: false
            rotation: panelIcon.iconRotation
            transformOrigin: Item.Center
        }
    }

    component ValvePanel: Item {
        id: vp
        property string valveId
        property string title
        property string valueText
        property real frameX: 0
        property real frameY: 0
        property real frameWidth: 490
        property real frameHeight: 120
        property real progressX: 0
        property real progressWidth: 488
        property real progressHeight: 70
        property real progressY: 4
        property real fillX: 15
        property real fillY: 10
        property real fillWidth: {
            var num = parseFloat(valueText)
            return isNaN(num) ? 0 : (progressWidth - 12) * num / 100
        }
        property real fillHeight: 54
        property real controlsX: 0
        property real controlsY: 70
        property real controlsSpacing: 3
        property real rewindWidth: 35


        width: frameWidth
        height: frameHeight

        MosRectangle {
            x: parent.frameX
            y: parent.frameY
            width: parent.frameWidth
            height: parent.frameHeight
            color: "transparent"
            border.color: "#ff7a7474"
            border.width: 3
        }

        MosRectangle {
            x: parent.fillX
            y: parent.fillY
            width: parent.fillWidth
            height: parent.fillHeight
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#6f0d0d" }
                GradientStop { position: 1.0; color: "#a71111" }
            }
        }

        MosImage {
            x: parent.progressX
            y: parent.progressY
            width: parent.progressWidth
            height: parent.progressHeight
            source: root.asset("pipe_progress.png")
            smooth: true
            mipmap: true
            fillMode: Image.Stretch
            previewEnabled: false
            hoverCursorShape: Qt.ArrowCursor
        }
        ValveSettingPopup {
            id: valvesetPopup
            x: -10
            y: frameHeight + 5
            width: parent.frameWidth * parent.parent.scale
            valveId: parent.valveId
        }

        Row {
            x: parent.controlsX
            y: parent.controlsY
            height: 40
            spacing: parent.controlsSpacing

            MosText {
                width: 108
                height: 40
                text: parent.parent.title
                color: "white"
                font.family: "Microsoft YaHei"
                font.pixelSize: 30
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            PanelIcon {
                id: valveSetting
                source: root.asset("pipe_setting.png")
                onClicked: {
                    valvesetPopup.open()
                }
            }
            PanelIcon {
                source: root.asset("pipe_auto.png")
                onClicked: vp.autoClicked()
            }
            PanelIcon {
                source: root.asset("pipe_cv.png")
                onClicked: vp.cvClicked()
            }
            PanelIcon {
                width: parent.parent.rewindWidth
                source: root.asset("pipe_rewind.png")
                onClicked: vp.adjustClicked(1)
            }
            PanelIcon {
                source: root.asset("pipe_forward.png")
                onClicked: vp.adjustClicked(2)
            }
            PanelIcon {
                source: root.asset("pipe_slow.png")
                iconRotation: 180
                onClicked: vp.adjustClicked(3)
            }
            MosText {
                width: 100
                height: 40
                text: parent.parent.valueText
                color: "white"
                font.family: "Microsoft YaHei"
                font.pixelSize: 28
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            PanelIcon {
                source: root.asset("pipe_slow.png")
                onClicked: vp.adjustClicked(4)
            }
       
        }
    }
    component ValveSettingPopup: MosPopover {
        id: popup
        property string valveId: ""
        property real sliderValue: 0
        signal valueConfirmed(real value)

        width: 280
        colorBg: 'transparent'
        closePolicy: MosPopover.CloseOnPressOutside | MosPopover.CloseOnEscape

        contentDelegate: Item {
            implicitHeight: footerLoader.implicitHeight

            Loader {
                id: footerLoader
                anchors.fill: parent
                sourceComponent: popup.footerDelegate
            }
        }

        footerDelegate: Item {
            implicitWidth: 280
            implicitHeight: 20

            MosSlider {
                id: valveSlider
                anchors.centerIn: parent
                width: parent.width - 24
                height: 30
                min: 0
                max: 100
                stepSize: 1
                value: popup.sliderValue
                onFirstMoved: popup.sliderValue = currentValue
            }
        }
    }
}

