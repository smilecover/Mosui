// Copyright (C) 2025-2027 Wing-summer (wingsummer)
// SPDX-License-Identifier: Apache-2.0

#include "widgetwindowagent_p.h"

namespace QWK {

    // Linux-specific Widgets window agent extensions.
    //
    // Unlike Windows (which needs a border workaround for DWM) and macOS
    // (which needs system button area positioning), Linux frameless windows
    // work through QtWindowContext + LinuxX11Context/LinuxWaylandContext
    // directly, so no additional setup is required here.
    //
    // Window effects (blur / acrylic / mica / dark-mode) are handled by
    // LinuxX11Context::windowAttributeChanged (X11) and
    // LinuxWaylandContext::windowAttributeChanged (Wayland).

} // namespace QWK
