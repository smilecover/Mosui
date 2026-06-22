import QtQuick
import MosuiBasic

QtObject {
    property var galleryModel: [
        {
            key: 'HomePage',
            label: qsTr('首页'),
            iconSource: MosIcon.HomeOutlined,
            source: './Controls/HomePage.qml',
        },
        // ====== Basic 基础 ======
        {
            key: 'Basic',
            label: qsTr('基础'),
            iconSource: MosIcon.FontColorsOutlined,
            menuChildren: [
                { key:'ExpText', label:qsTr('文本'), iconSource: MosIcon.FontSizeOutlined, source: './Controls/Universal/ExpText.qml' },
                { key:'ExpLabel', label:qsTr('标签文本'), iconSource: MosIcon.FontColorsOutlined, source: './Controls/Universal/ExpLabel.qml' },
                { key:'ExpCopyableText', label:qsTr('可复制文本'), iconSource: MosIcon.CopyOutlined, source: './Controls/Universal/ExpCopyableText.qml' },
                { key:'ExpIconText', label:qsTr('图标文本'), iconSource: MosIcon.FontColorsOutlined, source: './Controls/Universal/ExpIconText.qml' },
                { key:'ExpSpace', label:qsTr('间距'), iconSource: MosIcon.ColumnWidthOutlined, source: './Controls/Universal/ExpSpace.qml' },
                { key:'ExpDivider', label:qsTr('分割线'), iconSource: MosIcon.LineOutlined, source: './Controls/Universal/ExpDivider.qml' },
                { key:'ExpFrame', label:qsTr('框架'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpFrame.qml' },
                { key:'ExpRectangle', label:qsTr('矩形'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpRectangle.qml' },
                { key:'ExpRadius', label:qsTr('圆角'), iconSource: MosIcon.RadiusOutlined, source: './Controls/Universal/ExpRadius.qml' },
                { key:'ExpShadow', label:qsTr('阴影'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpShadow.qml' },
                { key:'ExpWatermark', label:qsTr('水印'), iconSource: MosIcon.EyeOutlined, source: './Controls/Universal/ExpWatermark.qml' },
            ]
        },
        // ====== Button 按钮 ======
        {
            key: 'Button',
            label: qsTr('按钮'),
            iconSource: MosIcon.ButtonOutlined,
            menuChildren: [
                { key:'ExpMosButton', label:qsTr('按钮'), iconSource: MosIcon.ButtonOutlined, source: './Controls/Universal/ExpMosButton.qml' },
                { key:'ExpMosButtonBlock', label:qsTr('按钮块'), iconSource: MosIcon.ButtonOutlined, source: './Controls/Universal/ExpMosButtonBlock.qml' },
                { key:'ExpIconButton', label:qsTr('图标按钮'), iconSource: MosIcon.RocketOutlined, source: './Controls/Universal/ExpIconButton.qml' },
            ]
        },
        // ====== Input 输入 ======
        {
            key: 'Input',
            label: qsTr('输入'),
            iconSource: MosIcon.EditOutlined,
            menuChildren: [
                { key:'ExpInput', label:qsTr('输入框'), iconSource: MosIcon.EditOutlined, source: './Controls/Universal/ExpInput.qml' },
                { key:'ExpInputNumber', label:qsTr('数字输入'), iconSource: MosIcon.NumberOutlined, source: './Controls/Universal/ExpInputNumber.qml' },
                { key:'ExpInputInteger', label:qsTr('整数输入'), iconSource: MosIcon.NumberOutlined, source: './Controls/Universal/ExpInputInteger.qml' },
                { key:'ExpTextArea', label:qsTr('文本域'), iconSource: MosIcon.EditOutlined, source: './Controls/Universal/ExpTextArea.qml' },
                { key:'ExpOTPInput', label:qsTr('验证码'), iconSource: MosIcon.SafetyOutlined, source: './Controls/Universal/ExpOTPInput.qml' },
                { key:'ExpRadio', label:qsTr('单选框'), iconSource: MosIcon.CheckCircleOutlined, source: './Controls/Universal/ExpRadio.qml' },
                { key:'ExpRadioBlock', label:qsTr('单选块'), iconSource: MosIcon.CheckSquareOutlined, source: './Controls/Universal/ExpRadioBlock.qml' },
                { key:'ExpCheckBox', label:qsTr('复选框'), iconSource: MosIcon.CheckSquareOutlined, source: './Controls/Universal/ExpCheckBox.qml' },
                { key:'ExpMultiCheckBox', label:qsTr('多选复选'), iconSource: MosIcon.CheckSquareOutlined, source: './Controls/Universal/ExpMultiCheckBox.qml' },
                { key:'ExpSwitch', label:qsTr('开关'), iconSource: MosIcon.SwapOutlined, source: './Controls/Universal/ExpSwitch.qml' },
                { key:'ExpSelect', label:qsTr('选择器'), iconSource: MosIcon.SelectOutlined, source: './Controls/Universal/ExpSelect.qml' },
                { key:'ExpMultiSelect', label:qsTr('多选下拉'), iconSource: MosIcon.SelectOutlined, source: './Controls/Universal/ExpMultiSelect.qml' },
                { key:'ExpAutoComplete', label:qsTr('自动完成'), iconSource: MosIcon.SearchOutlined, source: './Controls/Universal/ExpAutoComplete.qml' },
                { key:'ExpSlider', label:qsTr('滑动条'), iconSource: MosIcon.DashOutlined, source: './Controls/Universal/ExpSlider.qml' },
                { key:'ExpRate', label:qsTr('评分'), iconSource: MosIcon.StarOutlined, source: './Controls/Universal/ExpRate.qml' },
                { key:'ExpSpin', label:qsTr('加载中'), iconSource: MosIcon.LoadingOutlined, source: './Controls/Universal/ExpSpin.qml' },
            ]
        },
        // ====== DataDisplay 数据展示 ======
        {
            key: 'DataDisplay',
            label: qsTr('数据展示'),
            iconSource: MosIcon.AppstoreOutlined,
            menuChildren: [
                { key:'ExpAvatar', label:qsTr('头像'), iconSource: MosIcon.AvatarOutlined, source: './Controls/Universal/ExpAvatar.qml' },
                { key:'ExpBadge', label:qsTr('徽标'), iconSource: MosIcon.BadgeOutlined, source: './Controls/Universal/ExpBadge.qml' },
                { key:'ExpTag', label:qsTr('标签'), iconSource: MosIcon.TagsOutlined, source: './Controls/Universal/ExpTag.qml' },
                { key:'ExpCard', label:qsTr('卡片'), iconSource: MosIcon.IdcardOutlined, source: './Controls/Universal/ExpCard.qml' },
                { key:'ExpCarousel', label:qsTr('轮播图'), iconSource: MosIcon.PictureOutlined, source: './Controls/Universal/ExpCarousel.qml' },
                { key:'ExpCollapse', label:qsTr('折叠面板'), iconSource: MosIcon.MenuUnfoldOutlined, source: './Controls/Universal/ExpCollapse.qml' },
                { key:'ExpEmpty', label:qsTr('空状态'), iconSource: MosIcon.InboxOutlined, source: './Controls/Universal/ExpEmpty.qml' },
                { key:'ExpImage', label:qsTr('图片'), iconSource: MosIcon.FileImageOutlined, source: './Controls/Universal/ExpImage.qml' },
                { key:'ExpImagePreview', label:qsTr('图片预览'), iconSource: MosIcon.EyeOutlined, source: './Controls/Universal/ExpImagePreview.qml' },
                { key:'ExpAnimatedImage', label:qsTr('动画图片'), iconSource: MosIcon.AnimatedImageOutlined, source: './Controls/Universal/ExpAnimatedImage.qml' },
                { key:'ExpTableView', label:qsTr('表格'), iconSource: MosIcon.TableOutlined, source: './Controls/Universal/ExpTableView.qml' },
                { key:'ExpTreeView', label:qsTr('树形视图'), iconSource: MosIcon.ApartmentOutlined, source: './Controls/Universal/ExpTreeView.qml' },
                { key:'ExpSegmented', label:qsTr('分段选择'), iconSource: MosIcon.AppstoreOutlined, source: './Controls/Universal/ExpSegmented.qml' },
                { key:'ExpTabView', label:qsTr('标签页'), iconSource: MosIcon.AppstoreOutlined, source: './Controls/Universal/ExpTabView.qml' },
                { key:'ExpPagination', label:qsTr('分页'), iconSource: MosIcon.MoreOutlined, source: './Controls/Universal/ExpPagination.qml' },
                { key:'ExpBreadcrumb', label:qsTr('面包屑'), iconSource: MosIcon.RightOutlined, source: './Controls/Universal/ExpBreadcrumb.qml' },
                { key:'ExpTransfer', label:qsTr('穿梭框'), iconSource: MosIcon.SwapOutlined, source: './Controls/Universal/ExpTransfer.qml' },
                { key:'ExpProgress', label:qsTr('进度条'), iconSource: MosIcon.DashboardOutlined, source: './Controls/Universal/ExpProgress.qml' },
            ]
        },
        // ====== Feedback 反馈 ======
        {
            key: 'Feedback',
            label: qsTr('反馈'),
            iconSource: MosIcon.MessageOutlined,
            menuChildren: [
                { key:'ExpMessage', label:qsTr('消息'), iconSource: MosIcon.MessageOutlined, source: './Controls/Universal/ExpMessage.qml' },
                { key:'ExpNotification', label:qsTr('通知'), iconSource: MosIcon.NotificationOutlined, source: './Controls/Universal/ExpNotification.qml' },
                { key:'ExpModal', label:qsTr('模态框'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpModal.qml' },
                { key:'ExpDrawer', label:qsTr('抽屉'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpDrawer.qml' },
                { key:'ExpPopconfirm', label:qsTr('气泡确认'), iconSource: MosIcon.QuestionCircleOutlined, source: './Controls/Universal/ExpPopconfirm.qml' },
                { key:'ExpPopover', label:qsTr('气泡卡片'), iconSource: MosIcon.InfoCircleOutlined, source: './Controls/Universal/ExpPopover.qml' },
                { key:'ExpPopup', label:qsTr('弹出层'), iconSource: MosIcon.ExpandOutlined, source: './Controls/Universal/ExpPopup.qml' },
                { key:'ExpToolTip', label:qsTr('提示框'), iconSource: MosIcon.QuestionCircleOutlined, source: './Controls/Universal/ExpToolTip.qml' },
                { key:'ExpContextMenu', label:qsTr('右键菜单'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpContextMenu.qml' },
            ]
        },
        // ====== Navigation 导航 ======
        {
            key: 'Navigation',
            label: qsTr('导航'),
            iconSource: MosIcon.AimOutlined,
            menuChildren: [
                { key:'ExpMenu', label:qsTr('菜单'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpMenu.qml' },
                { key:'ExpPage', label:qsTr('页面'), iconSource: MosIcon.FileOutlined, source: './Controls/Universal/ExpPage.qml' },
                { key:'ExpTourFocus', label:qsTr('漫游聚焦'), iconSource: MosIcon.AimOutlined, source: './Controls/Universal/ExpTourFocus.qml' },
                { key:'ExpTourStep', label:qsTr('漫游步骤'), iconSource: MosIcon.SolutionOutlined, source: './Controls/Universal/ExpTourStep.qml' },
            ]
        },
        // ====== Window 窗口 ======
        {
            key: 'Window',
            label: qsTr('窗口'),
            iconSource: MosIcon.CaptionbarOutlined,
            menuChildren: [
                { key:'ExpMosCaptionbar', label:qsTr('标题栏'), iconSource: MosIcon.CaptionbarOutlined, source: './Controls/Universal/ExpMosCaptionbar.qml' },
                { key:'ExpMosCaptionButton', label:qsTr('标题按钮'), iconSource: MosIcon.CaptionbarOutlined, source: './Controls/Universal/ExpMosCaptionButton.qml' },
                { key:'ExpWindow', label:qsTr('窗口'), iconSource: MosIcon.BorderOutlined, source: './Controls/Universal/ExpWindow.qml' },
            ]
        },
        // ====== Picker 选择器 ======
        {
            key: 'Picker',
            label: qsTr('选择器'),
            iconSource: MosIcon.CalendarOutlined,
            menuChildren: [
                { key:'ExpDateTimePicker', label:qsTr('日期选择'), iconSource: MosIcon.CalendarOutlined, source: './Controls/Universal/ExpDateTimePicker.qml' },
                { key:'ExpDateTimePickerPanel', label:qsTr('日期面板'), iconSource: MosIcon.CalendarOutlined, source: './Controls/Universal/ExpDateTimePickerPanel.qml' },
                { key:'ExpColorPicker', label:qsTr('颜色选择'), iconSource: MosIcon.BgColorsOutlined, source: './Controls/Universal/ExpColorPicker.qml' },
                { key:'ExpColorPickerPanel', label:qsTr('颜色面板'), iconSource: MosIcon.BgColorsOutlined, source: './Controls/Universal/ExpColorPickerPanel.qml' },
            ]
        },
        // ====== Layout 布局 ======
        {
            key: 'Layout',
            label: qsTr('布局'),
            iconSource: MosIcon.GroupOutlined,
            menuChildren: [
                { key:'ExpSplitView', label:qsTr('分割视图'), iconSource: MosIcon.ColumnWidthOutlined, source: './Controls/Universal/ExpSplitView.qml' },
                { key:'ExpGroupBox', label:qsTr('分组框'), iconSource: MosIcon.GroupOutlined, source: './Controls/Universal/ExpGroupBox.qml' },
            ]
        },
        // ====== Effect 特效 ======
        {
            key: 'Effect',
            label: qsTr('特效'),
            iconSource: MosIcon.EyeOutlined,
            menuChildren: [
                { key:'ExpAcrylic', label:qsTr('亚克力'), iconSource: MosIcon.BgColorsOutlined, source: './Controls/Universal/ExpAcrylic.qml' },
                { key:'ExpLiquidGlass', label:qsTr('液态玻璃'), iconSource: MosIcon.EyeOutlined, source: './Controls/Universal/ExpLiquidGlass.qml' },
                { key:'ExpSwitchEffect', label:qsTr('切换动效'), iconSource: MosIcon.SwapOutlined, source: './Controls/Universal/ExpSwitchEffect.qml' },
                { key:'ExpCheckerBoard', label:qsTr('棋盘格'), iconSource: MosIcon.AppstoreOutlined, source: './Controls/Universal/ExpCheckerBoard.qml' },
            ]
        },
        // ====== Interaction 交互 ======
        {
            key: 'Interaction',
            label: qsTr('交互'),
            iconSource: MosIcon.DragOutlined,
            menuChildren: [
                { key:'ExpMoveMouseArea', label:qsTr('拖动区域'), iconSource: MosIcon.DragOutlined, source: './Controls/Universal/ExpMoveMouseArea.qml' },
                { key:'ExpResizeMouseArea', label:qsTr('调整区域'), iconSource: MosIcon.ColumnWidthOutlined, source: './Controls/Universal/ExpResizeMouseArea.qml' },
                { key:'ExpScrollBar', label:qsTr('滚动条'), iconSource: MosIcon.MenuOutlined, source: './Controls/Universal/ExpScrollBar.qml' },
            ]
        },
        // ====== Chart 图表 ======
        {
            key: 'Chart',
            label: qsTr('图表'),
            iconSource: MosIcon.ChartOutlined,
            menuChildren: [
                { key:'ExpCanvasChart', label:qsTr('Canvas图表'), iconSource: MosIcon.ChartOutlined, source: './Controls/Universal/ExpCanvasChart.qml' },
                { key:'ExpMosHighperchart', label:qsTr('高性能图表'), iconSource: MosIcon.ChartOutlined, source: './Controls/Universal/ExpMosHighperchart.qml' },
            ]
        },
        // ====== Tools 工具 ======
        {
            key: 'Tools',
            label: qsTr('Mos工具'),
            iconSource: MosIcon.ToolsOutlined,
            menuChildren: [
                { key:'ExpSerialPortManager', label:qsTr('串口管理器'), iconSource: MosIcon.SerialportOutlined, source: './Controls/Universal/ExpSerialPortManager.qml' },
                { key:'ExpMqttManager', label:qsTr('MQTT管理器'), iconSource: MosIcon.MqttOutlined, source: './Controls/Universal/ExpMqttManager.qml' },
                {
                    key: 'TPInv',
                    label: qsTr('逆变器工具'),
                    iconSource: MosIcon.ToolsOutlined,
                    source: './Tools/TPInv/TPInvWord.qml',
                },
                {
                    key: 'PLC_APP',
                    label: qsTr('PLC_APP 工具'),
                    iconSource: MosIcon.ToolsOutlined,
                    source: './Tools/PLC_APP/PLC_APPWord.qml',
                }
            ]
        }
    ]
}
