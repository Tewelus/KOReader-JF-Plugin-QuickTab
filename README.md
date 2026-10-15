# KOReader-JF-Plugin-QuickTab

A small [KOReader](https://github.com/koreader/koreader) user patch that adds a dedicated top-menu tab for **Browse Books** from Declan Chidlow's community [KOReader-Jellyfin-Plugin](https://github.com/DeclanChidlow/KOReader-Jellyfin-Plugin).

**This patch does not implement Jellyfin connectivity.** All Jellyfin integration, authentication, browsing, and downloads are provided by Declan Chidlow's plugin. QuickTab only makes its existing **Browse Books** action available from KOReader's top menu in the file manager.

## Requirements

- KOReader with user-patch support.
- [KOReader-Jellyfin-Plugin](https://github.com/DeclanChidlow/KOReader-Jellyfin-Plugin) installed and configured.
- A working Jellyfin connection in that plugin to browse books.

Tested with **KOReader v2026.07.1** on two **Kindle 4 Non-Touch** devices. Compatibility with other KOReader versions and devices has not yet been verified.

## Installation

1. Install and configure Declan Chidlow's KOReader-Jellyfin-Plugin first. Confirm that its **Browse Books** command works.
2. Copy [`2-jellyfin-tab.lua`](2-jellyfin-tab.lua) to `koreader/patches/` on your KOReader device.
3. Copy [`icons/quicktab-fin.svg`](icons/quicktab-fin.svg) to `koreader/icons/` on your KOReader device. Keep the filename `quicktab-fin.svg`. The patch uses its own icon and does not replace or modify any existing Jellyfin icon.
4. Restart KOReader and open the file manager's top menu. Use the new tab to choose **Browse Jellyfin Books**.


## Tests

Run from the repository root (with Lua installed):

```sh
lua tests/test_quicktab.lua
luac -p 2-jellyfin-tab.lua
```

The six automated regression tests cover normal menu registration, reordered Jellyfin menu items, a missing Jellyfin plugin, repeated menu builds, the custom QuickTab icon, and preservation of the original Jellyfin menu. Real-device testing has also been completed successfully on two Kindle 4 Non-Touch devices.

## Scope and limitations

- Provides a shortcut only in KOReader's **file manager**, not in the reader interface.
- Depends on the existing plugin exposing its **Browse Books** menu action. Upstream changes to that action or KOReader's menu internals could require an update.
- This is an independent community patch and is **not affiliated with or endorsed by Jellyfin, KOReader, or the KOReader-Jellyfin-Plugin author**.

## Upstream integration

This project is intentionally small. If the maintainer of KOReader-Jellyfin-Plugin would like to integrate the shortcut, that would be welcome. The intent is to make access easier, not to maintain a competing Jellyfin integration.

## License

See [LICENSE](LICENSE). The QuickTab icon is original artwork created for this project; it does not use Jellyfin's official logo.
