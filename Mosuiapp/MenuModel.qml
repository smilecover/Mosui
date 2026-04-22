import QtQuick
import MosuiBasic
QtObject{
    id: root
    property var galleryModel: [
        {
            key: 'HomePage',
            label: qsTr('首页'),
            iconSource: MosIcon.HomeOutlined,
            source: './Controls/HomePage.qml'
        },

    ]
}
