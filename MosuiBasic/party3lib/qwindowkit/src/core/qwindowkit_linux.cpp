// Copyright (C) 2021-2023 wangwenx190 (Yuhang Zhao)
// Copyright (C) 2023-2024 Stdware Collections (https://www.github.com/stdware)
// Copyright (C) 2025-2027 Wing-summer (wingsummer)
// SPDX-License-Identifier: Apache-2.0

#include "qwindowkit_linux.h"

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <QGuiApplication>
#include <QLibrary>

#include <cstring>
#include <cstdlib>

namespace QWK {
    namespace Private {

        bool isX11Platform() {
            static const bool isX11 = QGuiApplication::platformName().startsWith(
                QStringLiteral("xcb"), Qt::CaseInsensitive);
            return isX11;
        }

        bool isWaylandPlatform() {
            static const bool isWayland = QGuiApplication::platformName().startsWith(
                QStringLiteral("wayland"), Qt::CaseInsensitive);
            return isWayland;
        }

        // ── Wayland API ────────────────────────────────────

        const LinuxWaylandAPI &waylandAPI() {
            static LinuxWaylandAPI api;
            static bool guard = true;
            if (guard && isWaylandPlatform()) {
                QLibrary waylib(QStringLiteral("libwayland-client.so"));
                bool loaded = false;
                if (waylib.load()) {
                    loaded = true;
                } else {
                    waylib.setFileName(QStringLiteral("libwayland-client.so.0"));
                    if (waylib.load())
                        loaded = true;
                }
                if (loaded) {
                    api.wl_display_flush = reinterpret_cast<LinuxWaylandAPI::wl_display_flush_fn>(
                        waylib.resolve("wl_display_flush"));
                    api.wl_display_roundtrip = reinterpret_cast<LinuxWaylandAPI::wl_display_roundtrip_fn>(
                        waylib.resolve("wl_display_roundtrip"));
                    api.wl_proxy_marshal_flags = reinterpret_cast<LinuxWaylandAPI::wl_proxy_marshal_flags_fn>(
                        waylib.resolve("wl_proxy_marshal_flags"));
                    api.wl_proxy_get_version = reinterpret_cast<LinuxWaylandAPI::wl_proxy_get_version_fn>(
                        waylib.resolve("wl_proxy_get_version"));
                    api.wl_proxy_destroy = reinterpret_cast<LinuxWaylandAPI::wl_proxy_destroy_fn>(
                        waylib.resolve("wl_proxy_destroy"));
                    api.wl_proxy_add_listener = reinterpret_cast<LinuxWaylandAPI::wl_proxy_add_listener_fn>(
                        waylib.resolve("wl_proxy_add_listener"));
                    api.wl_display_get_registry = reinterpret_cast<LinuxWaylandAPI::wl_display_get_registry_fn>(
                        waylib.resolve("wl_display_get_registry"));
                    api.wl_registry_bind = reinterpret_cast<LinuxWaylandAPI::wl_registry_bind_fn>(
                        waylib.resolve("wl_registry_bind"));
                }
            }
            guard = false;
            return api;
        }

        // ── X11 API ────────────────────────────────────────

        const LinuxX11API &x11API() {
            static LinuxX11API api;
            static bool guard = true;
            if (guard && isX11Platform()) {
                QString libName = QStringLiteral(
#if defined(__CYGWIN__)
                    "libX11-6.so"
#elif defined(__OpenBSD__) || defined(__NetBSD__)
                    "libX11.so"
#else
                    "libX11.so.6"
#endif
                );
                QLibrary x11lib(libName);
                if (x11lib.load()) {
                    api.XInternAtom = reinterpret_cast<LinuxX11API::XInternAtomFn>(
                        x11lib.resolve("XInternAtom"));
                    api.XSendEvent = reinterpret_cast<LinuxX11API::XSendEventFn>(
                        x11lib.resolve("XSendEvent"));
                    api.XFlush = reinterpret_cast<LinuxX11API::XFlushFn>(
                        x11lib.resolve("XFlush"));
                    api.XChangeProperty = reinterpret_cast<LinuxX11API::XChangePropertyFn>(
                        x11lib.resolve("XChangeProperty"));
                    api.XDeleteProperty = reinterpret_cast<LinuxX11API::XDeletePropertyFn>(
                        x11lib.resolve("XDeleteProperty"));
                }
            }
            guard = false;
            return api;
        }

