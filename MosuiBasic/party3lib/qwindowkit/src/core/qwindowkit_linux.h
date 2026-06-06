// Copyright (C) 2021-2023 wangwenx190 (Yuhang Zhao)
// Copyright (C) 2023-2024 Stdware Collections (https://www.github.com/stdware)
// Copyright (C) 2025-2027 Wing-summer (wingsummer)
// SPDX-License-Identifier: Apache-2.0

#ifndef QWINDOWKIT_LINUX_H
#define QWINDOWKIT_LINUX_H

//
//  W A R N I N G !!!
//  -----------------
//
// This file is not part of the QWindowKit API. It is used purely as an
// implementation detail. This header file may change from version to
// version without notice, or may even be removed.
//

#include <QtCore/qglobal.h>

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <qguiapplication_platform.h>

// some declarations about x11
using Atom = unsigned long;
using Bool = int;
using XID = unsigned long;
using Window = XID;

union _XEvent;
using XEvent = union _XEvent;

// for wayland
struct wl_proxy;
struct wl_display;
struct wl_registry;
struct wl_surface;

namespace QWK {
    namespace Private {
        struct LinuxX11API {
            LinuxX11API() = default;
            Q_DISABLE_COPY(LinuxX11API)

            using XInternAtomFn = Atom (*)(Display *, const char *, Bool);
            using XSendEventFn = int (*)(Display *, Window, Bool, long, XEvent *);
            using XFlushFn = int (*)(Display *);
            using XChangePropertyFn = int (*)(Display *, Window, Atom, Atom, int, int,
                                               const unsigned char *, int);
            using XDeletePropertyFn = int (*)(Display *, Window, Atom);

            XInternAtomFn XInternAtom = nullptr;
            XSendEventFn XSendEvent = nullptr;
            XFlushFn XFlush = nullptr;
            XChangePropertyFn XChangeProperty = nullptr;
            XDeletePropertyFn XDeleteProperty = nullptr;

            inline bool isValid() const {
                return XInternAtom && XSendEvent && XFlush &&
                       XChangeProperty && XDeleteProperty;
            }
        };

        struct LinuxWaylandAPI {
            LinuxWaylandAPI() = default;
            Q_DISABLE_COPY(LinuxWaylandAPI)

            using wl_display_flush_fn      = int (*)(struct wl_display *);
            using wl_display_roundtrip_fn  = int (*)(struct wl_display *);
            using wl_proxy_marshal_flags_fn = void (*)(struct wl_proxy *, uint32_t,
                                                       const struct wl_interface *, uint32_t,
                                                       uint32_t, ...);
            using wl_proxy_get_version_fn   = int (*)(struct wl_proxy *);
            using wl_proxy_destroy_fn       = void (*)(struct wl_proxy *);
            using wl_proxy_add_listener_fn  = int (*)(struct wl_proxy *,
                                                       void (**)(void), void *);
            using wl_display_get_registry_fn = struct wl_registry *(*)(struct wl_display *);
            using wl_registry_bind_fn        = void *(*)(struct wl_registry *, uint32_t,
                                                          const struct wl_interface *, uint32_t);

            wl_display_flush_fn      wl_display_flush      = nullptr;
            wl_display_roundtrip_fn  wl_display_roundtrip  = nullptr;
            wl_proxy_marshal_flags_fn wl_proxy_marshal_flags = nullptr;
            wl_proxy_get_version_fn   wl_proxy_get_version   = nullptr;
            wl_proxy_destroy_fn       wl_proxy_destroy       = nullptr;
            wl_proxy_add_listener_fn  wl_proxy_add_listener  = nullptr;
            wl_display_get_registry_fn wl_display_get_registry = nullptr;
            wl_registry_bind_fn        wl_registry_bind        = nullptr;

            inline bool isValid() const {
                return wl_display_flush && wl_display_roundtrip &&
                       wl_proxy_marshal_flags && wl_proxy_get_version &&
                       wl_proxy_destroy && wl_proxy_add_listener &&
                       wl_display_get_registry && wl_registry_bind;
            }
        };

        // ── Platform detection ────────────────────────────

        bool isWaylandPlatform();
        bool isX11Platform();

        const LinuxX11API &x11API();
        const LinuxWaylandAPI &waylandAPI();

        // ── X11 window-attribute helpers ──────────────────

        // Set _KDE_NET_WM_BLUR_BEHIND_REGION for KWin blur-behind.
        bool x11SetBlurBehind(Display *display, Window xwin, bool enable);

        // Set _KDE_NET_WM_COLOR_SCHEME for dark/light mode hint.
        bool x11SetDarkMode(Display *display, Window xwin, bool isDark);

        // ── Wayland window-attribute helpers ───────────────

        // Opaque handle returned by waylandBlurCreate.
        struct WaylandBlurHandle;

        // Create (or remove) a blur region on the given wl_surface
        // using the org_kde_kwin_blur_manager protocol.
        // Returns nullptr if the compositor doesn't support it.
        WaylandBlurHandle *waylandBlurCreate(struct wl_display *display,
                                              struct wl_surface *surface);
        void waylandBlurDestroy(WaylandBlurHandle *handle);
    }
}
#endif // QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#endif // QWINDOWKIT_LINUX_H
