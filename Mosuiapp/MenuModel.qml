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
            iconSource: MosIcon.UniversalOutlined,
            menuChildren: [
                {
                    key: 'ExpMosButton',
                    label: qsTr('按钮'),
                    iconSource: MosIcon.ButtonOutlined,
                    source: './Controls/Universal/ExpMosButton.qml',
                    addVersion: '0.0.1',
                },
                {
                    key: 'ExpMosButtonBlock',
                    label: qsTr('按钮块'),
                    iconSource: MosIcon.ButtonOutlined,
                    source: './Controls/Universal/ExpMosButtonBlock.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpMosCaptionbar',
                    label: qsTr('标题栏'),
                    iconSource: MosIcon.CaptionbarOutlined,
                    source: './Controls/Universal/ExpMosCaptionbar.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpMosCaptionButton',
                    label: qsTr('标题按钮'),
                    iconSource: MosIcon.CaptionbarOutlined,
                    source: './Controls/Universal/ExpMosCaptionButton.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpCopyableText',
                    label: qsTr('可复制文本'),
                    iconSource: MosIcon.CopyOutlined,
                    source: './Controls/Universal/ExpCopyableText.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpCanvasChart',
                    label: qsTr('Canvas图表'),
                    iconSource: MosIcon.ChartOutlined,
                    source: './Controls/Universal/ExpCanvasChart.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpMosHighperchart',
                    label: qsTr('Mos高性能图表'),
                    iconSource: MosIcon.ChartOutlined,
                    source: './Controls/Universal/ExpMosHighperchart.qml',
                    addVersion: '0.0.2',
                },
                {
                    key:'ExpSerialPortManager',
                    label:qsTr('串口管理器'),
                    iconSource: MosIcon.SerialPortOutlined,
                    source: './Controls/Universal/ExpSerialPortManager.qml',
                    addVersion: '0.0.2'
                },
                {
                    key:'ExpAnimatedImage',
                    label:qsTr('动画图片'),
                    iconSource: MosIcon.AnimatedImageOutlined,
                    source: './Controls/Universal/ExpAnimatedImage.qml',
                    addVersion: '0.0.3'
                },
                {
                    key:'ExpAvatar',
                    label:qsTr('头像'),
                    iconSource: MosIcon.AvatarOutlined,
                    source: './Controls/Universal/ExpAvatar.qml',
                    addVersion: '0.0.3'
                },
                {
                    key:'ExpBadge',
                    label:qsTr('徽标'),
                    iconSource: MosIcon.BadgeOutlined,
                    source: './Controls/Universal/ExpBadge.qml',
                    addVersion: '0.0.3'
                }
            ]
        },
        {
            key: 'Tools',
            label: qsTr('Mos工具'),
            iconSource: MosIcon.ToolsOutlined,
            source: './Tools/MosTools.qml',
            menuChildren: [
                {
                    key: 'TPInv',
                    label: qsTr('逆变器工具'),
                    iconSource: MosIcon.ToolsOutlined,
                    source: './Tools/TPInv/TPInvWord.qml',
                    addVersion: '0.0.1',
                },
                {
                    key: 'PLC_APP',
                    label: qsTr('PLC_APP 工具'),
                    iconSource: MosIcon.ToolsOutlined,
                    source: './Tools/PLC_APP/PLC_APPWord.qml',
                    addVersion: '0.0.1',
                }
   
            ]
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
 