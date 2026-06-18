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
# MosInput 输入框 \n
通过鼠标或键盘输入内容，是最基础的表单域的包装。\n
* **模块 { MosuiBasic.Basic }**\n
* **继承自 { TextField }**\n
* **继承此 { [MosDateTimePicker](internal://MosDateTimePicker), [MosAutoComplete](internal://MosAutoComplete) }**\n
\n<br/>
\n### 支持的代理：\n
- **iconDelegate: Component** 图标代理\n
- **clearIconDelegate: Component** 清除图标代理\n
- **bgDelegate: Component** 背景代理\n
\n<br/>
\n### 支持的属性：\n
属性名 | 类型 | 默认值 | 描述
------ | --- | :---: | ---
animationEnabled | bool | MosTheme.animationEnabled | 是否开启动画
active | bool | - | 是否处于激活状态
showShadow | bool | false | 是否显示阴影
type | enum | MosInput.Type_Outlined | 输入框形态类型(来自 MosInput)
iconSource | int丨string | 0丨'' | 图标源(来自 MosIcon)或图标链接
iconSize | int | - | 图标大小
iconPosition | enum | MosInput.Position_Left | 图标位置(来自 MosInput)
clearEnabled | bool丨'active' | false | 是否启用清除按钮(active-仅当激活状态下可见)
clearIconSource | int丨string | MosIcon.CloseCircleFilled | 清除图标源(来自 MosIcon)或图标链接
clearIconSize | int | - | 清除图标大小
clearIconPosition | enum | MosInput.Position_Right | 清除图标位置(来自 MosInput)
leftIconPadding | int(readonly) | - | 图标在左边时的填充
rightIconPadding | int(readonly) | - | 图标在右边时的填充
leftClearIconPadding | int(readonly) | - | 清除图标在左边时的填充
rightClearIconPadding | int(readonly) | - | 清除图标在右边时的填充
colorIcon | color | - | 图标颜色
colorText | color | - | 文本颜色
colorBorder | color | - | 边框颜色
colorBg | color | - | 背景颜色
colorShadow | color | - | 阴影颜色
radiusBg | [MosRadius](internal://MosRadius) | - | 背景圆角
sizeHint | string | 'normal' | 尺寸提示
contentDescription | string | '' | 内容描述(提高可用性)
\n<br/>
\n### 支持的信号：\n
- \`clickClear()\` 点击清除图标时发出\n
                       `)
        }

        MosDescription {
            title: qsTr('何时使用')
            desc: qsTr(`
- 需要用户输入表单域内容时。\n
- 提供组合型输入框，带搜索的输入框，还可以进行大小选择。\n
                       `)
        }


        MosDescription {
            title: qsTr('代码演示')
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`iconSource\` 属性设置图标源，为 0 则不显示。\n
通过 \`iconSize\` 设置清除图标大小。\n
通过 \`iconPosition\` 属性改变图标位置，支持的位置：\n
- 图标在输入框左边(默认){ MosInput.Position_Left }\n
- 图标在输入框右边{ MosInput.Position_Right }\n
通过 \`clearEnabled\` 设置是否启用清除按钮。\n
通过 \`clearIconSource\` 设置清除图标，为 0 则不显示。\n
通过 \`clearIconSize\` 设置清除图标大小。\n
通过 \`clearIconPosition\` 设置清除图标的位置，支持的位置：\n
- 清除图标在输入框左边(默认){ MosInput.Position_Left }\n
- 清除图标在输入框右边{ MosInput.Position_Right }\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosInput {
                        width: 150
                        placeholderText: 'Basic Usage'
                    }

                    MosInput {
                        width: 150
                        placeholderText: 'Clear Active'
                        clearEnabled: 'active'
                    }

                    MosInput {
                        width: 150
                        iconPosition: MosInput.Position_Left
                        iconSource: MosIcon.UserOutlined
                        placeholderText: 'Username'
                    }

                    MosInput {
                        width: 150
                        iconPosition: MosInput.Position_Right
                        iconSource: MosIcon.UserOutlined
                        placeholderText: 'Username'
                    }

                    MosInput {
                        width: 150
                        iconPosition: MosInput.Position_Left
                        iconSource: MosIcon.UserOutlined
                        clearEnabled: true
                        clearIconPosition: MosInput.Position_Left
                        placeholderText: 'Username'
                    }

                    MosInput {
                        width: 150
                        iconPosition: MosInput.Position_Right
                        iconSource: MosIcon.UserOutlined
                        clearEnabled: true
                        clearIconPosition: MosInput.Position_Right
                        placeholderText: 'Username'
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosInput {
                    width: 150
                    placeholderText: 'Basic Usage'
                }

                MosInput {
                    width: 150
                    placeholderText: 'Clear Active'
                    clearEnabled: 'active'
                }

                MosInput {
                    width: 150
                    iconPosition: MosInput.Position_Left
                    iconSource: MosIcon.UserOutlined
                    placeholderText: 'Username'
                }

                MosInput {
                    width: 150
                    iconPosition: MosInput.Position_Right
                    iconSource: MosIcon.UserOutlined
                    placeholderText: 'Username'
                }

                MosInput {
                    width: 150
                    iconPosition: MosInput.Position_Left
                    iconSource: MosIcon.UserOutlined
                    clearEnabled: true
                    clearIconPosition: MosInput.Position_Left
                    placeholderText: 'Username'
                }

                MosInput {
                    width: 150
                    iconPosition: MosInput.Position_Right
                    iconSource: MosIcon.UserOutlined
                    clearEnabled: true
                    clearIconPosition: MosInput.Position_Right
                    placeholderText: 'Username'
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`showShadow\` 属性设置是否显示阴影。\n
通过 \`type\` 属性设置输入框形态类型，支持的类型：\n
- 实线框(默认){ MosInput.Type_Outlined }\n
- 虚线框{ MosInput.Type_Dashed }\n
- 无边框{ MosInput.Type_Borderless }\n
- 下划线{ MosInput.Type_Underlined }\n
- 填充框{ MosInput.Type_Filled }\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosSwitch {
                        id: shadowSwitch
                        checked: false
                        text: 'Show shadow: '
                    }

                    MosInput {
                        width: 150
                        type: MosInput.Type_Outlined
                        placeholderText: 'Outlined'
                        showShadow: shadowSwitch.checked
                    }

                    MosInput {
                        width: 150
                        type: MosInput.Type_Dashed
                        placeholderText: 'Dashed'
                        showShadow: shadowSwitch.checked
                    }

                    MosInput {
                        width: 150
                        type: MosInput.Type_Borderless
                        placeholderText: 'Borderless'
                        showShadow: shadowSwitch.checked
                    }

                    MosInput {
                        width: 150
                        type: MosInput.Type_Underlined
                        placeholderText: 'Underlined'
                        showShadow: shadowSwitch.checked
                    }

                    MosInput {
                        width: 150
                        type: MosInput.Type_Filled
                        placeholderText: 'Filled'
                        showShadow: shadowSwitch.checked
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosSwitch {
                    id: shadowSwitch
                    checked: false
                    text: 'Show shadow: '
                }

                MosInput {
                    width: 150
                    type: MosInput.Type_Outlined
                    placeholderText: 'Outlined'
                    showShadow: shadowSwitch.checked
                }

                MosInput {
                    width: 150
                    type: MosInput.Type_Dashed
                    placeholderText: 'Dashed'
                    showShadow: shadowSwitch.checked
                }

                MosInput {
                    width: 150
                    type: MosInput.Type_Borderless
                    placeholderText: 'Borderless'
                    showShadow: shadowSwitch.checked
                }

                MosInput {
                    width: 150
                    type: MosInput.Type_Underlined
                    placeholderText: 'Underlined'
                    showShadow: shadowSwitch.checked
                }

                MosInput {
                    width: 150
                    type: MosInput.Type_Filled
                    placeholderText: 'Filled'
                    showShadow: shadowSwitch.checked
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
通过 \`sizeHint\` 属性设置尺寸。\n
通过 \`echoMode\` 属性实现密码框。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                Column {
                    spacing: 10

                    MosRadioBlock {
                        id: sizeHintRadio
                        initCheckedIndex: 1
                        model: [
                            { label: 'Small', value: 'small' },
                            { label: 'Normal', value: 'normal' },
                            { label: 'Large', value: 'large' },
                        ]
                    }

                    MosInput {
                        width: 150
                        iconPosition: MosInput.Position_Left
                        iconSource: MosIcon.UserOutlined
                        placeholderText: 'Username'
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }

                    MosInput {
                        id: passwordInput
                        width: 150
                        iconPosition: MosInput.Position_Right
                        iconSource: echoMode === MosInput.Password ? MosIcon.EyeInvisibleOutlined :
                                                                     MosIcon.EyeOutlined
                        iconDelegate: MosIconButton {
                            padding: 0
                            rightPadding: 10 * passwordInput.sizeRatio
                            effectEnabled: false
                            type: MosButton.Type_Link
                            iconSize: passwordInput.iconSize
                            iconSource: passwordInput.iconSource
                            onClicked: {
                                if (passwordInput.echoMode === MosInput.Password) {
                                    passwordInput.echoMode = MosInput.Normal;
                                } else {
                                    passwordInput.echoMode = MosInput.Password;
                                }
                            }
                        }
                        placeholderText: 'Password'
                        sizeHint: sizeHintRadio.currentCheckedValue
                    }
                }
            `
            exampleDelegate: Column {
                spacing: 10

                MosRadioBlock {
                    id: sizeHintRadio
                    initCheckedIndex: 1
                    model: [
                        { label: 'Small', value: 'small' },
                        { label: 'Normal', value: 'normal' },
                        { label: 'Large', value: 'large' },
                    ]
                }

                MosInput {
                    width: 150
                    iconPosition: MosInput.Position_Left
                    iconSource: MosIcon.UserOutlined
                    placeholderText: 'Username'
                    sizeHint: sizeHintRadio.currentCheckedValue
                }

                MosInput {
                    id: passwordInput
                    width: 150
                    iconPosition: MosInput.Position_Right
                    iconSource: echoMode === MosInput.Password ? MosIcon.EyeInvisibleOutlined :
                                                                 MosIcon.EyeOutlined
                    iconDelegate: MosIconButton {
                        padding: 0
                        rightPadding: 10 * passwordInput.sizeRatio
                        effectEnabled: false
                        type: MosButton.Type_Link
                        iconSize: passwordInput.iconSize
                        iconSource: passwordInput.iconSource
                        onClicked: {
                            if (passwordInput.echoMode === MosInput.Password) {
                                passwordInput.echoMode = MosInput.Normal;
                            } else {
                                passwordInput.echoMode = MosInput.Password;
                            }
                        }
                    }
                    placeholderText: 'Password'
                    sizeHint: sizeHintRadio.currentCheckedValue
                }
            }
        }

        CodeBox {
            width: parent.width
            desc: qsTr(`
组合其他组件。\n
                       `)
            code: `
                import QtQuick
                import MosuiBasic

                MosSpace {
                    layout: 'Row'

                    MosInput {
                        id: input
                        width: 250
                        text: 'Combine input and button'
                    }

                    MosIconButton {
                        type: MosButton.Type_Primary
                        text: 'Submit'
                        loading: true
                    }
                }
            `
            exampleDelegate: MosSpace {
                layout: 'Row'

                MosInput {
                    id: input
                    width: 250
                    text: 'Combine input and button'
                }

                MosIconButton {
                    type: MosButton.Type_Primary
                    text: 'Submit'
                    loading: true
                }
            }
        }
    }
}
