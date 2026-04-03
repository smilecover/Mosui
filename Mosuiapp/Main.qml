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
    Button{
        text: "lianganqiehuan"
        anchors.centerIn: parent
        onClicked: {
            MosTheme.darkMode = MosTheme.isDark ? MosTheme.DarkMode.Light : MosTheme.DarkMode.Dark
            MosTheme.reloadTheme()  
        }
    }
}
