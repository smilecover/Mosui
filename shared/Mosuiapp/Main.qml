import QtQuick
import QtQuick.Controls
import MosuiBasic
MosWindow{
    id: root
    visible: true
    width: 1200
    height: 800
    color: MosTheme.Primary.colorBgBase
    title: "MosUI"
    MosButton{
        text: "lianganqiehuan"
        width: 100
        height: 30
        buttoncolor: MosTheme.MosButton.ButtonBgColor
        anchors.centerIn: parent
        onClicked: {
            MosTheme.darkMode = MosTheme.isDark ? MosTheme.DarkMode.Light : MosTheme.DarkMode.Dark
        }
    }

}
