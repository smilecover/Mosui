import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.SplitView {
    id: root

    property bool animationEnabled: MosTheme.animationEnabled
    property bool resizable: true
    property var showCollapsibleIcon: false ?? ''
    property real handleSize: 2
    property real handleTriggerSize: 6
    property MosRadius radiusCollapseBar: MosRadius { all: parseInt(themeSource.radiusCollapseBar) - 2 }
    property var themeSource: MosTheme.MosSplitView

    property Component collapseBarStart: MosIconButton {
        implicitWidth: root.orientation === Qt.Horizontal ? 12 : 30
        implicitHeight: root.orientation === Qt.Horizontal ? 30 : 12
        animationEnabled: false
        visible: root.showCollapsibleIcon === 'auto' ? collapseBarHovered : true
        iconSource: root.orientation === Qt.Horizontal ? MosIcon.LeftOutlined : MosIcon.UpOutlined
        leftPadding: 0
        rightPadding: 0
        colorBorder: 'transparent'
        colorBg: pressed ? root.themeSource.colorHandleActive :
                           hovered ? root.themeSource.colorHandleHover :
                                     root.themeSource.colorHandle
        radiusBg: root.radiusCollapseBar
        onClicked: {
            const selfState = __private.getState(index);
            if (selfState.state === 'normal') {
                setItemCollapseState(index, 'collapse');
                setItemCollapseState(index + 1, 'left_expand');
            } else if (selfState.state === 'left_expand' || selfState.state === 'right_expand') {
                setItemCollapseState(index, 'normal');
                setItemCollapseState(index + 1, 'normal');
            }
        }
    }
    property Component collapseBarEnd: MosIconButton {
        implicitWidth: root.orientation === Qt.Horizontal ? 12 : 30
        implicitHeight: root.orientation === Qt.Horizontal ? 30 : 12
        animationEnabled: false
        visible: root.showCollapsibleIcon === 'auto' ? collapseBarHovered : true
        iconSource: root.orientation === Qt.Horizontal ? MosIcon.RightOutlined : MosIcon.DownOutlined
        leftPadding: 0
        rightPadding: 0
        colorBorder: 'transparent'
        colorBg: pressed ? root.themeSource.colorHandleActive :
                           hovered ? root.themeSource.colorHandleHover :
                                     root.themeSource.colorHandle
        radiusBg: root.radiusCollapseBar
        onClicked: {
            const selfState = __private.getState(index);
            if (selfState.state === 'collapse') {
                setItemCollapseState(index, 'normal');
                setItemCollapseState(index + 1, 'normal');
            } else if (selfState.state === 'normal') {
                setItemCollapseState(index, 'right_expand');
                setItemCollapseState(index + 1, 'collapse');
            }
        }
    }

    function setItemCollapseState(index: int, collapseState: string) {
        if (index < 0 || index >= count) return;

        const item = root.itemAt(index);
        const state = __private.getState(index);
        if (root.orientation === Qt.Horizontal) {
            if (collapseState === 'collapse') {
                item.T.SplitView.preferredWidth = 0;
            } else if (collapseState === 'normal') {
                item.T.SplitView.preferredWidth = state.size;
            } else if (collapseState === 'left_expand') {
                const nextItem = root.itemAt(index - 1);
                item.T.SplitView.preferredWidth = item.width + nextItem?.width ?? 0;
            } else {
                // right_expand
                const nextItem = root.itemAt(index + 1);
                item.T.SplitView.preferredWidth = item.width + nextItem?.width ?? 0;
            }
            __private.setState(index, { 'state': collapseState, 'size': item.width });
        } else {
            if (collapseState === 'collapse') {
                item.T.SplitView.preferredHeight = 0;
            } else if (collapseState === 'normal') {
                item.T.SplitView.preferredHeight = state.size;
            } else if (collapseState === 'left_expand') {
                const nextItem = root.itemAt(index - 1);
                item.T.SplitView.preferredHeight = item.height + nextItem?.height ?? 0;
            } else {
                // right_expand
                const nextItem = root.itemAt(index + 1);
                item.T.SplitView.preferredHeight = item.height + nextItem?.height ?? 0;
            }
            __private.setState(index, { 'state': collapseState, 'size': item.height });
        }

        __private.collapseChanged(index, collapseState);
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    handle: Rectangle {
        id: __handleRoot
        implicitWidth: root.orientation === Qt.Horizontal ? root.handleSize : root.width
        implicitHeight: root.orientation === Qt.Horizontal ? root.height : root.handleSize
        enabled: root.resizable
        color: {
            if (root.resizable) {
                return T.SplitHandle.pressed ? root.themeSource.colorHandleActive
                                             : T.SplitHandle.hovered ? root.themeSource.colorHandleHover :
                                                                       root.themeSource.colorHandle;
            } else {
                return root.themeSource.colorHandle;
            }
        }
        containmentMask: Item {
            x: (__handleRoot.width - width) * 0.5
            y: (__handleRoot.height - height) * 0.5
            width: root.orientation === Qt.Horizontal ? root.handleTriggerSize : root.width
            height: root.orientation === Qt.Horizontal ? root.height : root.handleTriggerSize
        }
        /*onXChanged: {
            const item = root.itemAt(index);
            if (collapseState === 'collapse' && item.width > 0) {
                root.setItemCollapseState(index, 'normal');
                root.setItemCollapseState(index + 1, 'normal');
            } else if (collapseState === 'normal' && item.width <= 0) {
                root.setItemCollapseState(index, 'collapse');
                root.setItemCollapseState(index + 1, 'left_expand');
            }
        }*/
        Component.onCompleted: {
            index = __private.instanceCount++;
        }
        Component.onDestruction: {
            __private.instanceCount--;
        }

        property int index: 0
        property string collapseState: 'normal'

        Behavior on color { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationFast } }

        Rectangle {
            implicitWidth: root.orientation === Qt.Horizontal ? parent.width : 20
            implicitHeight: root.orientation === Qt.Horizontal ? 20 : parent.height
            anchors.centerIn: parent
            color: root.themeSource.colorPointer
            visible: root.resizable && root.enabled

            Connections {
                target: __private
                function onCollapseChanged(index: int, collapseState: string) {
                    if (__handleRoot.index === index) {
                        __handleRoot.collapseState = collapseState;
                    }
                }
            }

            Loader {
                id: __collapseBarStartLoader
                anchors.right: root.orientation === Qt.Horizontal ? parent.left : undefined
                anchors.bottom: root.orientation === Qt.Horizontal ? undefined : parent.top
                anchors.verticalCenter: root.orientation === Qt.Horizontal ? parent.verticalCenter : undefined
                anchors.horizontalCenter: root.orientation === Qt.Horizontal ? undefined : parent.horizontalCenter
                visible: __handleRoot.collapseState !== 'collapse'
                active: root.showCollapsibleIcon === 'auto' || root.showCollapsibleIcon === true
                sourceComponent: root.collapseBarStart
                property alias index: __handleRoot.index
                readonly property bool collapseBarHovered: __handleRoot.T.SplitHandle.hovered ||
                                                           __hoverHandlerStart.hovered || __hoverHandlerEnd.hovered

                HoverHandler {
                    id: __hoverHandlerStart
                }
            }

            Loader {
                id: __collapseBarEndLoader
                anchors.left: root.orientation === Qt.Horizontal ? parent.right : undefined
                anchors.top: root.orientation === Qt.Horizontal ? undefined : parent.bottom
                anchors.verticalCenter: root.orientation === Qt.Horizontal ? parent.verticalCenter : undefined
                anchors.horizontalCenter: root.orientation === Qt.Horizontal ? undefined : parent.horizontalCenter
                visible: __handleRoot.collapseState !== 'left_expand' && __handleRoot.collapseState !== 'right_expand'
                active: root.showCollapsibleIcon === 'auto' || root.showCollapsibleIcon === true
                sourceComponent: root.collapseBarEnd
                property alias index: __handleRoot.index
                readonly property bool collapseBarHovered: __handleRoot.T.SplitHandle.hovered ||
                                                           __hoverHandlerStart.hovered || __hoverHandlerEnd.hovered

                HoverHandler {
                    id: __hoverHandlerEnd
                }
            }
        }
    }

    QtObject {
        id: __private

        signal collapseChanged(index: int, collapseState: string)

        property var collapseState: new Map
        property int instanceCount: 0

        function setState(index: int, value: var) {
            collapseState.set(index, value);
        }

        function getState(index: int): var {
            if (!collapseState.has(index)) {
                collapseState.set(index, { 'state': 'normal', 'size': 0 });
            }
            return collapseState.get(index);
        }
    }
}