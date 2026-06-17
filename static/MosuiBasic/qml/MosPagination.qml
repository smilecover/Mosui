import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property var defaultButtonWidth: 32 * sizeRatio ?? ''
    property var defaultButtonHeight: 30 * sizeRatio ?? ''
    property alias defaultButtonSpacing: root.spacing
    property bool showQuickJumper: false
    property int currentPageIndex: 0
    property int total: 0
    readonly property int pageTotal: pageSize > 0 ? Math.ceil(total / pageSize) : 0
    property int pageButtonMaxCount: 7
    property int pageSize: 10
    property var pageSizeModel: []
    property string prevButtonToolTip: qsTr('上一页')
    property string nextButtonToolTip: qsTr('下一页')
    property string sizeHint: 'normal'
    property real sizeRatio: MosTheme.sizeHint[sizeHint]
    property var themeSource: MosTheme.MosPagination

    property Component prevButtonDelegate: ActionButton {
        iconSource: MosIcon.LeftOutlined
        toolTipText: root.prevButtonToolTip
        disabled: root.currentPageIndex === 0
        onClicked: root.gotoPrevPage();
    }
    property Component nextButtonDelegate: ActionButton {
        iconSource: MosIcon.RightOutlined
        toolTipText: root.nextButtonToolTip
        disabled: root.currentPageIndex === (root.pageTotal - 1)
        onClicked: root.gotoNextPage();
    }
    property Component quickJumperDelegate: Row {
        height: root.defaultButtonHeight
        spacing: root.defaultButtonSpacing

        MosText {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr('跳至')
            font: root.font
            color: MosTheme.Primary.colorTextBase
        }

        MosInput {
            width: 48 * root.sizeRatio
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: MosInput.AlignHCenter
            animationEnabled: root.animationEnabled
            enabled: root.enabled
            sizeRatio: root.sizeRatio
            validator: IntValidator { top: 99999; bottom: 0 }
            onEditingFinished: {
                root.gotoPageIndex(parseInt(text) - 1);
                clear();
            }
        }

        MosText {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr('页')
            font: root.font
            color: MosTheme.Primary.colorTextBase
        }
    }

    function gotoPageIndex(index: int) {
        if (index <= 0)
            root.currentPageIndex = 0;
        else if (index < pageTotal)
            root.currentPageIndex = index;
        else
            root.currentPageIndex = (pageTotal - 1);
    }

    function gotoPrevPage() {
        if (currentPageIndex > 0)
            currentPageIndex--;
    }

    function gotoPrev5Page() {
        if (currentPageIndex > 5)
            currentPageIndex -= 5;
        else
            currentPageIndex = 0;
    }

    function gotoNextPage() {
        if (currentPageIndex < pageTotal - 1)
            currentPageIndex++;
    }

    function gotoNext5Page() {
        if ((currentPageIndex + 5) < pageTotal)
            currentPageIndex += 5;
        else
            currentPageIndex = pageTotal - 1;
    }

    onPageTotalChanged: {
        if (currentPageIndex >= pageTotal) {
            currentPageIndex = pageTotal === 0 ? 0 : (pageTotal - 1);
        }
    }
    onPageSizeChanged: {
        const __pageTotal = (pageSize > 0 ? Math.ceil(total / pageSize) : 0);
        if (currentPageIndex >= __pageTotal) {
            currentPageIndex = __pageTotal === 0 ? 0 : (__pageTotal - 1);
        }
    }
    Component.onCompleted: currentPageIndexChanged();

    objectName: '__MosPagination__'
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    spacing: 8 * sizeRatio
    font {
        family: themeSource.fontFamily
        pixelSize: parseInt(themeSource.fontSize) * sizeRatio
    }
    contentItem: Row {
        id: __row
        spacing: root.spacing

        Loader {
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.prevButtonDelegate
        }

        PaginationButton {
            anchors.verticalCenter: parent.verticalCenter
            pageIndex: 0
            visible: root.pageTotal > 0
        }

        PaginationMoreButton {
            anchors.verticalCenter: parent.verticalCenter
            isPrev: true
            toolTipText: qsTr('向前5页')
            visible: root.pageTotal > root.pageButtonMaxCount && (root.currentPageIndex + 1) > __private.pageButtonHalfCount
            onClicked: root.gotoPrev5Page();
        }

        Repeater {
            id: __repeater
            model: (root.pageTotal < 2) ? 0 :
                                             (root.pageTotal >= root.pageButtonMaxCount) ? (root.pageButtonMaxCount - 2) :
                                                                                                 (root.pageTotal - 2)
            delegate: Loader {
                sourceComponent: PaginationButton {
                    anchors.verticalCenter: parent.verticalCenter
                    pageIndex: {
                        if ((root.currentPageIndex + 1) <= __private.pageButtonHalfCount)
                            return index + 1;
                        else if (root.pageTotal - (root.currentPageIndex + 1) <= (root.pageButtonMaxCount - __private.pageButtonHalfCount))
                            return (root.pageTotal - __repeater.count + index - 1);
                        else
                            return (root.currentPageIndex + index + 2 - __private.pageButtonHalfCount);
                    }
                }
                required property int index
            }
        }

        PaginationMoreButton {
            anchors.verticalCenter: parent.verticalCenter
            isPrev: false
            toolTipText: qsTr('向后5页')
            visible: root.pageTotal > root.pageButtonMaxCount &&
                     (root.pageTotal - (root.currentPageIndex + 1) > (root.pageButtonMaxCount - __private.pageButtonHalfCount))
            onClicked: root.gotoNext5Page();
        }

        PaginationButton {
            anchors.verticalCenter: parent.verticalCenter
            pageIndex: root.pageTotal - 1
            visible: root.pageTotal > 1
        }

        Loader {
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.nextButtonDelegate
        }

        MosSelect {
            anchors.verticalCenter: parent.verticalCenter
            animationEnabled: root.animationEnabled
            clearEnabled: false
            sizeRatio: root.sizeRatio
            model: root.pageSizeModel
            visible: count > 0
            font: root.font
            onActivated:
                (index) => {
                    root.pageSize = currentValue;
                }
        }

        Loader {
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: root.showQuickJumper ? root.quickJumperDelegate : null
        }
    }

    component PaginationButton: MosButton {
        width: __private.widthIsAuto ? Math.max(implicitWidth, 32 * root.sizeRatio) : root.defaultButtonWidth
        height: __private.heightIsAuto ? Math.max(implicitHeight, 30 * root.sizeRatio) : root.defaultButtonHeight
        leftPadding: __private.widthIsAuto ? 10 * root.sizeRatio : 0
        rightPadding: __private.widthIsAuto ? 10 * root.sizeRatio : 0
        animationEnabled: false
        effectEnabled: false
        enabled: root.enabled
        sizeRatio: root.sizeRatio
        text: (pageIndex + 1)
        checked: root.currentPageIndex == pageIndex
        font {
            family: root.font.family
            pixelSize: root.font.pixelSize
            bold: checked
        }
        colorText: {
            if (enabled)
                return checked ? root.themeSource.colorButtonTextActive : root.themeSource.colorButtonText;
            else
                return root.themeSource.colorButtonTextDisabled;
        }
        colorBg: {
            if (enabled) {
                if (checked)
                    return root.themeSource.colorButtonBg;
                else
                    return down ? root.themeSource.colorButtonBgActive :
                                  hovered ? root.themeSource.colorButtonBgHover :
                                            root.themeSource.colorButtonBg;
            } else {
                return checked ? root.themeSource.colorButtonBgDisabled : 'transparent';
            }
        }
        colorBorder: checked ? root.themeSource.colorBorderActive : 'transparent'
        onClicked: {
            root.currentPageIndex = pageIndex;
        }
        property int pageIndex: 0

        Behavior on colorText { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
        Behavior on colorBg { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
        Behavior on colorBorder { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

        MosToolTip {
            visible: parent.hovered && parent.enabled
            animationEnabled: root.animationEnabled
            text: parent.text
        }
    }

    component PaginationMoreButton: MosIconButton {
        id: __moreRoot
        width: __private.widthIsAuto ? Math.max(implicitWidth, 32 * root.sizeRatio) : root.defaultButtonWidth
        height: __private.heightIsAuto ? Math.max(implicitHeight, 30 * root.sizeRatio) : root.defaultButtonHeight
        leftPadding: 0
        rightPadding: 0
        animationEnabled: false
        effectEnabled: false
        enabled: root.enabled
        sizeRatio: root.sizeRatio
        colorBg: 'transparent'
        colorBorder: 'transparent'
        text: '•••'

        property bool showIcon: (enabled && (down || hovered))
        property bool isPrev: false
        property alias toolTipText: __moreToolTip.text

        onShowIconChanged: __seqAnimation.restart();

        SequentialAnimation {
            id: __seqAnimation
            alwaysRunToEnd: true
            ScriptAction {
                script: {
                    if (__moreRoot.showIcon) {
                        __moreRoot.text = '';
                        __moreRoot.iconSource = __moreRoot.isPrev ? MosIcon.DoubleLeftOutlined : MosIcon.DoubleRightOutlined;
                    } else {
                        __moreRoot.text = '•••'
                        __moreRoot.iconSource = 0;
                    }
                }
            }
            NumberAnimation {
                target: __moreRoot
                property: 'opacity'
                from: 0.0
                to: 1.0
                duration: root.animationEnabled ? MosTheme.Primary.durationSlow : 0
            }
        }

        MosToolTip {
            id: __moreToolTip
            visible: parent.enabled && parent.hovered && text !== ''
            animationEnabled: root.animationEnabled
        }
    }

    component ActionButton: Item {
        id: __actionRoot
        width: __actionButton.width
        height: __actionButton.height

        signal clicked()
        property bool disabled: false
        property alias iconSource: __actionButton.iconSource
        property alias toolTipText: __ToolTip.text

        MosIconButton {
            id: __actionButton
            width: __private.widthIsAuto ? Math.max(implicitWidth, 32 * root.sizeRatio) : root.defaultButtonWidth
            height: __private.heightIsAuto ? Math.max(implicitHeight, 30 * root.sizeRatio) : root.defaultButtonHeight
            leftPadding: __private.widthIsAuto ? 10 * root.sizeRatio : 0
            rightPadding: __private.widthIsAuto ? 10 * root.sizeRatio : 0
            animationEnabled: root.animationEnabled
            enabled: root.enabled && !__actionRoot.disabled
            effectEnabled: false
            sizeRatio: root.sizeRatio
            iconSize: root.font.pixelSize
            colorBorder: 'transparent'
            colorBg: enabled ? (down ? root.themeSource.colorActionBgActive :
                                       hovered ? root.themeSource.colorActionBgHover :
                                                 root.themeSource.colorActionBg) : root.themeSource.colorActionBg
            onClicked: __actionRoot.clicked();

            MosToolTip {
                id: __ToolTip
                visible: parent.hovered && parent.enabled && text !== ''
                animationEnabled: root.animationEnabled
            }
        }

        HoverHandler {
            enabled: __actionRoot.disabled
            cursorShape: Qt.ForbiddenCursor
        }
    }

    QtObject {
        id: __private
        property bool widthIsAuto: root.defaultButtonWidth === 'auto'
        property bool heightIsAuto: root.defaultButtonHeight === 'auto'
        property int pageButtonHalfCount: Math.ceil(root.pageButtonMaxCount * 0.5)
    }
}
