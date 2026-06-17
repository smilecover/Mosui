import QtQuick
import QtQuick.Templates as T
import MosuiBasic

T.Control {
    id: root

    enum Type {
        Type_Line = 0,
        Type_Circle = 1,
        Type_Dashboard = 2
    }

    enum Status {
        Status_Normal = 0,
        Status_Success = 1,
        Status_Exception = 2,
        Status_Active = 3
    }

    property bool animationEnabled: MosTheme.animationEnabled
    property int type: MosProgress.Type_Line
    property int status: MosProgress.Status_Normal
    property real percent: 0
    property real barThickness: 8
    property string strokeLineCap: 'round'
    property int steps: 0
    property int currentStep: 0
    property real gap: 4
    property real gapDegree: 60
    property bool useGradient: false
    property var gradientStops: ({
                                     '0%': root.colorBar,
                                     '100%': root.colorBar
                                 })
    property bool showInfo: true
    property int precision: 0
    property var formatter:
        () => {
            switch (root.status) {
                case MosProgress.Status_Success:
                return root.type === MosProgress.Type_Line ? MosIcon.CheckCircleFilled : MosIcon.CheckOutlined;
                case MosProgress.Status_Exception:
                return root.type === MosProgress.Type_Line ? MosIcon.CloseCircleFilled : MosIcon.CloseOutlined;
                default: return `${root.percent.toFixed(root.precision)}%`;
            }
        }
    property color colorBar: {
        switch (root.status) {
        case MosProgress.Status_Success: return themeSource.colorBarSuccess;
        case MosProgress.Status_Exception: return themeSource.colorBarException;
        case MosProgress.Status_Normal: return themeSource.colorBarNormal;
        case MosProgress.Status_Active : return themeSource.colorBarNormal;
        default: return themeSource.colorBarNormal;
        }
    }
    property color colorTrack: themeSource.colorTrack
    property color colorInfo: {
        switch (root.status) {
        case MosProgress.Status_Success: return themeSource.colorInfoSuccess;
        case MosProgress.Status_Exception: return themeSource.colorInfoException;
        default: return themeSource.colorInfoNormal;
        }
    }
    property var themeSource: MosTheme.MosProgress

    property Component infoDelegate: MosIconText {
        color: root.colorInfo
        font.family: isIcon ? 'MOSUI' : root.font.family
        font.pixelSize: type === MosProgress.Type_Line ? parseInt(root.font.pixelSize) + (!isIcon ? 0 : 2) :
                                                         parseInt(root.font.pixelSize) + (!isIcon ? 8 : 16)
        text: isIcon ? String.fromCharCode(formatText) : formatText
        property var formatText: root.formatter()
        property bool isIcon: typeof formatText == 'number'
    }

    Behavior on percent { enabled: root.animationEnabled; NumberAnimation { duration: MosTheme.Primary.durationMid } }

    Behavior on colorBar { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorTrack { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }
    Behavior on colorInfo { enabled: root.animationEnabled; ColorAnimation { duration: MosTheme.Primary.durationMid } }

    objectName: '__MosProgress__'
    onPercentChanged: __canvas.requestPaint();
    onStepsChanged: __canvas.requestPaint();
    onCurrentStepChanged: __canvas.requestPaint();
    onBarThicknessChanged: __canvas.requestPaint();
    onStrokeLineCapChanged: __canvas.requestPaint();
    onGapChanged: __canvas.requestPaint();
    onGapDegreeChanged: __canvas.requestPaint();
    onUseGradientChanged: __canvas.requestPaint();
    onGradientStopsChanged: __canvas.requestPaint();
    onColorBarChanged: __canvas.requestPaint();
    onColorTrackChanged: __canvas.requestPaint();
    onColorInfoChanged: __canvas.requestPaint();

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    font {
        family: root.themeSource.fontFamily
        pixelSize: parseInt(root.themeSource.fontSize)
    }
    contentItem: Item {
        implicitHeight: 16

        Canvas {
            id: __canvas
            height: parent.height
            anchors.left: parent.left
            anchors.right: root.type === MosProgress.Type_Line ? (root.showInfo ? __infoLoader.left : parent.right) : parent.right
            anchors.rightMargin: root.type === MosProgress.Type_Line && root.showInfo ? 5 : 0
            antialiasing: true
            onWidthChanged: requestPaint();
            onHeightChanged: requestPaint();
            onActiveWidthChanged:  requestPaint();

            property color activeColor: MosThemeFunctions.alpha(MosTheme.Primary.colorBgBase, 0.15)
            property real activeWidth: 0
            property real progressWidth: root.percent * 0.01 * width

            NumberAnimation on activeWidth {
                running: root.type == MosProgress.Type_Line && root.status == MosProgress.Status_Active
                from: 0
                to: __canvas.progressWidth
                loops: Animation.Infinite
                duration: 2000
                easing.type: Easing.OutQuint
            }

            function createGradient(ctx) {
                let gradient = ctx.createLinearGradient(0, 0, width, height);
                Object.keys(root.gradientStops).forEach(
                            stop => {
                                const percentage = parseFloat(stop) / 100;
                                gradient.addColorStop(percentage, root.gradientStops[stop]);
                            });

                return gradient;
            }

            function getCurrentColor(ctx) {
                return root.useGradient ? createGradient(ctx) : root.colorBar;
            }

            function drawStrokeWithRadius(ctx, x, y, radius, startAngle, endAngle, color) {
                ctx.beginPath();
                ctx.arc(x, y, radius, startAngle, endAngle);
                ctx.lineWidth = root.barThickness;
                ctx.strokeStyle = color;
                ctx.stroke();
            }

            function drawRoundLine(ctx, x, y, width, height, radius, color) {
                ctx.beginPath();
                if (root.strokeLineCap === 'butt') {
                    ctx.moveTo(x, y + height * 0.5);
                    ctx.lineTo(x + width, y + height * 0.5);
                } else {
                    ctx.moveTo(x + radius, y + height * 0.5);
                    ctx.lineTo(x + width - radius * 2, y + radius);
                }
                ctx.lineWidth = root.barThickness;
                ctx.lineCap = root.strokeLineCap;
                ctx.strokeStyle = color;
                ctx.stroke();
            }

            function drawLine(ctx) {
                const color = getCurrentColor(ctx);
                if (root.steps > 0) {
                    const stepWidth = (width - ((root.steps - 1) * root.gap)) / root.steps;
                    const stepHeight = root.barThickness;
                    const stepY = (__canvas.height - stepHeight) * 0.5;

                    for (let i = 0; i < root.steps; i++) {
                        const stepX = i * root.gap + i * stepWidth;
                        ctx.fillStyle = root.colorTrack;
                        ctx.fillRect(stepX, stepY, stepWidth, stepHeight);
                    }

                    for (let ii = 0; ii < root.currentStep; ii++) {
                        const stepX = ii * root.gap + ii * stepWidth;
                        ctx.fillStyle = color;
                        ctx.fillRect(stepX, stepY, stepWidth, stepHeight);
                    }
                } else {
                    const x = 0;
                    const y = (height - root.barThickness) * 0.5;
                    const progressWidth = root.percent * 0.01 * width;
                    const radius = root.strokeLineCap === 'round' ? root.barThickness * 0.5 : 0;

                    drawRoundLine(ctx, x, y, width, root.barThickness, radius, root.colorTrack);

                    if (progressWidth > 0) {
                        drawRoundLine(ctx, x, y, progressWidth, root.barThickness, radius, color);
                        /*! 绘制激活状态动画 */
                        if (root.status == MosProgress.Status_Active) {
                            drawRoundLine(ctx, x, y, __canvas.activeWidth, root.barThickness, radius, __canvas.activeColor);
                        }
                    }
                }
            }

            function drawCircle(ctx, centerX, centerY, radius) {
                /*! 确保绘制不会超出边界 */
                radius = Math.max(0, Math.min(radius, Math.min(width, height) * 0.5 - root.barThickness));
                const color = getCurrentColor(ctx);
                if (root.steps > 0) {
                    /*! 计算每个步骤的弧长，考虑圆角影响 */
                    const gap = root.gap;
                    const circumference = Math.PI * 2 * radius;
                    const totalGapLength = gap * root.steps;
                    const availableLength = circumference - totalGapLength;
                    const stepLength = availableLength / root.steps;

                    /*! 绘制背景圆环段 */
                    for (let i = 0; i < root.steps; i++) {
                        const gapDistance = (gap * i) / radius;
                        const stepAngle = stepLength / radius;
                        const startAngle = (i * stepAngle) + gapDistance - Math.PI / 2;
                        const endAngle = startAngle + stepLength / radius;

                        drawStrokeWithRadius(ctx, centerX, centerY, radius, startAngle, endAngle, root.colorTrack);
                    }

                    /*! 绘制已完成的步骤 */
                    for (let ii = 0; ii < root.currentStep; ii++) {
                        const gapDistance = (gap * ii) / radius;
                        const stepAngle = stepLength / radius;
                        const startAngle = (ii * stepAngle) + gapDistance - Math.PI / 2;
                        const endAngle = startAngle + stepLength / radius;

                        drawStrokeWithRadius(ctx, centerX, centerY, radius, startAngle, endAngle, color);
                    }
                } else {
                    /*! 非步骤条需要使用线帽 */
                    ctx.lineCap = root.strokeLineCap;

                    /*! 绘制轨道 */
                    drawStrokeWithRadius(ctx, centerX, centerY, radius, 0, Math.PI * 2, root.colorTrack);

                    /*! 绘制进度 */
                    const progress = root.percent * 0.01 * Math.PI * 2;
                    drawStrokeWithRadius(ctx, centerX, centerY, radius, -Math.PI / 2, progress - Math.PI / 2, color);
                }
            }

            function drawDashboard(ctx, centerX, centerY, radius) {
                radius = Math.max(0,Math.min(radius, Math.min(width, height) * 0.5 - root.barThickness));
                /* ! 计算开始和结束角度 */
                const gapRad = Math.min(Math.max(root.gapDegree, 0), 295) * Math.PI / 180;
                const startAngle = Math.PI * 0.5 + gapRad * 0.5;
                const endAngle = Math.PI * 2.5 - gapRad * 0.5;
                const color = getCurrentColor(ctx);

                if (root.steps > 0) {
                   /*! 计算每个步骤的弧长，考虑仪表盘缺口和步进间隔 */
                    const gap = root.gap;
                    const availableAngle = endAngle - startAngle;
                    const totalGapAngle = (gap / radius) * (root.steps - 1);
                    const stepAngle = (availableAngle - totalGapAngle) / root.steps;

                    /*! 绘制背景圆环段 */
                    for (let i = 0; i < root.steps; i++) {
                        const stepStartAngle = startAngle + i * (stepAngle + gap / radius);
                        const stepEndAngle = stepStartAngle + stepAngle;
                        drawStrokeWithRadius(ctx, centerX, centerY, radius, stepStartAngle, stepEndAngle, root.colorTrack);
                    }

                    /*! 绘制已完成的步骤 */
                    for (let ii = 0; ii < root.currentStep; ii++) {
                        const stepStartAngle = startAngle + ii * (stepAngle + gap / radius);
                        const stepEndAngle = stepStartAngle + stepAngle;
                        drawStrokeWithRadius(ctx, centerX, centerY, radius, stepStartAngle, stepEndAngle, color);
                    }
                } else {
                    /*! 非步骤条需要使用线帽 */
                    ctx.lineCap = root.strokeLineCap;

                    /*！绘制背景轨道 */
                    drawStrokeWithRadius(ctx, centerX, centerY, radius, startAngle, endAngle, root.colorTrack);

                    /*计算进度条角度 */
                    const progressRange = endAngle - startAngle;
                    const progress = root.percent * 0.01 * progressRange;

                    /*绘制进度 */
                    drawStrokeWithRadius(ctx, centerX, centerY, radius, startAngle, startAngle + progress, color);
                }
            }

            onPaint: {
                let ctx = getContext('2d');

                let centerX = width * 0.5;
                let centerY = height * 0.5;
                let radius = Math.max(0, Math.min(width, height) * 0.5 - root.barThickness);

                /*! 清除画布 */
                ctx.clearRect(0, 0, width, height);

                switch (root.type) {
                case MosProgress.Type_Line:
                    drawLine(ctx); break;
                case MosProgress.Type_Circle:
                    drawCircle(ctx, centerX, centerY, radius); break;
                case MosProgress.Type_Dashboard:
                    drawDashboard(ctx, centerX, centerY, radius); break;
                default: break;
                }
            }
        }

        Loader {
            id: __infoLoader
            active: root.showInfo
            visible: active
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: root.type === MosProgress.Type_Line ? undefined : parent.horizontalCenter
            anchors.right: root.type === MosProgress.Type_Line ? parent.right : undefined
            sourceComponent: root.infoDelegate
        }
    }
}
