// Copyright (C) 2025-2027 Wing-summer (wingsummer)
// SPDX-License-Identifier: Apache-2.0

#include "quickwindowagent_p.h"

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)

namespace QWK {

    // Linux-specific Quick window agent extensions.
    //
    // Unlike Windows (border workaround) and macOS (system button area),
    // Linux frameless windows work through QtWindowContext +
    // LinuxX11Context / LinuxWaylandContext directly.
    //
    // Window effects (blur / acrylic / mica / dark-mode) are handled by
    // LinuxX11Context::windowAttributeChanged (X11 _KDE_NET_WM_BLUR_BEHIND_REGION)
    // and LinuxWaylandContext::windowAttributeChanged (org_kde_kwin_blur_manager).
    //
    // Visual frosted-glass rendering is done in QML (MosWindow.qml)
    // via tint Rectangle + noise ShaderEffect overlays.

} // namespace QWK
#endif // QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
