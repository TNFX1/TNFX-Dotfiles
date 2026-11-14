import QtQuick
import qs.modules.common
import qs.modules.ii.onScreenDisplay

// local edit: keyboard light OSD (mode, color, bar = brightness 0-3); state comes from OnScreenDisplay root via IPC
OsdValueIndicator {
    id: ind
    readonly property var modes: [
        { name: "Sabit", icon: "keyboard" },
        { name: "Nefes", icon: "air" },
        { name: "Renk döngüsü", icon: "looks" },
        { name: "Yanıp sönme", icon: "flash_on" }
    ]
    implicitWidth: Appearance.sizes.osdWidth + 90 + 2 * Appearance.sizes.elevationMargin // room for "mode  color"
    readonly property int m: root.kbdMode
    readonly property bool cycling: m === 2
    property real hue: 0

    readonly property bool off: root.kbdBrightness === 0

    value: root.kbdBrightness / 3
    icon: off ? "keyboard_off" : modes[m].icon
    name: off ? "Klavye ışığı kapalı" : modes[m].name
    valueText: off || cycling ? "" : root.kbdColorName
    iconColor: cycling ? Qt.hsva(hue, 0.85, 1, 1) : root.kbdColor
    barColor: iconColor
    wavy: m === 1 || cycling

    NumberAnimation on hue {
        running: ind.cycling
        from: 0; to: 1; duration: 2500
        loops: Animation.Infinite
    }
}
