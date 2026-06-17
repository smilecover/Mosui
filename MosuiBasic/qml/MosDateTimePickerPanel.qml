import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    signal selected(date: var)

    property bool animationEnabled: MosTheme.animationEnabled
    property string text: ''
    property string visualText: ''
    property bool showNow: false
    property bool showDate: true
    property bool showTime: true
    property int datePickerMode: MosDateTimePicker.Mode_Day
    property int timePickerMode: MosDateTimePicker.Mode_HHMMSS
    property string format: 'yyyy-MM-dd hh:mm:ss'
    property string visualYearTitle: visualYear + qsTr('年')
    property string visualMonthTitle: (visualMonth + 1) + qsTr('月')

    property var prevIconSource: MosIcon.LeftOutlined ?? ''
    property var nextIconSource: MosIcon.RightOutlined ?? ''
    property var superPrevIconSource: MosIcon.DoubleLeftOutlined ?? ''
    property var superNextIconSource: MosIcon.DoubleRightOutlined ?? ''

    property real yearRowSpacing: 10 * root.sizeRatio
    property real yearColumnSpacing: 15 * root.sizeRatio
    property real monthRowSpacing: 10 * root.sizeRatio
    property real monthColumnSpacing: 15 * root.sizeRatio
    property real quarterSpacing: 10 * root.sizeRatio

    property var initDateTime: undefined

    property var currentDateTime: new Date()
    property int currentYear: new Date().getFullYear()
    property int currentMonth: new Date().getMonth()
    property int currentDay: new Date().getDate()
    property int currentWeekNumber: MosApi.getWeekNumber(new Date())
    property int currentQuarter: Math.floor(currentMonth / 3) + 1
    property int currentHours: 0
    property int currentMinutes: 0
    property int currentSeconds: 0

    property int visualYear: currentYear
    property int visualMonth: currentMonth
    property int visualDay: currentDay
    property int visualWeekNumber: currentWeekNumber
    property int visualQuarter: currentQuarter
    property int visualHours: currentHours
    property int visualMinutes: currentMinutes
    property int visualSeconds: currentSeconds

    property color colorBg: themeSource.colorBg
    property color colorBorder: themeSource.colorBorder
    property MosRadius radiusBg: MosRadius { all: themeSource.radiusBg }
    property MosRadius radiusItemBg: MosRadius { all: themeSource.radiusItemBg }
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosDateTimePicker

    property Component dayDelegate: MosButton {
        padding: 0
        implicitWidth: 28 * root.sizeRatio
        implicitHeight: 28 * root.sizeRatio
        animationEnabled: root.animationEnabled
        sizeRatio: root.sizeRatio
        type: MosButton.Type_Primary
        text: model.day
        font: root.font
        radiusBg: root.radiusItemBg
        effectEnabled: false
        colorBorder: model.today ? root.themeSource.colorDayBorderToday : 'transparent'
        colorText: {
            if (root.datePickerMode == MosDateTimePicker.Mode_Week) {
                return isCurrentWeek || isHoveredWeek ? root.themeSource.colorDayTextCurrent :
                                                        isVisualMonth ? root.themeSource.colorDayText :
                                                                        root.themeSource.colorDayTextNone;
            } else {
                return isVisualDay ? root.themeSource.colorDayTextCurrent :
                                     isVisualMonth ? root.themeSource.colorDayText :
                                                     root.themeSource.colorDayTextNone;
            }
        }
        colorBg: {
            if (root.datePickerMode == MosDateTimePicker.Mode_Week) {
                return 'transparent';
            } else {
                return isVisualDay ? root.themeSource.colorDayBgCurrent :
                                      isHovered ? root.themeSource.colorDayBgHover :
                                                  root.themeSource.colorDayBg;
            }
        }
    }

    function clearDateTime() {
        visualText = text = '';

        if (initDateTime) {
            setDateTime(initDateTime);
        } else {
            const now = new Date();
            currentYear = now.getFullYear();
            currentMonth = now.getMonth();
            currentDay = now.getDate();
            currentWeekNumber = MosApi.getWeekNumber(now);
            currentQuarter = Math.floor(currentMonth / 3) + 1;
            currentHours = 0;
            currentMinutes = 0;
            currentSeconds = 0;
        }
        __hourListView.clearCheck();
        __minuteListView.clearCheck();
        __secondListView.clearCheck();
    }

    function setDateTime(date: var, emitSelected = false) {
        __private.selectDateTime(date, emitSelected);
    }

    function getDateTime(): var {
        return __private.getDateTime();
    }

    function setDateTimeString(dateTimeString: string, emitSelected = false) {
        __private.setDateTimeString(dateTimeString, emitSelected);
    }

    function getDateTimeString(): string {
        return __private.getDateTimeString();
    }

    function selectNow() {
        const now = new Date();
        __private.selectDateTime(now);
        __private.initCheckTime(now);
    }

    function resetVisualStatus() {
        const date = __private.getDateTime();
        __private.selectVisualDateTime(date);
        __private.initCheckTime(date);

        switch (datePickerMode) {
        case MosDateTimePicker.Mode_Day:
        case MosDateTimePicker.Mode_Week:
        {
            __pickerHeader.isPickYear = false;
            __pickerHeader.isPickMonth = false;
            __pickerHeader.isPickQuarter = false;
        } break;
        case MosDateTimePicker.Mode_Month:
        {
            __pickerHeader.isPickYear = false;
            __pickerHeader.isPickMonth = true;
            __pickerHeader.isPickQuarter = false;
        } break;
        case MosDateTimePicker.Mode_Quarter:
        {
            __pickerHeader.isPickYear = false;
            __pickerHeader.isPickMonth = false;
            __pickerHeader.isPickQuarter = true;
        } break;
        case MosDateTimePicker.Mode_Year:
        {
            __pickerHeader.isPickYear = true;
            __pickerHeader.isPickMonth = false;
            __pickerHeader.isPickQuarter = false;
        } break;
        default:
        {
            __pickerHeader.isPickYear = false;
            __pickerHeader.isPickMonth = false;
            __pickerHeader.isPickQuarter = false;
        }
        }
    }

    onInitDateTimeChanged: setDateTime(initDateTime);

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    padding: 8 * sizeRatio
    leftPadding: (showDate ? 8 : 2) * sizeRatio
    rightPadding: (showDate ? (showTime ? 2 : 8) : 2) * sizeRatio
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            spacing: 0

            ColumnLayout {
                visible: root.showDate
                spacing: 5 * root.sizeRatio

                PickerHeader {
                    id: __pickerHeader
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.themeSource.colorSplit
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignCenter
                    spacing: 0
                    visible: (root.datePickerMode == MosDateTimePicker.Mode_Day ||
                              root.datePickerMode == MosDateTimePicker.Mode_Week) &&
                             !__pickerHeader.isPickYear && !__pickerHeader.isPickMonth

                    T.AbstractDayOfWeekRow {
                        id: __dayOfWeekRow
                        implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                                contentItem.implicitWidth + leftPadding + rightPadding)
                        implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                                 contentItem.implicitHeight + topPadding + bottomPadding)
                        spacing: 6 * root.sizeRatio
                        topPadding: 6 * root.sizeRatio
                        bottomPadding: 6 * root.sizeRatio
                        locale: __monthGrid.locale
                        delegate: MosText {
                            width: __dayOfWeekRow.itemWidth
                            text: shortName
                            font: root.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: root.themeSource.colorWeekText

                            required property string shortName
                        }
                        contentItem: Row {
                            spacing: __dayOfWeekRow.spacing
                            Repeater {
                                model: __dayOfWeekRow.source
                                delegate: __dayOfWeekRow.delegate
                            }
                        }
                        property real itemWidth: (__monthGrid.implicitWidth - 6 * spacing) / 7
                    }

                    T.AbstractMonthGrid {
                        id: __monthGrid
                        implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                                contentItem.implicitWidth + leftPadding + rightPadding)
                        implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                                 contentItem.implicitHeight + topPadding + bottomPadding)
                        padding: 0
                        spacing: 0
                        year: root.visualYear
                        month: root.visualMonth
                        locale: root.locale
                        delegate: null
                        contentItem: GridLayout {
                            rows: 6
                            columns: 7
                            rowSpacing: 0
                            columnSpacing: 0

                            Repeater {
                                model: __monthGrid.source
                                delegate: Item {
                                    id: __dayItem
                                    implicitWidth: __dayBg.implicitWidth
                                    implicitHeight: __dayBg.implicitHeight + 6 * root.sizeRatio

                                    required property var model

                                    property int weekYear: MosApi.getWeekYearNumber(model.date)
                                    property bool isCurrentWeek: root.currentWeekNumber === model.weekNumber &&
                                                                 root.visualYear === root.currentYear
                                    property bool isHoveredWeek: __monthGrid.hovered && __private.hoveredWeekNumber === model.weekNumber
                                    property bool isCurrentMonth: root.currentYear === model.year && root.currentMonth === model.month
                                    property bool isVisualMonth: root.visualMonth === model.month
                                    property bool isCurrentDay: root.currentYear === model.year &&
                                                                root.currentMonth === model.month &&
                                                                root.currentDay === model.day
                                    property bool isVisualDay: root.visualYear === model.year &&
                                                               root.visualMonth === model.month &&
                                                               root.visualDay === model.day

                                    Rectangle {
                                        id: __dayBg
                                        implicitWidth: __dayLoader.implicitWidth + 16 * root.sizeRatio
                                        implicitHeight: __dayLoader.implicitHeight
                                        anchors.verticalCenter: parent.verticalCenter
                                        clip: true
                                        color: {
                                            if (root.datePickerMode == MosDateTimePicker.Mode_Week) {
                                                return __dayItem.isCurrentWeek ? root.themeSource.colorDayItemBgCurrent :
                                                                                 __dayItem.isHoveredWeek ? root.themeSource.colorDayItemBgHover :
                                                                                                           root.themeSource.colorDayItemBg;
                                            } else {
                                                return 'transparent';
                                            }
                                        }

                                        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

                                        Loader {
                                            id: __dayLoader
                                            anchors.centerIn: parent
                                            sourceComponent: root.dayDelegate
                                            property alias model: __dayItem.model
                                            property alias isHovered: __hoverHandler.hovered
                                            property alias isCurrentWeek: __dayItem.isCurrentWeek
                                            property alias isHoveredWeek: __dayItem.isHoveredWeek
                                            property alias isCurrentMonth: __dayItem.isCurrentMonth
                                            property alias isVisualMonth: __dayItem.isVisualMonth
                                            property alias isCurrentDay: __dayItem.isCurrentDay
                                            property alias isVisualDay: __dayItem.isVisualDay
                                        }

                                        HoverHandler {
                                            id: __hoverHandler
                                            cursorShape: Qt.PointingHandCursor
                                            onHoveredChanged: {
                                                if (hovered) {
                                                    __private.hoveredWeekNumber = __dayItem.model.weekNumber;
                                                    __private.hoveredDay = __dayItem.model.day;
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (root.showDate && root.showTime)
                                                    __private.selectVisualDateTime(model.date);
                                                else
                                                    __private.selectDateTime(model.date);
                                            }
                                            onDoubleClicked: __private.selectDateTime(model.date);
                                        }
                                    }
                                }
                            }
                        }

                        NumberAnimation on scale {
                            running: root.animationEnabled && __monthGrid.visible
                            from: 0
                            to: 1
                            easing.type: Easing.OutCubic
                            duration: MosTheme.Primary.durationMid
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: __yearPicker.implicitWidth
                    Layout.preferredHeight: __yearPicker.implicitHeight
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 10 * root.sizeRatio
                    visible: __pickerHeader.isPickYear

                    Grid {
                        id: __yearPicker
                        anchors.centerIn: parent
                        rows: 4
                        columns: 3
                        rowSpacing: root.yearRowSpacing
                        columnSpacing: root.yearColumnSpacing

                        NumberAnimation on scale {
                            running: root.animationEnabled && __yearPicker.visible
                            from: 0
                            to: 1
                            easing.type: Easing.OutCubic
                            duration: MosTheme.Primary.durationMid
                        }

                        Repeater {
                            model: 12
                            delegate: Item {
                                width: 80 * root.sizeRatio
                                height: 40 * root.sizeRatio

                                PickerButton {
                                    id: __yearPickerButton
                                    anchors.centerIn: parent
                                    text: year
                                    checked: year == root.visualYear
                                    onClicked: {
                                        root.visualYear = year;
                                        if (root.datePickerMode == MosDateTimePicker.Mode_Day ||
                                                root.datePickerMode == MosDateTimePicker.Mode_Week ||
                                                root.datePickerMode == MosDateTimePicker.Mode_Month) {
                                            __pickerHeader.isPickYear = false;
                                            __pickerHeader.isPickMonth = true;
                                        } else if (root.datePickerMode == MosDateTimePicker.Mode_Quarter) {
                                            __pickerHeader.isPickYear = false;
                                            __pickerHeader.isPickQuarter = true;
                                        } else if (root.datePickerMode == MosDateTimePicker.Mode_Year) {
                                            if (root.showDate && root.showTime)
                                                __private.selectVisualDateTime(new Date(root.visualYear + 1, 0, 0));
                                            else
                                                __private.selectDateTime(new Date(root.visualYear + 1, 0, 0));
                                        }
                                    }
                                    property int year: root.visualYear + modelData - 4
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: __monthPicker.implicitWidth
                    Layout.preferredHeight: __monthPicker.implicitHeight
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 10 * root.sizeRatio
                    visible: __pickerHeader.isPickMonth

                    Grid {
                        id: __monthPicker
                        anchors.centerIn: parent
                        rows: 4
                        columns: 3
                        rowSpacing: root.monthRowSpacing
                        columnSpacing: root.monthColumnSpacing

                        NumberAnimation on scale {
                            running: root.animationEnabled && __monthPicker.visible
                            from: 0
                            to: 1
                            easing.type: Easing.OutCubic
                            duration: MosTheme.Primary.durationMid
                        }

                        Repeater {
                            model: 12
                            delegate: Item {
                                width: 80 * root.sizeRatio
                                height: 40 * root.sizeRatio

                                PickerButton {
                                    id: __monthPickerButton
                                    anchors.centerIn: parent
                                    text: (month + 1) + qsTr('月')
                                    checked: month == root.visualMonth
                                    onClicked: {
                                        root.visualMonth = month;
                                        if (root.datePickerMode == MosDateTimePicker.Mode_Day ||
                                                root.datePickerMode == MosDateTimePicker.Mode_Week) {
                                            __pickerHeader.isPickMonth = false;
                                        } else if (root.datePickerMode == MosDateTimePicker.Mode_Month) {
                                            if (root.showDate && root.showTime)
                                                __private.selectVisualDateTime(new Date(root.visualYear, root.visualMonth + 1, 0));
                                            else
                                                __private.selectDateTime(new Date(root.visualYear, root.visualMonth + 1, 0),
                                                                         (root.showDate && root.showTime));
                                        }
                                    }
                                    property int month: modelData
                                }
                            }
                        }
                    }
                }

                Row {
                    id: __quarterPicker
                    Layout.alignment: Qt.AlignHCenter
                    visible: __pickerHeader.isPickQuarter
                    spacing: root.quarterSpacing

                    NumberAnimation on scale {
                        running: root.animationEnabled && __quarterPicker.visible
                        from: 0
                        to: 1
                        easing.type: Easing.OutCubic
                        duration: MosTheme.Primary.durationMid
                    }

                    Repeater {
                        model: 4
                        delegate: Item {
                            width: 60 * root.sizeRatio
                            height: 40 * root.sizeRatio

                            PickerButton {
                                anchors.centerIn: parent
                                text: `Q${quarter}`
                                checked: quarter == root.visualQuarter
                                onClicked: {
                                    root.visualQuarter = quarter;
                                    __pickerHeader.isPickYear = false;

                                    if (root.datePickerMode == MosDateTimePicker.Mode_Quarter) {
                                        __private.selectDateTime(new Date(root.visualYear, (quarter - 1) * 3 + 1, 0),
                                                                 (root.showDate && root.showTime));
                                    }
                                }
                                property int quarter: modelData + 1
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    visible: root.showNow && root.datePickerMode == MosDateTimePicker.Mode_Day && !root.showTime
                    color: root.themeSource.colorSplit
                }

                Loader {
                    Layout.alignment: Qt.AlignHCenter
                    active: root.showNow && root.datePickerMode == MosDateTimePicker.Mode_Day && !root.showTime
                    visible: active
                    sourceComponent: MosButton {
                        animationEnabled: root.animationEnabled
                        sizeRatio: root.sizeRatio
                        type: MosButton.Type_Link
                        text: qsTr('今天')
                        onClicked: __private.selectDateTime(new Date());
                    }
                }
            }

            Loader {
                Layout.fillHeight: true
                active: root.showDate && root.showTime
                visible: active
                sourceComponent: Item {
                    width: 8 * root.sizeRatio

                    Rectangle {
                        width: 1
                        height: parent.height
                        anchors.right: parent.right
                        color: root.themeSource.colorSplit
                    }
                }
            }

            ColumnLayout {
                Layout.preferredHeight: Math.max(220 * root.sizeRatio, implicitHeight)
                visible: root.showTime

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: __timeLayout.implicitWidth
                    Layout.preferredHeight: 36 * root.sizeRatio
                    visible: root.showDate

                    MosText {
                        anchors.centerIn: parent
                        font {
                            family: root.themeSource.fontFamily
                            pixelSize: parseInt(root.themeSource.fontSize) * root.sizeRatio
                            bold: true
                        }
                        text: {
                            switch (root.timePickerMode) {
                            case MosDateTimePicker.Mode_HHMMSS:
                                return `${__hourListView.checkValue}:${__minuteListView.checkValue}:${__secondListView.checkValue}`;
                            case MosDateTimePicker.Mode_HHMM:
                                return `${__hourListView.checkValue}:${__minuteListView.checkValue}`;
                            case MosDateTimePicker.Mode_MMSS:
                                return `${__minuteListView.checkValue}:${__secondListView.checkValue}`;
                            }
                        }
                        color: root.themeSource.colorTimeHeaderText
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        anchors.bottom: parent.bottom
                        color: root.themeSource.colorSplit
                        visible: root.showDate && root.showTime
                    }
                }

                RowLayout {
                    id: __timeLayout
                    Layout.fillHeight: true
                    spacing: 0

                    TimeListView {
                        id: __hourListView
                        model: 24
                        visible: root.timePickerMode == MosDateTimePicker.Mode_HHMMSS ||
                                 root.timePickerMode == MosDateTimePicker.Mode_HHMM

                        Rectangle {
                            width: 1
                            height: parent.height
                            anchors.right: parent.right
                            color: root.themeSource.colorSplit
                        }
                    }

                    TimeListView {
                        id: __minuteListView
                        model: 60
                        visible: root.timePickerMode == MosDateTimePicker.Mode_HHMMSS ||
                                 root.timePickerMode == MosDateTimePicker.Mode_HHMM ||
                                 root.timePickerMode == MosDateTimePicker.Mode_MMSS

                        Rectangle {
                            width: 1
                            height: parent.height
                            anchors.right: parent.right
                            visible: root.timePickerMode == MosDateTimePicker.Mode_HHMMSS ||
                                     root.timePickerMode == MosDateTimePicker.Mode_MMSS
                            color: root.themeSource.colorSplit
                        }
                    }

                    TimeListView {
                        id: __secondListView
                        model: 60
                        visible: root.timePickerMode == MosDateTimePicker.Mode_HHMMSS ||
                                 root.timePickerMode == MosDateTimePicker.Mode_MMSS
                    }
                }
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.preferredHeight: 32 * root.sizeRatio
            active: root.showNow && root.showTime
            visible: active
            sourceComponent: Item {

                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.themeSource.colorSplit
                }

                MosButton {
                    padding: 2 * root.sizeRatio
                    topPadding: 2 * root.sizeRatio
                    bottomPadding: 2 * root.sizeRatio
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * root.sizeRatio
                    anchors.bottom: parent.bottom
                    animationEnabled: root.animationEnabled
                    sizeRatio: root.sizeRatio
                    type: MosButton.Type_Link
                    text: qsTr('此刻')
                    colorBg: 'transparent'
                    onClicked: root.selectNow();
                }

                MosButton {
                    id: __confirmButton
                    topPadding: 4 * root.sizeRatio
                    bottomPadding: 4 * root.sizeRatio
                    leftPadding: 10 * root.sizeRatio
                    rightPadding: 10 * root.sizeRatio
                    anchors.right: parent.right
                    anchors.rightMargin: 5 * root.sizeRatio
                    anchors.bottom: parent.bottom
                    animationEnabled: root.animationEnabled
                    sizeRatio: root.sizeRatio
                    type: MosButton.Type_Primary
                    text: qsTr('确定')
                    onClicked: {
                        __hourListView.initValue(__hourListView.checkValue);
                        __minuteListView.initValue(__minuteListView.checkValue);
                        __secondListView.initValue(__secondListView.checkValue);
                        __private.selectDateTime(__private.getVisualDateTime());
                    }
                }
            }
        }
    }
    background: MosRectangleInternal {
        color: root.colorBg
        border.color: root.colorBorder
        radius: root.radiusBg.all
        topLeftRadius: root.radiusBg.topLeft
        topRightRadius: root.radiusBg.topRight
        bottomLeftRadius: root.radiusBg.bottomLeft
        bottomRightRadius: root.radiusBg.bottomRight
    }

    component TimeListView: MouseArea {
        id: __rootItem

        property string value: '00'
        property string checkValue: '00'
        property string tempValue: '00'
        property alias model: __listView.model

        function clearCheck() {
            value = checkValue = tempValue = '00';
            if (__buttonGroup.checkedButton != null)
                __buttonGroup.checkedButton.checked = false;
            const item = __listView.itemAtIndex(0);
            if (item)
                item.checked = true;
            __listView.positionViewAtBeginning();
        }

        function initValue(v) {
            value = checkValue = tempValue = v;
        }

        function checkIndex(index) {
            checkValue = tempValue = (String(index).padStart(2, '0'));
            const item = __listView.itemAtIndex(index);
            if (item) {
                item.checked = true;
                item.clicked();
            }
            __listView.positionViewAtIndex(index, ListView.Beginning);
        }

        function positionViewAtIndex(index, mode) {
            __listView.positionViewAtIndex(index, mode);
        }

        Layout.preferredWidth: 52 * root.sizeRatio
        Layout.fillHeight: true
        hoverEnabled: true
        onExited: {
            tempValue = checkValue;
            __private.resetCheckTime();
        }

        ListView {
            id: __listView
            height: parent.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2 * root.sizeRatio
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            delegate: T.AbstractButton {
                width: __listView.width
                height: 28 * root.sizeRatio
                checkable: true
                contentItem: MosText {
                    id: __viewText
                    font {
                        family: root.themeSource.fontFamily
                        pixelSize: parseInt(root.themeSource.fontSize) * root.sizeRatio
                    }
                    text: String(index).padStart(2, '0')
                    color: root.themeSource.colorTimeText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Item {
                    MosRectangleInternal {
                        id: selectionRect
                        anchors.fill: parent
                        radius: root.radiusItemBg.all
                        topLeftRadius: root.radiusItemBg.topLeft
                        topRightRadius: root.radiusItemBg.topRight
                        bottomLeftRadius: root.radiusItemBg.bottomLeft
                        bottomRightRadius: root.radiusItemBg.bottomRight
                        color: root.themeSource.colorButtonBgActive
                        opacity: checked ? 1.0 : 0.0

                        Behavior on opacity {
                            enabled: root.animationEnabled && !checked
                            NumberAnimation { duration: MosTheme.Primary.durationFast }
                        }
                    }

                    MosRectangleInternal {
                        anchors.fill: parent
                        radius: root.radiusItemBg.all
                        topLeftRadius: root.radiusItemBg.topLeft
                        topRightRadius: root.radiusItemBg.topRight
                        bottomLeftRadius: root.radiusItemBg.bottomLeft
                        bottomRightRadius: root.radiusItemBg.bottomRight
                        color: hovered && !checked ? root.themeSource.colorButtonBgHover : 'transparent'
                        z: -1

                        Behavior on color {
                            enabled: root.animationEnabled
                            ColorAnimation { duration: MosTheme.Primary.durationFast }
                        }
                    }
                }
                T.ButtonGroup.group: __buttonGroup
                onHoveredChanged: {
                    if (hovered) {
                        __rootItem.tempValue = __viewText.text;
                        __private.resetTempTime();
                    }
                }
                onClicked: {
                    __rootItem.checkValue = __viewText.text;
                    __private.resetCheckTime();
                    __private.timeViewAtBeginning();
                }
                onDoubleClicked: {
                    __private.selectDateTime(__private.getVisualDateTime());
                }

                Component.onCompleted: checked = (index == 0);
            }
            onContentHeightChanged: cacheBuffer = contentHeight;
            T.ScrollBar.vertical: MosScrollBar {
                id: __scrollBar
                policy: T.ScrollBar.AsNeeded
                animationEnabled: root.animationEnabled
            }

            T.ButtonGroup {
                id: __buttonGroup
            }
        }
    }

    component PageButton: MosIconButton {
        leftPadding: 8 * root.sizeRatio
        rightPadding: 8 * root.sizeRatio
        animationEnabled: root.animationEnabled
        sizeRatio: root.sizeRatio
        type: MosButton.Type_Link
        font {
            family: root.themeSource.fontFamily
            pixelSize: parseInt(root.themeSource.fontSize) * root.sizeRatio
        }
        iconSize: 16 * root.sizeRatio
        colorIcon: hovered ? root.themeSource.colorPageIconHover : root.themeSource.colorPageIcon
    }

    component PickerHeader: RowLayout {
        id: __pickerHeaderComp

        property bool isPickYear: false
        property bool isPickMonth: false
        property bool isPickQuarter: root.datePickerMode === MosDateTimePicker.Mode_Quarter

        PageButton {
            Layout.alignment: Qt.AlignVCenter
            iconSource: root.superPrevIconSource
            onClicked: {
                const prevYear = root.visualYear - (__pickerHeaderComp.isPickYear ? 10 : 1);
                if (prevYear > -9999) {
                    root.visualYear = prevYear;
                }
            }
        }

        PageButton {
            Layout.alignment: Qt.AlignVCenter
            iconSource: root.prevIconSource
            visible: !__pickerHeaderComp.isPickMonth && !__pickerHeaderComp.isPickMonth
            onClicked: {
                if (__pickerHeaderComp.isPickYear) {
                    const prev1Year = root.visualYear - 1;
                    if (prev1Year >= -9999) {
                        root.visualYear = prev1Year;
                    }
                } else {
                    const prevMonth = root.visualMonth - 1;
                    if (prevMonth < 0) {
                        const prevYear = root.visualYear - 1;
                        if (prevYear >= -9999) {
                            root.visualYear = prevYear;
                            root.visualMonth = 11;
                        }
                    } else {
                        root.visualMonth = prevMonth;
                    }
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.preferredHeight: __centerRow.height

            Row {
                id: __centerRow
                anchors.horizontalCenter: parent.horizontalCenter

                PageButton {
                    text: root.visualYearTitle
                    colorText: hovered ? root.themeSource.colorPageTextHover :
                                         root.themeSource.colorPageText
                    font.bold: true
                    onClicked: {
                        __pickerHeaderComp.isPickYear = true;
                        __pickerHeaderComp.isPickMonth = false;
                        __pickerHeaderComp.isPickQuarter = false;
                    }
                }

                PageButton {
                    visible: root.datePickerMode !== MosDateTimePicker.Mode_Year &&
                             root.datePickerMode !== MosDateTimePicker.Mode_Quarter &&
                             !__pickerHeaderComp.isPickQuarter &&
                             !__pickerHeaderComp.isPickYear
                    text: root.visualMonthTitle
                    colorText: hovered ? root.themeSource.colorPageTextHover :
                                         root.themeSource.colorPageText
                    font.bold: true
                    onClicked: {
                        __pickerHeaderComp.isPickYear = false;
                        __pickerHeaderComp.isPickMonth = true;
                    }
                }
            }
        }

        PageButton {
            Layout.alignment: Qt.AlignVCenter
            iconSource: root.nextIconSource
            visible: !__pickerHeaderComp.isPickMonth && !__pickerHeaderComp.isPickMonth
            onClicked: {
                if (__pickerHeaderComp.isPickYear) {
                    const nextPickYear = root.visualYear + 1;
                    if (nextPickYear < 9999) {
                        root.visualYear = nextPickYear;
                    }
                } else {
                    const nextMonth = root.visualMonth + 1;
                    if (nextMonth > 11) {
                        const nextYear = root.visualYear + 1;
                        if (nextYear <= 9999) {
                            root.visualYear = nextYear;
                            root.visualMonth = 0;
                        }
                    } else {
                        root.visualMonth = nextMonth;
                    }
                }
            }
        }

        PageButton {
            Layout.alignment: Qt.AlignVCenter
            iconSource: root.superNextIconSource
            onClicked: {
                const nextYear = root.visualYear + (__pickerHeaderComp.isPickYear ? 10 : 1);
                if (nextYear < 9999) {
                    root.visualYear = nextYear;
                }
            }
        }
    }

    component PickerButton: MosButton {
        padding: 20 * root.sizeRatio
        topPadding: 6 * root.sizeRatio
        bottomPadding: 6 * root.sizeRatio
        animationEnabled: root.animationEnabled
        sizeRatio: root.sizeRatio
        effectEnabled: false
        colorBorder: 'transparent'
        colorBg: checked ? root.themeSource.colorDayBgCurrent :
                           hovered ? root.themeSource.colorDayBgHover :
                                     root.themeSource.colorDayBg
        colorText: checked ? root.themeSource.colorDayTextCurrent : root.themeSource.colorDayText
        font {
            family: root.themeSource.fontFamily
            pixelSize: parseInt(root.themeSource.fontSize) * root.sizeRatio
        }
        radiusBg: root.radiusItemBg
    }

    Item {
        id: __private

        property int hoveredWeekNumber: root.currentWeekNumber
        property int hoveredDay: root.currentDay

        function selectDateTime(date: var, emitSelected = true) {
            if (isValidDate(date)) {
                const month = date.getMonth();
                const weekNumber = MosApi.getWeekNumber(date);
                const quarter = Math.floor(month / 3) + 1;
                if (root.datePickerMode == MosDateTimePicker.Mode_Week) {
                    let inputDate = date;
                    let weekYear = date.getFullYear();
                    let weekYearNumber = MosApi.getWeekYearNumber(date);
                    let text = Qt.formatDateTime(inputDate, root.format.replace('w', String(weekNumber)));
                    if (weekYear !== weekYearNumber) {
                        text = text.replace(String(weekYear), String(weekYearNumber));
                    }
                    root.text = text;
                } else if (root.datePickerMode == MosDateTimePicker.Mode_Quarter) {
                    root.text = Qt.formatDateTime(date, root.format.replace('q', String(quarter)));
                } else {
                    root.text = Qt.formatDateTime(date, root.format);
                }
                root.visualText = root.text;
                root.currentDateTime = getDateTime();
                root.visualYear = root.currentYear = date.getFullYear();
                root.visualMonth = root.currentMonth = month;
                root.visualDay = root.currentDay = date.getDate();
                root.visualWeekNumber = root.currentWeekNumber = weekNumber;
                root.visualQuarter = root.currentQuarter = quarter;

                root.visualHours = root.currentHours = date.getHours();
                root.visualMinutes = root.currentMinutes = date.getMinutes();
                root.visualSeconds = root.currentSeconds = date.getSeconds();

                if (emitSelected) {
                    root.selected(date);
                }
            }
        }

        function selectVisualDateTime(date: var) {
            if (isValidDate(date)) {
                const month = date.getMonth();
                const weekNumber = MosApi.getWeekNumber(date);
                const quarter = Math.floor(month / 3) + 1;
                if (root.datePickerMode == MosDateTimePicker.Mode_Week) {
                    let inputDate = date;
                    let weekYear = date.getFullYear();
                    let weekYearNumber = MosApi.getWeekYearNumber(date);
                    let visualText = Qt.formatDateTime(inputDate, root.format.replace('w', String(weekNumber)));
                    if (weekYear !== weekYearNumber) {
                        visualText = visualText.replace(`${weekYear}`, `${weekYearNumber}`);
                    }
                    root.visualText = visualText;
                } else if (root.datePickerMode == MosDateTimePicker.Mode_Quarter) {
                    root.visualText = Qt.formatDateTime(date, root.format.replace('q', String(quarter)));
                } else {
                    root.visualText = Qt.formatDateTime(date, root.format);
                }

                root.visualYear = date.getFullYear();
                root.visualMonth = month;
                root.visualDay = date.getDate();
                root.visualWeekNumber = weekNumber;
                root.visualQuarter = quarter;

                root.visualHours = date.getHours();
                root.visualMinutes = date.getMinutes();
                root.visualSeconds = date.getSeconds();
            }
        }

        function getDateTime(): var {
            return new Date(root.currentYear,
                            root.currentMonth,
                            root.currentDay,
                            root.currentHours,
                            root.currentMinutes,
                            root.currentSeconds);
        }

        function getVisualDateTime(): var {
            return new Date(root.visualYear,
                            root.visualMonth,
                            root.visualDay,
                            root.visualHours,
                            root.visualMinutes,
                            root.visualSeconds);
        }

        function setDateTimeString(dateTimeString: string, emitSelected = true) {
            selectDateTime(MosApi.dateFromString(dateTimeString, root.format), emitSelected);
        }

        function getDateTimeString(): string {
            let text = '';
            const date = getDateTime();
            const month = date.getMonth();
            const weekNumber = MosApi.getWeekNumber(date);
            const quarter = Math.floor(month / 3) + 1;
            if (root.datePickerMode == MosDateTimePicker.Mode_Week) {
                let inputDate = date;
                let weekYear = date.getFullYear();
                if (weekNumber === 1 && month === 11) {
                    weekYear++;
                    inputDate = new Date(weekYear + 1, 0, 0, date.getHours(), date.getMinutes(), date.getSeconds());
                }
                text = Qt.formatDateTime(inputDate, root.format.replace('w', String(weekNumber)));
            } else if (root.datePickerMode == MosDateTimePicker.Mode_Quarter) {
                text = Qt.formatDateTime(date, root.format.replace('q', String(quarter)));
            } else {
                text = Qt.formatDateTime(date, root.format);
            }

            return text;
        }

        function initCheckTime(date: var) {
            __hourListView.initValue(String(date.getHours()).padStart(2, '0'));
            __hourListView.checkIndex(date.getHours());
            __minuteListView.initValue(String(date.getMinutes()).padStart(2, '0'));
            __minuteListView.checkIndex(date.getMinutes());
            __secondListView.initValue(String(date.getSeconds()).padStart(2, '0'));
            __secondListView.checkIndex(date.getSeconds());
            __private.timeViewAtBeginning();
        }

        function resetCheckTime() {
            root.visualHours = parseInt(__hourListView.checkValue);
            root.visualMinutes = parseInt(__minuteListView.checkValue);
            root.visualSeconds = parseInt(__secondListView.checkValue);
            selectVisualDateTime(getVisualDateTime());
        }

        function resetTempTime() {
            root.visualHours = parseInt(__hourListView.tempValue);
            root.visualMinutes = parseInt(__minuteListView.tempValue);
            root.visualSeconds = parseInt(__secondListView.tempValue);
            selectVisualDateTime(getVisualDateTime());
        }

        function timeViewAtBeginning() {
            __hourListView.positionViewAtIndex(root.visualHours, ListView.Beginning);
            __minuteListView.positionViewAtIndex(root.visualMinutes, ListView.Beginning);
            __secondListView.positionViewAtIndex(root.visualSeconds, ListView.Beginning);
        }

        function isValidDate(date) {
            return date && !isNaN(date.getTime());
        }
    }
}
