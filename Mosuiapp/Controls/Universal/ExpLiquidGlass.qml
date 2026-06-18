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

        MosDescription {
            desc: qsTr(`
# MosLiquidGlass 液态玻璃 \n
液态玻璃/折射效果，灵感来源于 Apple WWDC 2025 液态玻璃 (Liquid Glass) 设计风格。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { Item }**\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
sourceItem | Item | - | 源项目
sourceRect | rect | - | 源矩形大小
refraction | real | 0.026 | 折射强度
bevelDepth | real | 0.119 | 斜面深度
bevelWidth | real | 0.057 | 斜面宽度
animated | bool | true | 是否启用动态高光
frost | real | 0.0 | 磨砂程度
specularIntensity | real | 1.0 | 高光强度
tiltX | real | 0.0 | 水平倾斜角度
tiltY | real | 0.0 | 垂直倾斜角度
magnify | real | 1.0 | 放大倍数
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
当用户需要实现类似液态玻璃的折射/磨砂效果时。
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`sourceItem\` 属性设置需要该效果的项目，**注意** \`MosLiquidGlass\` 不能为 \`sourceItem\` 的子项。\n
通过 \`refraction\` 控制折射强度，\`frost\` 控制磨砂程度。\n
通过 \`bevelDepth\` / \`bevelWidth\` 控制边缘斜面效果。\n
通过 \`specularIntensity\` 控制镜面高光强度。\n
通过 \`tiltX\` / \`tiltY\` 模拟倾斜折射。\n
通过 \`magnify\` 控制放大缩小。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {

                    MosSlider {
                        id: refractionSlider
                        width: 200; height: 30
                        min: 0.0; max: 0.1; stepSize: 0.01; value: 0.1
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('折射: ') + parent.currentValue.toFixed(3)
                        }
                    }

                    MosSlider {
                        id: frostSlider
                        width: 200; height: 30
                        min: 0.0; max: 10.0; stepSize: 0.1; value: 0.2
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('磨砂: ') + parent.currentValue.toFixed(1)
                        }
                    }

                    MosSlider {
                        id: bevelDepthSlider
                        width: 200; height: 30
                        min: 0.0; max: 0.5; stepSize: 0.01; value: 0.1
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('斜面深度: ') + parent.currentValue.toFixed(2)
                        }
                    }

                    MosSlider {
                        id: bevelWidthSlider
                        width: 200; height: 30
                        min: 0.0; max: 0.5; stepSize: 0.01; value: 0.1
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('斜面宽度: ') + parent.currentValue.toFixed(2)
                        }
                    }

                    MosSlider {
                        id: specularSlider
                        width: 200; height: 30
                        min: 0.0; max: 2.0; stepSize: 0.1; value: 1.0
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('高光: ') + parent.currentValue.toFixed(1)
                        }
                    }

                    MosSlider {
                        id: radiusSlider
                        width: 200; height: 30
                        min: 0; max: 80; stepSize: 1; value: 30
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('圆角: ') + parent.currentValue.toFixed(0)
                        }
                    }

                    MosSlider {
                        id: tiltXSlider
                        width: 200; height: 30
                        min: -45; max: 45; stepSize: 1; value: 0
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('水平倾斜: ') + parent.currentValue.toFixed(0) + '°'
                        }
                    }

                    MosSlider {
                        id: tiltYSlider
                        width: 200; height: 30
                        min: -45; max: 45; stepSize: 1; value: 0
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('垂直倾斜: ') + parent.currentValue.toFixed(0) + '°'
                        }
                    }

                    MosSlider {
                        id: magnifySlider
                        width: 200; height: 30
                        min: 0.5; max: 3.0; stepSize: 0.05; value: 1.25
                        MosCopyableText {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.right; anchors.leftMargin: 10
                            text: qsTr('放大: ') + parent.currentValue.toFixed(2) + 'x'
                        }
                    }

                    Rectangle {
                        width: 600; height: 400
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: 'transparent'
                        border.color: MosTheme.Primary.colorTextBase

                        Rectangle {
                            id: source
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: '#667eea' }
                                GradientStop { position: 0.5; color: '#764ba2' }
                                GradientStop { position: 1.0; color: '#f093fb' }
                            }
                        }

                        MosLiquidGlass {
                            x: (source.width - width) * 0.5
                            y: (source.height - height) * 0.5
                            width: 200; height: 200
                            sourceItem: source
                            refraction: refractionSlider.currentValue
                            frost: frostSlider.currentValue
                            bevelDepth: bevelDepthSlider.currentValue
                            bevelWidth: bevelWidthSlider.currentValue
                            radiusBg: MosRadius { all: radiusSlider.currentValue }
                            tiltX: tiltXSlider.currentValue
                            tiltY: tiltYSlider.currentValue
                            magnify: magnifySlider.currentValue

                            MosResizeMouseArea {
                                target: parent
                                movable: true
                                preventStealing: true
                                minimumWidth: 100
                                minimumHeight: 30
                                minimumX: source.x
                                maximumX: source.x + source.width - parent.width
                                minimumY: source.y
                                maximumY: source.y + source.height - parent.height
                            }
                        }
                    }
                }
            `
            exampleDelegate: Column {

                MosSlider {
                    id: refractionSlider
                    width: 200; height: 30
                    min: 0.0; max: 0.1; stepSize: 0.01; value: 0.1
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('折射: ') + parent.currentValue.toFixed(3)
                    }
                }

                MosSlider {
                    id: frostSlider
                    width: 200; height: 30
                    min: 0.0; max: 10.0; stepSize: 0.1; value: 0.2
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('磨砂: ') + parent.currentValue.toFixed(1)
                    }
                }

                MosSlider {
                    id: bevelDepthSlider
                    width: 200; height: 30
                    min: 0.0; max: 0.5; stepSize: 0.01; value: 0.1
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('斜面深度: ') + parent.currentValue.toFixed(2)
                    }
                }

                MosSlider {
                    id: bevelWidthSlider
                    width: 200; height: 30
                    min: 0.0; max: 0.5; stepSize: 0.01; value: 0.1
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('斜面宽度: ') + parent.currentValue.toFixed(2)
                    }
                }

                MosSlider {
                    id: specularSlider
                    width: 200; height: 30
                    min: 0.0; max: 2.0; stepSize: 0.1; value: 1.0
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('高光: ') + parent.currentValue.toFixed(1)
                    }
                }

                MosSlider {
                    id: radiusSlider
                    width: 200; height: 30
                    min: 0; max: 80; stepSize: 1; value: 30
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('圆角: ') + parent.currentValue.toFixed(0)
                    }
                }

                MosSlider {
                    id: tiltXSlider
                    width: 200; height: 30
                    min: -45; max: 45; stepSize: 1; value: 0
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('水平倾斜: ') + parent.currentValue.toFixed(0) + '°'
                    }
                }

                MosSlider {
                    id: tiltYSlider
                    width: 200; height: 30
                    min: -45; max: 45; stepSize: 1; value: 0
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('垂直倾斜: ') + parent.currentValue.toFixed(0) + '°'
                    }
                }

                MosSlider {
                    id: magnifySlider
                    width: 200; height: 30
                    min: 0.5; max: 3.0; stepSize: 0.05; value: 1.25
                    MosCopyableText {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right; anchors.leftMargin: 10
                        text: qsTr('放大: ') + parent.currentValue.toFixed(2) + 'x'
                    }
                }

                Rectangle {
                    width: 600; height: 400
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: 'transparent'
                    border.color: MosTheme.Primary.colorTextBase

                    Rectangle {
                        id: source
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: '#667eea' }
                            GradientStop { position: 0.5; color: '#764ba2' }
                            GradientStop { position: 1.0; color: '#f093fb' }
                        }
                    }

                    MosLiquidGlass {
                        x: (source.width - width) * 0.5
                        y: (source.height - height) * 0.5
                        width: 200; height: 200
                        sourceItem: source
                        refraction: refractionSlider.currentValue
                        frost: frostSlider.currentValue
                        bevelDepth: bevelDepthSlider.currentValue
                        bevelWidth: bevelWidthSlider.currentValue
                        specularIntensity: specularSlider.currentValue
                        radiusBg: MosRadius { all: radiusSlider.currentValue }
                        tiltX: tiltXSlider.currentValue
                        tiltY: tiltYSlider.currentValue
                        magnify: magnifySlider.currentValue

                        MosResizeMouseArea {
                            target: parent
                            movable: true
                            preventStealing: true
                            minimumWidth: 100
                            minimumHeight: 30
                            minimumX: source.x
                            maximumX: source.x + source.width - parent.width
                            minimumY: source.y
                            maximumY: source.y + source.height - parent.height
                        }
                    }
                }
            }
        }
    }
}