        // ═════════════════════════════════════════════════════
        // X11: KWin blur-behind
        // ═════════════════════════════════════════════════════

        bool x11SetBlurBehind(Display *display, Window xwin, bool enable) {
            const auto &api = x11API();
            if (!api.isValid() || !display || !xwin)
                return false;

            Atom blurAtom = api.XInternAtom(display,
                "_KDE_NET_WM_BLUR_BEHIND_REGION", 0);
            if (blurAtom == 0)
                return false;

            if (enable) {
                // CARDINAL = 32-bit unsigned integer
                Atom cardAtom = api.XInternAtom(display, "CARDINAL", 0);
                if (cardAtom == 0)
                    return false;
                unsigned long value = 1;
                api.XChangeProperty(display, xwin, blurAtom, cardAtom,
                                    32, 0, // format, mode=Replace
                                    reinterpret_cast<const unsigned char *>(&value), 1);
            } else {
                api.XDeleteProperty(display, xwin, blurAtom);
            }
            api.XFlush(display);
            return true;
        }

        // ═════════════════════════════════════════════════════
        // X11: dark-mode hint (_KDE_NET_WM_COLOR_SCHEME)
        // ═════════════════════════════════════════════════════

        bool x11SetDarkMode(Display *display, Window xwin, bool isDark) {
            const auto &api = x11API();
            if (!api.isValid() || !display || !xwin)
                return false;

            Atom colorSchemeAtom = api.XInternAtom(display,
                "_KDE_NET_WM_COLOR_SCHEME", 0);
            if (colorSchemeAtom == 0)
                return false;

            Atom utf8Atom = api.XInternAtom(display, "UTF8_STRING", 0);
            if (utf8Atom == 0)
                return false;

            const char *value = isDark ? "1" : "0";
            api.XChangeProperty(display, xwin, colorSchemeAtom, utf8Atom,
                                8, 0, // format=8, mode=Replace
                                reinterpret_cast<const unsigned char *>(value),
                                static_cast<int>(std::strlen(value)));
            api.XFlush(display);
            return true;
        }

        // ═════════════════════════════════════════════════════
        // Wayland: KWin blur-behind
        //
        // Uses org_kde_kwin_blur_manager protocol.
        // Protocol (kwin/src/plugins/blur/org.kde.kwin.blur.xml):
        //
        //   blur_manager::create  (op 0): new_id blur, wl_surface
        //   blur_manager::remove  (op 1): blur
        //   blur::set_region      (op 0): wl_region?
        //   blur::commit          (op 1): (none)
        //   blur::release         (op 2): (none)
        // ═════════════════════════════════════════════════════

        static constexpr char kBlurManagerIface[] = "org_kde_kwin_blur_manager";

        // wl_registry_listener — manually defined (avoid header dep)
        struct WlRegistryListener {
            void (*global)(void *, wl_registry *, uint32_t, const char *, uint32_t);
            void (*global_remove)(void *, wl_registry *, uint32_t);
        };

        struct RegistryScanData {
            uint32_t blurManagerId;
            uint32_t blurManagerVersion;
        };

        static void onRegistryGlobal(void *data, wl_registry *, uint32_t name,
                                     const char *interface, uint32_t version) {
            auto *d = static_cast<RegistryScanData *>(data);
            if (std::strcmp(interface, kBlurManagerIface) == 0) {
                d->blurManagerId = name;
                d->blurManagerVersion = version;
            }
        }

        static void onRegistryGlobalRemove(void *, wl_registry *, uint32_t) {
            // no-op
        }

