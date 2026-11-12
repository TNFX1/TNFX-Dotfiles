import QtQuick
import Quickshell.Services.UPower
import qs.modules.ii.onScreenDisplay

OsdValueIndicator {
    readonly property int p: PowerProfiles.profile
    value: p === PowerProfile.PowerSaver ? 1 / 3 : p === PowerProfile.Balanced ? 2 / 3 : 1
    icon: p === PowerProfile.PowerSaver ? "eco" : p === PowerProfile.Balanced ? "balance" : "bolt"
    scaleIcon: true
    name: p === PowerProfile.PowerSaver ? "Güç tasarrufu" : p === PowerProfile.Balanced ? "Dengeli" : "Performans"
    valueText: ""
}
