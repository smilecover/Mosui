import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import MosuiBasic

MosInput {
    id: root

    enum DatePickerMode {
        Mode_Year = 0,
        Mode_Quarter = 1,
        Mode_Month = 2,
        Mode_Week = 3,
        Mode_Day = 4
    }

    enum TimePickerMode {
        Mode_HHMMSS = 0,
        Mode_HHMM = 1,
        Mode_MMSS = 2
    }

    signal selected(date: var)

    property alias showDate: __dateTimePickerPanel.showDate
    property alias showTime: __dateTimePickerPanel.showTime
    property alias datePickerMode: __dateTimePickerPanel.datePickerMode
    property alias timePickerMode: __dateTimePickerPanel.timePickerMode
    property alias format: __dateTimePickerPanel.format
    property alias visualYearTitle: __dateTimePickerPanel.visualYearTitle
    property alias visualMonthTitle: __dateTimePickerPanel.visualMonthTitle

    property alias prevIconSource: __dateTimePickerPanel.prevIconSource
    property alias nextIconSource: __dateTimePickerPanel.nextIconSource
    property alias superPrevIconSource: __dateTimePickerPanel.superPrevIconSource
    property alias superNextIconSource: __dateTimePickerPanel.superNextIconSource

    property alias yearRowSpacing: __dateTimePickerPanel.yearRowSpacing
    property alias yearColumnSpacing: __dateTimePickerPanel.yearColumnSpacing
    property alias monthRowSpacing: __dateTimePickerPanel.monthRowSpacing
    property alias monthColumnSpacing: __dateTimePickerPanel.monthColumnSpacing
    property alias quarterSpacing: __dateTimePickerPanel.quarterSpacing

    property alias initDateTime: __dateTimePickerPanel.initDateTime

    property alias currentDateTime: __dateTimePickerPanel.currentDateTime
    property alias currentYear: __dateTimePickerPanel.currentYear
    property alias currentMonth: __dateTimePickerPanel.currentMonth
    property alias currentDay: __dateTimePickerPanel.currentDay
    property alias currentWeekNumber: __dateTimePickerPanel.currentWeekNumber
    property alias currentQuarter: __dateTimePickerPanel.currentQuarter
    property alias currentHours: __dateTimePickerPanel.currentHours
    property alias currentMinutes: __dateTimePickerPanel.currentMinutes
    property alias currentSeconds: __dateTimePickerPanel.currentSeconds

    property alias visualYear: __dateTimePickerPanel.visualYear
    property alias visualMonth: __dateTimePickerPanel.visualMonth
    property alias visualDay: __dateTimePickerPanel.visualDay
    property alias visualWeekNumber: __dateTimePickerPanel.visualWeekNumber
    property alias visualQuarter: __dateTimePickerPanel.visualQuarter
    property alias visualHours: __dateTimePickerPanel.visualHours
    property alias visualMinutes: __dateTimePickerPanel.visualMinutes
    property alias visualSeconds: __dateTimePickerPanel.visualSeconds

    property alias locale: __dateTimePickerPanel.locale

    property alias radiusItemBg: __dateTimePickerPanel.radiusItemBg
    property alias radiusPopupBg: __picker.radiusBg

    property alias dayDelegate: __dateTimePickerPanel.dayDelegate

    property alias popup: __picker
    property alias panel: __dateTimePickerPanel

    function clearDateTime(date: var) {
        root.clear();
        __dateTimePickerPanel.clearDateTime();
    }

    function setDateTime(date: var, emitSelected = false) {
        __dateTimePickerPanel.setDateTime(date, emitSelected);
    }

    function getDateTime(): var {
        return __dateTimePickerPanel.getDateTime();
    }

    function setDateTimeString(dateTimeString: string, emitSelected = false) {
        __dateTimePickerPanel.setDateTimeString(dateTimeString, emitSelected);
    }

    function getDateTimeString(): string {
        return __dateTimePickerPanel.getDateTimeString();
    }

    function selectNow() {
        __dateTimePickerPanel.selectNow();
    }

    function resetVisualStatus() {
        __dateTimePickerPanel.resetVisualStatus();
    }

    function openPicker() {
        if (!__picker.opened)
            __picker.open();
    }

    function closePicker() {
        __picker.close();
    }

    objectName: '__MosDateTimePicker__'
    width: (showDate && showTime ? 210 : 160) * root.sizeRatio
    themeSource: MosTheme.MosDateTimePicker
    iconSource: (__private.interactive && root.hovered && root.length !== 0) ?
                    MosIcon.CloseCircleFilled : root.showDate ? MosIcon.CalendarOutlined :
                                                                   MosIcon.ClockCircleOutlined
    iconPosition: MosInput.Position_Right
    iconDelegate: MosIconText {
        leftPadding: root.iconPosition === MosInput.Position_Left ? 10 * sizeRatio: 0
        rightPadding: root.iconPosition === MosInput.Position_Right ? 10 * sizeRatio: 0
        iconSource: root.iconSource
        iconSize: root.iconSize
        colorIcon: root.enabled ?
                       __iconMouse.hovered ? root.themeSource.colorIconHover :
                                             root.themeSource.colorIcon : root.themeSource.colorIconDisabled

        Behavior on colorIcon { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

        MouseArea {
            id: __iconMouse
            anchors.fill: parent
            enabled: __private.interactive
            hoverEnabled: true
            cursorShape: parent.iconSource === MosIcon.CloseCircleFilled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onEntered: hovered = true;
            onExited: hovered = false;
            onClicked: {
                if (root.length === 0) {
                    root.openPicker();
                } else {
                    root.closePicker();
                }
                root.clearDateTime();
            }
            property bool hovered: false
        }
    }
    onTextEdited: {
        root.openPicker();
        root.setDateTimeString(text);
    }
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
            root.setDateTimeString(text);
            root.closePicker();
        }
    }

    Item {
        id: __private
        property var window: Window.window
        property bool interactive: root.enabled && !root.readOnly
    }

    TapHandler {
        enabled: __private.interactive
        onTapped: {
            root.openPicker();
        }
    }

    MosPopup {
        id: __picker
        x: (root.width - implicitWidth) * 0.5
        y: root.height + 6
        padding: 0
        implicitWidth: implicitContentWidth + leftPadding + rightPadding
        implicitHeight: implicitContentHeight + topPadding + bottomPadding
        animationEnabled: root.animationEnabled
        colorBg: MosTheme.isDark ? root.themeSource.colorPopupBgDark : root.themeSource.colorPopupBg
        radiusBg.all: root.themeSource.radiusPopupBg
        closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent
        transformOrigin: isTop ? Item.Bottom : Item.Top
        enter: Transition {
            NumberAnimation {
                property: 'scale'
                from: 0.5
                to: 1.0
                easing.type: Easing.OutQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
            NumberAnimation {
                property: 'opacity'
                from: 0.0
                to: 1.0
                easing.type: Easing.OutQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: 'scale'
                from: 1.0
                to: 0.5
                easing.type: Easing.InQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
            NumberAnimation {
                property: 'opacity'
                from: 1.0
                to: 0.0
                easing.type: Easing.InQuad
                duration: root.animationEnabled ? MosTheme.Primary.durationMid : 0
            }
        }
        contentItem: MosDateTimePickerPanel {
            id: __dateTimePickerPanel
            animationEnabled: root.animationEnabled
            themeSource: root.themeSource
            sizeRatio: root.sizeRatio
            showNow: true
            colorBorder: 'transparent'
            background: null
            onSelected:
                date => {
                    root.selected(date);
                    root.closePicker();
                }
            onVisualTextChanged: root.text = visualText;
        }
        onAboutToShow: root.resetVisualStatus();
        onAboutToHide: root.resetVisualStatus();
        Component.onCompleted: MosApi.setPopupAllowAutoFlip(this);
        property bool isTop: (y + height * 0.5) < root.height * 0.5
    }
}
