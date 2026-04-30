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
            key: 'HomePage',
            label: qsTr('首页'),
            iconSource: MosIcon.HomeOutlined,
            source: './Controls/HomePage.qml',
        },
        {
            key: 'Universal',
            label: qsTr('通用控件'),
            // iconSource: MosIcon.UniversalOutlined,
            menuChildren: [
                {
                    key: 'ExpMosButton',
                    label: qsTr('MosButton 按钮'),
                    // iconSource: MosIcon.ButtonOutlined,
                    source: './Controls/Universal/ExpMosButton.qml',
                    addVersion: '0.0.1',
                },
            ]
        },

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
 