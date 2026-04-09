// MosShadow.qml
import QtQuick
import QtQuick.Layouts
import MosuiBasic
import QtQuick.Effects
MultiEffect {
    shadowEnabled: true
    shadowColor: MosTheme.Primary.colorTextBase
    shadowOpacity: MosTheme.isDark ? 0.3 : 0.2
    shadowScale: MosTheme.isDark ? 1.03 : 1.02
}