        struct WaylandBlurHandle {
            wl_proxy *blurProxy = nullptr;
        };

        WaylandBlurHandle *waylandBlurCreate(wl_display *display, wl_surface *surface) {
            if (!display || !surface)
                return nullptr;

            const auto &api = waylandAPI();
            if (!api.isValid())
                return nullptr;

            // 1) Get registry
            wl_registry *registry = api.wl_display_get_registry(display);
            if (!registry)
                return nullptr;

            // 2) Add listener to capture global announcements
            RegistryScanData scanData{0, 0};
            WlRegistryListener listener{onRegistryGlobal, onRegistryGlobalRemove};
            if (api.wl_proxy_add_listener(reinterpret_cast<wl_proxy *>(registry),
                                          reinterpret_cast<void (**)(void)>(&listener),
                                          &scanData) < 0) {
                api.wl_proxy_destroy(reinterpret_cast<wl_proxy *>(registry));
                return nullptr;
            }

            // 3) Roundtrip — dispatches pending events including registry globals
            api.wl_display_roundtrip(display);

            if (scanData.blurManagerId == 0) {
                // compositor doesn't support org_kde_kwin_blur_manager
                api.wl_proxy_destroy(reinterpret_cast<wl_proxy *>(registry));
                return nullptr;
            }

            // 4) Bind to blur_manager
            wl_proxy *blurManagerProxy = reinterpret_cast<wl_proxy *>(
                api.wl_registry_bind(registry, scanData.blurManagerId,
                                      nullptr, // we pass nullptr for interface
                                      scanData.blurManagerVersion));
            api.wl_proxy_destroy(reinterpret_cast<wl_proxy *>(registry));

            if (!blurManagerProxy)
                return nullptr;

            // 5) blur_manager::create → get org_kde_kwin_blur proxy
            //    opcode 0, flags=WL_MARSHAL_FLAG_NEW_ID (1)
            constexpr uint32_t kNewIdFlag = 1;

            // wl_proxy is opaque — allocate a generous buffer.
            // A typical wl_proxy is < 128 bytes; 256 is safe.
            constexpr size_t kProxyBufSize = 256;
            auto *blurProxy = static_cast<wl_proxy *>(std::malloc(kProxyBufSize));
            std::memset(blurProxy, 0, kProxyBufSize);

            api.wl_proxy_marshal_flags(
                blurManagerProxy,
                0,                                  // opcode 0 = create
                nullptr,                            // interface (for new_id)
                scanData.blurManagerVersion,
                kNewIdFlag,
                blurProxy,                          // new_id
                reinterpret_cast<wl_proxy *>(surface)); // wl_surface

            // 6) blur::set_region(null) → blur entire window (opcode 0)
            api.wl_proxy_marshal_flags(
                blurProxy,
                0,              // opcode 0 = set_region
                nullptr, 1,     // interface, version
                0,              // no flags
                nullptr);       // null region → full window

            // 7) blur::commit (opcode 1) → apply
            api.wl_proxy_marshal_flags(
                blurProxy,
                1,              // opcode 1 = commit
                nullptr, 1,     // interface, version
                0);             // no flags, no args

            // 8) Done with manager proxy
            api.wl_proxy_destroy(blurManagerProxy);

            api.wl_display_flush(display);

            auto *handle = new WaylandBlurHandle;
            handle->blurProxy = blurProxy;
            return handle;
        }

        void waylandBlurDestroy(WaylandBlurHandle *handle) {
            if (!handle)
                return;
            const auto &api = waylandAPI();
            if (api.isValid() && handle->blurProxy) {
                // blur::release (opcode 2)
                api.wl_proxy_marshal_flags(
                    handle->blurProxy,
                    2,              // opcode 2 = release
                    nullptr, 1,     // interface, version
                    0);             // no flags, no args
                // Release then free the raw-allocated proxy buffer
                std::free(handle->blurProxy);
            }
            delete handle;
        }

    } // namespace Private
} // namespace QWK
#endif // QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
