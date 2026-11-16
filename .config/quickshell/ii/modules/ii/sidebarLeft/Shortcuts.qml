pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

// LOCAL ADDITION (not in dots): searchable keybind list for the left sidebar.
Item {
    id: root

    property var keyNames: ({
        "code:211": "Fn+F4", "Return": "Enter", "Period": ".", "Slash": "/", "Escape": "Esc",
        "mouse:272": "Sol tık", "mouse:273": "Sağ tık", "mouse_up": "Tekerlek ↓", "mouse_down": "Tekerlek ↑",
        "SUPER_L": "", "SUPER_R": ""
    })

    function combo(bind) {
        const mods = [];
        if (bind.modmask & (1 << 2)) mods.push("Ctrl");
        if (bind.modmask & (1 << 6)) mods.push("Super");
        if (bind.modmask & (1 << 0)) mods.push("Shift");
        if (bind.modmask & (1 << 3)) mods.push("Alt");
        const key = root.keyNames[bind.key] ?? bind.key;
        if (key.length > 0) mods.push(key);
        return mods.join(" + ");
    }

    property var binds: {
        const q = searchField.text.trim().toLowerCase();
        const seen = new Set();
        return HyprlandKeybinds.keybinds
            .filter(b => b.description?.length > 0)
            .map(b => {
                const i = b.description.indexOf(":");
                return {
                    category: i > 0 ? b.description.substring(0, i) : "Diğer",
                    text: i > 0 ? b.description.substring(i + 1).trim() : b.description,
                    combo: root.combo(b)
                };
            })
            .filter(b => {
                const id = b.combo + b.text; // same bind registered twice (e.g. SUPER+V)
                if (seen.has(id)) return false;
                seen.add(id);
                return q.length === 0 || (b.category + " " + b.text + " " + b.combo).toLowerCase().includes(q);
            })
            .sort((a, b) => a.category.localeCompare(b.category));
    }

    onFocusChanged: focus => { if (focus) searchField.forceActiveFocus(); }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        MaterialTextField {
            id: searchField
            Layout.fillWidth: true
            placeholderText: "Kısayol ara…"
            wrapMode: TextEdit.NoWrap
            Keys.onEscapePressed: text = ""
        }

        StyledListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: root.binds
            delegate: ColumnLayout {
                id: row
                required property var modelData
                required property int index
                width: ListView.view.width
                spacing: 2
                StyledText {
                    visible: row.index === 0 || root.binds[row.index - 1].category !== row.modelData.category
                    topPadding: row.index === 0 ? 0 : 10
                    text: row.modelData.category
                    color: Appearance.colors.colPrimary
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    StyledText {
                        Layout.fillWidth: true
                        text: row.modelData.text
                        wrapMode: Text.Wrap
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                    KeyboardKey {
                        key: row.modelData.combo
                        visible: row.modelData.combo.length > 0
                    }
                }
            }
        }

        StyledText {
            visible: root.binds.length === 0
            Layout.alignment: Qt.AlignHCenter
            text: "Eşleşen kısayol yok"
            color: Appearance.colors.colSubtext
        }
    }
}
