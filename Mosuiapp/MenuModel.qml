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
                    label: qsTr('MosButton 按钮'),
                    iconSource: MosIcon.ButtonOutlined,
                    source: './Controls/Universal/ExpMosButton.qml',
                    addVersion: '0.0.1',
                },
                {
                    key: 'ExpMosButtonBlock',
                    label: qsTr('MosButtonBlock 按钮块'),
                    iconSource: MosIcon.ButtonOutlined,
                    source: './Controls/Universal/ExpMosButtonBlock.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpMosCaptionbar',
                    label: qsTr('MosCaptionbar 标题栏'),
                    iconSource: MosIcon.CaptionbarOutlined,
                    source: './Controls/Universal/ExpMosCaptionbar.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpMosCaptionButton',
                    label: qsTr('MosCaptionButton 标题按钮'),
                    iconSource: MosIcon.CaptionbarOutlined,
                    source: './Controls/Universal/ExpMosCaptionButton.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpCopyableText',
                    label: qsTr('MosCopyableText 可复制文本'),
                    iconSource: MosIcon.CopyOutlined,
                    source: './Controls/Universal/ExpCopyableText.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpCanvasChart',
                    label: qsTr('MosCanvasChart 图表'),
                    iconSource: MosIcon.ChartOutlined,
                    source: './Controls/Universal/ExpCanvasChart.qml',
                    addVersion: '0.0.2',
                },
                {
                    key: 'ExpMosHighperchart',
                    label: qsTr('MosHighperchart 图表'),
                    iconSource: MosIcon.ChartOutlined,
                    source: './Controls/Universal/ExpMosHighperchart.qml',
                    addVersion: '0.0.2',
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
 