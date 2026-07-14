import QtQuick
import QtQuick.Layouts
import MosuiBasic

Item {
    id: root
    implicitHeight: 100

    property string expertPassword: ""
    MosRectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: MosTheme.Primary.colorSplit
        border.width: 1
    }

    MosSpace {
        anchors.fill: parent
        layout: 'RowLayout'
        spacing: 0
        // Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        // 节流阀区域
        MosFrame{
            Layout.horizontalStretchFactor: 0
            Layout.fillWidth: true
            Layout.minimumWidth: 410
            Layout.preferredWidth: 430
            Layout.fillHeight: true
            Layout.preferredHeight: root.height
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            borderWidth: 1
            padding: 10
            MosSpace{
                layout: 'RowLayout'
                spacing: 10
                anchors.fill: parent
                Repeater{
                    model: K3data.k3data_down
                    delegate: MosLabel{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumWidth: 120
                        Layout.preferredWidth: 130
                        text: modelData.name + "\n" + modelData.value
                        font.pixelSize: 16
                        colorText: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        MosFrame{
            Layout.horizontalStretchFactor: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: root.height
            colorBg: "transparent"
            colorBorder: MosTheme.Primary.colorSplit
            borderWidth: 1
            padding: 10
            MosSpace{
                layout: 'RowLayout'
                spacing: 4
                anchors.fill: parent
                Repeater{
                    model: [
                        {name: K3data.flag_auto_hand ? "自动模式" : "手动模式", color: "#FFFFC738"},
                        {name: K3data.flag_model_downhole ? "井底压力模式（打开）" : "井底压力模式（关闭）", color: "white"},
                        {name: K3data.flag_model_ground ? "井口压力模式（打开）" : "井口压力模式（关闭）", color: "white"},
                        {name: K3data.flag_model_mainsecond ? "主备阀模式切换（打开）" : "主备阀模式切换（关闭）", color: "white"},
                        {name: K3data.flag_model_profession ? "专家模式（打开）" : "专家模式（关闭）", color: "white"},
                        {name: K3data.flag_stop ? "停车（已停车）" : "停车（运行中）", color: "white"},
                        {name: K3data.flag_board ? "切换控制板（板A）" : "切换控制板（板B）", color: "white"}
                    ]
                    delegate: MosButton{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: modelData.name
                        colorText: modelData.color
                        onClicked: {
                            switch(index)
                            {
                                case 0: K3dataprocess.Flag_Auto_Hand(); break;
                                case 1: K3dataprocess.Flag_Model_Downhole(); break;
                                case 2: K3dataprocess.Flag_Model_Ground(); break;
                                case 3: K3dataprocess.Flag_Model_Mainsecond(); break;
                                case 4: {
                                    if(K3data.flag_model_profession) {
                                        // 已打开，直接关闭
                                        K3dataprocess.Flag_Model_Profession();
                                    } else {
                                        // 需要密码才能开启
                                        passwordDialog.open();
                                    }
                                    break;
                                }
                                case 5: K3dataprocess.Flag_Stop(); break;
                                case 6: K3dataprocess.Flag_Board(); break;
                            }
                        }
                    }
                }
            }
        }
    }

    // 专家模式密码对话框
    MosModal {
        id: passwordDialog
        title: "专家模式"
        description: "请输入专家模式密码："
        confirmText: "确定"
        cancelText: "取消"

        bodyDelegate: RowLayout {
            MosLabel {
                Layout.alignment: Qt.AlignVCenter
                text: passwordDialog.description
                colorText: passwordDialog.colorDescription
            }
            MosInput {
                id: passwordField
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "请输入密码"
                onTextChanged: root.expertPassword = text
            }
        }

        confirmButtonDelegate: MosButton {
            text: passwordDialog.confirmText
            type: MosButton.Type_Primary
            onClicked: {
                if(K3dataprocess.checkProfessionPassword(root.expertPassword)) {
                    K3dataprocess.Flag_Model_Profession();
                }
                root.expertPassword = "";
                passwordDialog.close();
            }
        }

        cancelButtonDelegate: MosButton {
            text: passwordDialog.cancelText
            type: MosButton.Type_Default
            onClicked: {
                root.expertPassword = "";
                passwordDialog.close();
            }
        }
    }
}
