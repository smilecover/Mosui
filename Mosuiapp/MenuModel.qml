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
                },
                {
                    key:'ExpMqttManager',
                    label:qsTr('MQTT管理器'),
                    iconSource: MosIcon.MqttOutlined,
                    source: './Controls/Universal/ExpMqttManager.qml',
                    addVersion: '0.0.4'
                },
                { key:'ExpAcrylic', label:qsTr('亚克力'), iconSource: MosIcon.BgColorsOutlined, source: './Controls/Universal/ExpAcrylic.qml', addVersion: '0.0.5' },
                { key:'ExpAutoComplete', label:qsTr('自动完成'), iconSource: MosIcon.SearchOutlined, source: './Controls/Universal/ExpAutoComplete.qml', addVersion: '0.0.5' },
                { key:'ExpBreadcrumb', label:qsTr('面包屑'), iconSource: MosIcon.RightOutlined, source: './Controls/Universal/ExpBreadcrumb.qml', addVersion: '0.0.5' },
                { key:'ExpCard', label:qsTr('卡片'), iconSource: MosIcon.IdcardOutlined, source: './Controls/Universal/ExpCard.qml', addVersion: '0.0.5' },
                { key:'ExpCarousel', label:qsTr('轮播图'), iconSource: MosIcon.PictureOutlined, source: './Controls/Universal/ExpCarousel.qml', addVersion: '0.0.5' },
                { key:'ExpCheckBox', label:qsTr('复选框'), iconSource: MosIcon.CheckSquareOutlined, source: './Controls/Universal/ExpCheckBox.qml', addVersion: '0.0.5' },
                { key:'ExpCheckerBoard', label:qsTr('棋盘格'), iconSource: MosIcon.AppstoreOutlined, source: './Controls/Universal/ExpCheckerBoard.qml', addVersion: '0.0.5' },
                { key:'ExpCollapse', label:qsTr('折叠面板'), iconSource: MosIcon.MenuUnfoldOutlined, source: './Controls/Universal/ExpCollapse.qml', addVersion: '0.0.5' },
                { key:'ExpColorPicker', label:qsTr('颜色选择'), iconSource: MosIcon.BgColorsOutlined, source: './Controls/Universal/ExpColorPicker.qml', addVersion: '0.0.5' },
                { key:'ExpColorPickerPanel', label:qsTr('颜色面板'), iconSource: MosIcon.BgColorsOutlined, source: './Controls/Universal/ExpColorPickerPanel.qml', addVersion: '0.0.5' },
                { key:'ExpDateTimePicker', label:qsTr('日期选择'), iconSource: MosIcon.CalendarOutlined, source: './Controls/Universal/ExpDateTimePicker.qml', addVersion: '0.0.5' },
                { key:'ExpDateTimePickerPanel', label:qsTr('日期面板'), iconSource: MosIcon.CalendarOutlined, source: './Controls/Universal/ExpDateTimePickerPanel.qml', addVersion: '0.0.5' },
                { key:'ExpDrawer', label:qsTr('抽屉'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpDrawer.qml', addVersion: '0.0.5' },
                { key:'ExpEmpty', label:qsTr('空状态'), iconSource: MosIcon.InboxOutlined, source: './Controls/Universal/ExpEmpty.qml', addVersion: '0.0.5' },
                { key:'ExpFrame', label:qsTr('框架'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpFrame.qml', addVersion: '0.0.5' },
                { key:'ExpImage', label:qsTr('图片'), iconSource: MosIcon.FileImageOutlined, source: './Controls/Universal/ExpImage.qml', addVersion: '0.0.5' },
                { key:'ExpInput', label:qsTr('输入框'), iconSource: MosIcon.EditOutlined, source: './Controls/Universal/ExpInput.qml', addVersion: '0.0.5' },
                { key:'ExpLabel', label:qsTr('标签文本'), iconSource: MosIcon.FontColorsOutlined, source: './Controls/Universal/ExpLabel.qml', addVersion: '0.0.5' },
                { key:'ExpLiquidGlass', label:qsTr('液态玻璃'), iconSource: MosIcon.EyeOutlined, source: './Controls/Universal/ExpLiquidGlass.qml', addVersion: '0.0.5' },
                { key:'ExpMenu', label:qsTr('菜单'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpMenu.qml', addVersion: '0.0.5' },
                { key:'ExpModal', label:qsTr('模态框'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpModal.qml', addVersion: '0.0.5' },
                { key:'ExpMultiCheckBox', label:qsTr('多选复选'), iconSource: MosIcon.CheckSquareOutlined, source: './Controls/Universal/ExpMultiCheckBox.qml', addVersion: '0.0.5' },
                { key:'ExpMultiSelect', label:qsTr('多选下拉'), iconSource: MosIcon.SelectOutlined, source: './Controls/Universal/ExpMultiSelect.qml', addVersion: '0.0.5' },
                { key:'ExpNotification', label:qsTr('通知'), iconSource: MosIcon.NotificationOutlined, source: './Controls/Universal/ExpNotification.qml', addVersion: '0.0.5' },
                { key:'ExpOTPInput', label:qsTr('验证码'), iconSource: MosIcon.SafetyOutlined, source: './Controls/Universal/ExpOTPInput.qml', addVersion: '0.0.5' },
                { key:'ExpPage', label:qsTr('页面'), iconSource: MosIcon.FileOutlined, source: './Controls/Universal/ExpPage.qml', addVersion: '0.0.5' },
                { key:'ExpPagination', label:qsTr('分页'), iconSource: MosIcon.MoreOutlined, source: './Controls/Universal/ExpPagination.qml', addVersion: '0.0.5' },
                { key:'ExpPopconfirm', label:qsTr('气泡确认'), iconSource: MosIcon.QuestionCircleOutlined, source: './Controls/Universal/ExpPopconfirm.qml', addVersion: '0.0.5' },
                { key:'ExpPopover', label:qsTr('气泡卡片'), iconSource: MosIcon.InfoCircleOutlined, source: './Controls/Universal/ExpPopover.qml', addVersion: '0.0.5' },
                { key:'ExpProgress', label:qsTr('进度条'), iconSource: MosIcon.DashboardOutlined, source: './Controls/Universal/ExpProgress.qml', addVersion: '0.0.5' },
                { key:'ExpRate', label:qsTr('评分'), iconSource: MosIcon.StarOutlined, source: './Controls/Universal/ExpRate.qml', addVersion: '0.0.5' },
                { key:'ExpSegmented', label:qsTr('分段选择'), iconSource: MosIcon.AppstoreOutlined, source: './Controls/Universal/ExpSegmented.qml', addVersion: '0.0.5' },
                { key:'ExpSelect', label:qsTr('选择器'), iconSource: MosIcon.SelectOutlined, source: './Controls/Universal/ExpSelect.qml', addVersion: '0.0.5' },
                { key:'ExpSlider', label:qsTr('滑动条'), iconSource: MosIcon.DashOutlined, source: './Controls/Universal/ExpSlider.qml', addVersion: '0.0.5' },
                { key:'ExpSpin', label:qsTr('加载中'), iconSource: MosIcon.LoadingOutlined, source: './Controls/Universal/ExpSpin.qml', addVersion: '0.0.5' },
                { key:'ExpSplitView', label:qsTr('分割视图'), iconSource: MosIcon.ColumnWidthOutlined, source: './Controls/Universal/ExpSplitView.qml', addVersion: '0.0.5' },
                { key:'ExpSwitch', label:qsTr('开关'), iconSource: MosIcon.SwapOutlined, source: './Controls/Universal/ExpSwitch.qml', addVersion: '0.0.5' },
                { key:'ExpSwitchEffect', label:qsTr('切换动效'), iconSource: MosIcon.SwapOutlined, source: './Controls/Universal/ExpSwitchEffect.qml', addVersion: '0.0.5' },
                { key:'ExpTabView', label:qsTr('标签页'), iconSource: MosIcon.AppstoreOutlined, source: './Controls/Universal/ExpTabView.qml', addVersion: '0.0.5' },
                { key:'ExpTimeline', label:qsTr('时间轴'), iconSource: MosIcon.FieldTimeOutlined, source: './Controls/Universal/ExpTimeline.qml', addVersion: '0.0.5' },
                { key:'ExpTourFocus', label:qsTr('漫游聚焦'), iconSource: MosIcon.AimOutlined, source: './Controls/Universal/ExpTourFocus.qml', addVersion: '0.0.5' },
                { key:'ExpTourStep', label:qsTr('漫游步骤'), iconSource: MosIcon.SolutionOutlined, source: './Controls/Universal/ExpTourStep.qml', addVersion: '0.0.5' },
                { key:'ExpTransfer', label:qsTr('穿梭框'), iconSource: MosIcon.SwapOutlined, source: './Controls/Universal/ExpTransfer.qml', addVersion: '0.0.5' },
                { key:'ExpTreeView', label:qsTr('树形视图'), iconSource: MosIcon.ApartmentOutlined, source: './Controls/Universal/ExpTreeView.qml', addVersion: '0.0.5' },
                { key:'ExpTag', label:qsTr('标签'), iconSource: MosIcon.TagsOutlined, source: './Controls/Universal/ExpTag.qml', addVersion: '0.0.5' },
                { key:'ExpButton', label:qsTr('按钮(详)'), iconSource: MosIcon.ButtonOutlined, source: './Controls/Universal/ExpButton.qml', addVersion: '0.0.6' },
                { key:'ExpButtonBlock', label:qsTr('按钮块(详)'), iconSource: MosIcon.ButtonOutlined, source: './Controls/Universal/ExpButtonBlock.qml', addVersion: '0.0.6' },
                { key:'ExpCaptionBar', label:qsTr('标题栏(详)'), iconSource: MosIcon.CaptionbarOutlined, source: './Controls/Universal/ExpCaptionBar.qml', addVersion: '0.0.6' },
                { key:'ExpCaptionButton', label:qsTr('标题按钮(详)'), iconSource: MosIcon.CaptionbarOutlined, source: './Controls/Universal/ExpCaptionButton.qml', addVersion: '0.0.6' },
                { key:'ExpIconButton', label:qsTr('图标按钮'), iconSource: MosIcon.RocketOutlined, source: './Controls/Universal/ExpIconButton.qml', addVersion: '0.0.6' },
                { key:'ExpIconText', label:qsTr('图标文本'), iconSource: MosIcon.FontColorsOutlined, source: './Controls/Universal/ExpIconText.qml', addVersion: '0.0.6' },
                { key:'ExpContextMenu', label:qsTr('右键菜单'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpContextMenu.qml', addVersion: '0.0.6' },
                { key:'ExpScrollBar', label:qsTr('滚动条'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpScrollBar.qml', addVersion: '0.0.6' },
                { key:'ExpPopup', label:qsTr('弹出层'), iconSource: MosIcon.ExpandOutlined, source: './Controls/Universal/ExpPopup.qml', addVersion: '0.0.6' },
                { key:'ExpMessage', label:qsTr('消息'), iconSource: MosIcon.MessageOutlined, source: './Controls/Universal/ExpMessage.qml', addVersion: '0.0.6' },
                { key:'ExpNotification', label:qsTr('通知(详)'), iconSource: MosIcon.NotificationOutlined, source: './Controls/Universal/ExpNotification.qml', addVersion: '0.0.6' },
                { key:'ExpDivider', label:qsTr('分割线'), iconSource: MosIcon.LineOutlined, source: './Controls/Universal/ExpDivider.qml', addVersion: '0.0.6' },
                { key:'ExpGroupBox', label:qsTr('分组框'), iconSource: MosIcon.GroupOutlined, source: './Controls/Universal/ExpGroupBox.qml', addVersion: '0.0.6' },
                { key:'ExpSpace', label:qsTr('间距'), iconSource: MosIcon.ColumnWidthOutlined, source: './Controls/Universal/ExpSpace.qml', addVersion: '0.0.6' },
                { key:'ExpImagePreview', label:qsTr('图片预览'), iconSource: MosIcon.EyeOutlined, source: './Controls/Universal/ExpImagePreview.qml', addVersion: '0.0.6' },
                { key:'ExpInputInteger', label:qsTr('整数输入'), iconSource: MosIcon.NumberOutlined, source: './Controls/Universal/ExpInputInteger.qml', addVersion: '0.0.6' },
                { key:'ExpInputNumber', label:qsTr('数字输入'), iconSource: MosIcon.NumberOutlined, source: './Controls/Universal/ExpInputNumber.qml', addVersion: '0.0.6' },
                { key:'ExpTextArea', label:qsTr('文本域'), iconSource: MosIcon.EditOutlined, source: './Controls/Universal/ExpTextArea.qml', addVersion: '0.0.6' },
                { key:'ExpText', label:qsTr('文本'), iconSource: MosIcon.FontSizeOutlined, source: './Controls/Universal/ExpText.qml', addVersion: '0.0.6' },
                { key:'ExpToolTip', label:qsTr('提示框'), iconSource: MosIcon.QuestionCircleOutlined, source: './Controls/Universal/ExpToolTip.qml', addVersion: '0.0.6' },
                { key:'ExpRadio', label:qsTr('单选框'), iconSource: MosIcon.CheckCircleOutlined, source: './Controls/Universal/ExpRadio.qml', addVersion: '0.0.6' },
                { key:'ExpRadioBlock', label:qsTr('单选块'), iconSource: MosIcon.CheckSquareOutlined, source: './Controls/Universal/ExpRadioBlock.qml', addVersion: '0.0.6' },
                { key:'ExpTableView', label:qsTr('表格'), iconSource: MosIcon.TableOutlined, source: './Controls/Universal/ExpTableView.qml', addVersion: '0.0.6' },
                { key:'ExpShadow', label:qsTr('阴影'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpShadow.qml', addVersion: '0.0.6' },
                { key:'ExpMoveMouseArea', label:qsTr('拖动区域'), iconSource: MosIcon.DragOutlined, source: './Controls/Universal/ExpMoveMouseArea.qml', addVersion: '0.0.6' },
                { key:'ExpResizeMouseArea', label:qsTr('调整区域'), iconSource: MosIcon.ColumnWidthOutlined, source: './Controls/Universal/ExpResizeMouseArea.qml', addVersion: '0.0.6' },
                { key:'ExpWindow', label:qsTr('窗口'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpWindow.qml', addVersion: '0.0.6' },
                { key:'ExpRectangle', label:qsTr('矩形'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpRectangle.qml', addVersion: '0.0.6' },
                { key:'ExpRadius', label:qsTr('圆角'), iconSource: MosIcon.RadiusOutlined, source: './Controls/Universal/ExpRadius.qml', addVersion: '0.0.6' }
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
 