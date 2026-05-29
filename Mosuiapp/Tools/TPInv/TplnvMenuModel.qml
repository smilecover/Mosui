import QtQuick
import MosuiBasic
QtObject{
    id: root
    objectName: '__MenuModel__'
    property var menus: []
    property var options: []
    property var updates: []

    property var galleryModel: [
        {
            key: 'TPInvhome',
            label: qsTr('首页'),
            iconSource: MosIcon.HomeOutlined,
            source: './TPinvPage/TPInvhome.qml',
        },
        {
            key: 'TPInvSerialport',
            label: qsTr('串口助手'),
            iconSource: MosIcon.SerialportOutlined,
            source: './TPinvPage/TPInvSerialport.qml',
        },
        {
            key: 'TPInvfault',
            label: qsTr('故障查询'),
            iconSource: MosIcon.FaultOutlined,
            source: './TPinvPage/TPInvfault.qml',
        },
        {
            key: 'TPInvcontrol',
            label: qsTr('逆变器控制'),
            iconSource: MosIcon.ControlOutlined,
            source: './TPinvPage/TPInvcontrol.qml',
        },
        {
            key: 'TPInvwave',
            label: qsTr('在线示波器'),
            iconSource: MosIcon.WaveOutlined,
            source: './TPinvPage/TPInvwave.qml',
        },
        {
            key: 'TPLInvSamp',
            label: qsTr('线性校正'),
            iconSource: MosIcon.SettingsOutlined,
            source: './TPinvPage/TPLInvSamp.qml',
        }
       ]
    Component.onCompleted:{
        /*! 创建菜单等 */
        let __menus = [], __options = [], __updates = [];
        for (const item of galleryModel) {
            if (item && item.menuChildren) {
                let hasNew = false;
                let hasUpdate = false;
                item.menuChildren.sort((a, b) => a.key.localeCompare(b.key));
                item.menuChildren.forEach(
                            object => {
                                object.state = object.addVersion ? 'New' : object.updateVersion ? 'Update' : '';
                                if (object.state) {
                                    if (object.state === 'New') hasNew = true;
                                    if (object.state === 'Update') hasUpdate = true;
                                }
                                if (object.label) {
                                    __options.push({
                                                       'key': object.key,
                                                       'value': object.key,
                                                       'label': object.label,
                                                       'state': object.state,
                                                   });
                                    __updates.push({
                                                       'name': object.key,
                                                       'desc': object.desc ?? '',
                                                       'tagState': object.state,
                                                       'version': object.addVersion || object.updateVersion || '',
                                                   });
                                }
                            });
                if (hasNew)
                    item.badgeState = 'New';
                else
                    item.badgeState = hasUpdate ? 'Update' : '';
            }
            __menus.push(item);
        } 
        menus = __menus;
        options = __options.sort((a, b) => a.key.localeCompare(b.key));
        updates = __updates.sort(
                    (a, b) => {
                        const parts1 = a.version.split('.').map(Number);
                        const parts2 = b.version.split('.').map(Number);
                        for (let i = 0; i < Math.max(parts1.length, parts2.length); i++) {
                            const num1 = parts1[i] || 0;
                            const num2 = parts2[i] || 0;

                            if (num1 > num2) return -1;
                            if (num1 < num2) return 1;
                        }
                        return 0;
                    });

    }
}
 
