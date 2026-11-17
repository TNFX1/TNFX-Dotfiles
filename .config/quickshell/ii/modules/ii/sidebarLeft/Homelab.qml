pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// LOCAL ADDITION (not in dots): home server (CasaOS) status for the left sidebar.
// Stats come over `ssh sunucu-stats` (~/.ssh/config); its key can only run ~/homelab-stats.sh on the server.
Item {
    id: root

    readonly property string host: "192.168.1.3"
    readonly property var services: [
        { id: "casaos", name: "CasaOS", icon: "home_storage", port: 80 },
        { id: "immich", name: "Immich", icon: "photo_library", port: 2283 },
        { id: "searxng", name: "SearXNG", icon: "search", port: 8080, path: "healthz" }, // "/" counts toward SearXNG's rate limiter
        { id: "nextcloud", name: "Nextcloud", icon: "cloud", port: 7580 },
        { id: "kuma", name: "Uptime Kuma", icon: "monitor_heart", port: 3002 },
        { id: "vault", name: "Vaultwarden", icon: "key", port: 8444, https: true, path: "alive" }, // Caddy, self-signed Homelab CA
        { id: "dns", name: "AdGuard Home", icon: "shield", port: 53, webPort: 7200 }, // checked via DNS query, UI on webPort
    ]
    property var status: ({}) // id -> { ok: bool, ms: int }
    property bool checking: false
    property string lastCheck: ""
    readonly property bool online: status.ping?.ok ?? false

    function check() {
        if (checking) return;
        checking = true;
        checker.buffer = {};
        checker.running = true;
        if (!stats.running) { stats.buffer = {}; stats.running = true; }
    }

    property var sys: ({}) // key -> [numbers], from the server over SSH
    function pct(a) { return a && a[1] > 0 ? a[0] / a[1] : 0; }
    function gb(b) { return (b / 1e9).toFixed(b < 1e10 ? 1 : 0); }
    function uptime(sec) {
        const d = Math.floor(sec / 86400), h = Math.floor(sec % 86400 / 3600), m = Math.floor(sec % 3600 / 60);
        return d > 0 ? `${d} g ${h} sa` : h > 0 ? `${h} sa ${m} dk` : `${m} dk`;
    }

    // Each line: "<key> <n> [<n>]"
    Process {
        id: stats
        property var buffer: ({})
        // Key is locked to ~/homelab-stats.sh on the server (forced command in authorized_keys), so no remote command is sent
        command: ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=5", "sunucu-stats"]
        stdout: SplitParser {
            onRead: line => {
                const [k, ...v] = line.trim().split(/ +/);
                stats.buffer[k] = v.map(Number);
            }
        }
        onExited: (code) => root.sys = code === 0 ? stats.buffer : {}
    }

    // Each line: "<id> <ok 0|1> <ms>"
    Process {
        id: checker
        property var buffer: ({})
        command: ["bash", "-c", `
            export LC_ALL=C # ping prints "süre=" under Turkish locale
            h='${root.host}'
            ms() { awk -v t="$1" 'BEGIN{printf "%d", t*1000}'; }
            http() { r=$(curl -sk -o /dev/null -m 3 -w '%{http_code} %{time_total}' "$3://$h:$2/$4"); c=\${r%% *}; case $c in [234]??) o=1;; *) o=0;; esac; echo "$1 $o $(ms \${r#* })"; }
            ( p=$(ping -c1 -W1 "$h" | sed -n 's/.*time=\\([0-9.]*\\).*/\\1/p'); [ -n "$p" ] && echo "ping 1 \${p%.*}" || echo "ping 0 0" ) &
            ( s=$(date +%s%N); a=$(dig +short +time=2 +tries=1 @"$h" example.com A); e=$(( ($(date +%s%N)-s)/1000000 )); [ -n "$a" ] && echo "dns 1 $e" || echo "dns 0 0" ) &
            ${root.services.filter(s => s.id !== "dns").map(s => `http ${s.id} ${s.port} ${s.https ? "https" : "http"} ${s.path ?? ""} &`).join("\n")}
            wait`]
        stdout: SplitParser {
            onRead: line => {
                const [id, ok, ms] = line.trim().split(" ");
                checker.buffer[id] = { ok: ok === "1", ms: parseInt(ms) || 0 };
            }
        }
        onExited: {
            root.status = checker.buffer;
            root.lastCheck = Qt.formatTime(new Date(), "HH:mm:ss");
            root.checking = false;
        }
    }

    Timer {
        // Only poll while this tab is on screen
        running: root.visible && (root.SwipeView.isCurrentItem ?? true) && (root.QsWindow.window?.visible ?? true)
        interval: 30000
        repeat: true
        triggeredOnStart: true
        onTriggered: root.check()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Server header
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: header.implicitHeight + 24
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer2

            RowLayout {
                id: header
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12
                MaterialSymbol {
                    text: "dns"
                    iconSize: 32
                    color: root.online ? Appearance.colors.colPrimary : Appearance.colors.colError
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        text: "Ev sunucusu"
                        font.pixelSize: Appearance.font.pixelSize.large
                    }
                    StyledText {
                        text: root.lastCheck === "" ? "Kontrol ediliyor…"
                            : root.online ? `Çevrimiçi · ${root.host} · ${root.status.ping.ms} ms`
                            : `Ulaşılamıyor · ${root.host}`
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                }
                RippleButton {
                    implicitWidth: 36
                    implicitHeight: 36
                    buttonRadius: Appearance.rounding.full
                    onClicked: root.check()
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        text: "refresh"
                        iconSize: 22
                        rotation: root.checking ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 400 } }
                    }
                    StyledToolTip { text: "Yenile" }
                }
            }
        }

        // System card (hidden until the SSH stats arrive)
        Rectangle {
            visible: root.sys.mem !== undefined
            Layout.fillWidth: true
            implicitHeight: sysCol.implicitHeight + 24
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer2

            ColumnLayout {
                id: sysCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6
                Repeater {
                    model: [
                        { icon: "memory", name: "İşlemci yükü", v: root.sys.load ? root.sys.load[0] / root.sys.load[1] : 0,
                          text: root.sys.load ? `${root.sys.load[0].toFixed(2)} / ${root.sys.load[1]} çekirdek` : "" },
                        { icon: "memory_alt", name: "RAM", v: root.pct(root.sys.mem),
                          text: root.sys.mem ? `${root.gb(root.sys.mem[0])} / ${root.gb(root.sys.mem[1])} GB` : "" },
                        { icon: "hard_drive", name: "Disk", v: root.pct(root.sys.disk),
                          text: root.sys.disk ? `${root.gb(root.sys.disk[0])} / ${root.gb(root.sys.disk[1])} GB` : "" },
                    ]
                    delegate: ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 2
                        RowLayout {
                            Layout.fillWidth: true
                            MaterialSymbol { text: modelData.icon; iconSize: 18; color: Appearance.colors.colOnLayer1 }
                            StyledText { Layout.fillWidth: true; text: modelData.name; color: Appearance.colors.colOnLayer1 }
                            StyledText { text: modelData.text; color: Appearance.colors.colSubtext; font.pixelSize: Appearance.font.pixelSize.smaller }
                        }
                        StyledProgressBar {
                            Layout.fillWidth: true
                            value: Math.min(modelData.v, 1)
                            highlightColor: modelData.v > 0.85 ? Appearance.colors.colError : Appearance.colors.colPrimary
                        }
                    }
                }
                StyledText {
                    Layout.fillWidth: true
                    Layout.topMargin: 2
                    text: [
                        root.sys.up ? `Açık ${root.uptime(root.sys.up[0])}` : "",
                        root.sys.temp?.[0] > 0 ? `${Math.round(root.sys.temp[0] / 1000)}°C` : "",
                        root.sys.ctr ? `Konteyner ${root.sys.ctr[0]}/${root.sys.ctr[1]}` : "",
                    ].filter(x => x).join(" · ")
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }

        StyledText {
            text: "Servisler"
            color: Appearance.colors.colPrimary
        }

        Repeater {
            model: root.services
            delegate: RippleButton {
                id: row
                required property var modelData
                readonly property var st: root.status[modelData.id]
                Layout.fillWidth: true
                implicitHeight: 48
                onClicked: Quickshell.execDetached(["xdg-open", `${modelData.https ? "https" : "http"}://${root.host}:${modelData.webPort ?? modelData.port}/`])
                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    MaterialSymbol {
                        text: row.modelData.icon
                        iconSize: 22
                        color: Appearance.colors.colOnLayer1
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        StyledText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            text: row.modelData.name
                            color: Appearance.colors.colOnLayer1
                        }
                        StyledText {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            text: `:${row.modelData.port}` + (row.st?.ok ? ` · ${row.st.ms} ms` : "")
                            color: Appearance.colors.colSubtext
                            font.pixelSize: Appearance.font.pixelSize.smaller
                        }
                    }
                    Rectangle {
                        implicitWidth: 10
                        implicitHeight: 10
                        radius: 5
                        color: row.st === undefined ? Appearance.colors.colSubtext
                            : row.st.ok ? Appearance.colors.colPrimary : Appearance.colors.colError
                    }
                    MaterialSymbol {
                        text: "open_in_new"
                        iconSize: 18
                        color: Appearance.colors.colSubtext
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        StyledText {
            Layout.fillWidth: true
            text: root.lastCheck === "" ? "" : `Son kontrol ${root.lastCheck} · 30 sn'de bir`
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.smaller
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
