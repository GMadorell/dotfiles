#!/bin/zsh
# VPN service aliases: Pritunl

# VPN / Pritunl
alias pritunl-client="/Applications/Pritunl.app/Contents/Resources/pritunl-client"
alias pritunl=pritunl-client
pritunlpick() {
  local selected id
  selected=$(
    pritunl list | awk '
      $0 ~ /^\+/ { next }
      $0 ~ /^\|[[:space:]]*ID[[:space:]]*\|/ { next }

      function flush(    label) {
        if (cur_id == "") return
        if (match(cur_extra, /\([^)]*\)/)) {
          label = substr(cur_extra, RSTART, RLENGTH)
        } else if (match(cur_name, /\([^)]*\)/)) {
          label = substr(cur_name, RSTART, RLENGTH)
        } else {
          label = cur_extra != "" ? cur_extra : cur_name
        }
        if (label == "" || label == "-") label = "(" cur_name ")"
        print cur_id " " label
        cur_id = ""; cur_name = ""; cur_extra = ""
      }

      $0 ~ /^\|/ {
        n = split($0, c, "|")
        for (i=1; i<=n; i++) gsub(/^[ \t]+|[ \t]+$/, "", c[i])

        id = c[2]
        name = c[3]

        if (id != "") {
          flush()
          cur_id = id
          cur_name = name
          cur_extra = ""
        } else if (cur_id != "") {
          cur_extra = name
        }
      }

      END { flush() }
    ' | percol --prompt='<green>Select Pritunl profile:</green> %q'
  )

  echo "$selected"  # outputs "id label"
}

# Show the currently active profile (ID + label)
vpnactive() {
  pritunl list | awk '
    $0 ~ /^\+/ { next }
    $0 ~ /^\|[[:space:]]*ID[[:space:]]*\|/ { next }

    $0 ~ /^\|/ {
      n = split($0, c, "|")
      for (i=1; i<=n; i++) gsub(/^[ \t]+|[ \t]+$/, "", c[i])

      id = c[2]
      name = c[3]
      state = c[4]  # STATE column

      if (id != "") {
        cur_id = id
        cur_name = name
        cur_state = state
        next
      }

      if (cur_id != "" && cur_state == "Active") {
        if (match(name, /\([^)]*\)/)) label = substr(name, RSTART, RLENGTH)
        else if (match(cur_name, /\([^)]*\)/)) label = substr(cur_name, RSTART, RLENGTH)
        else label = cur_name

        print cur_id " " label
        found = 1
        exit
      }

      cur_id = ""
      cur_name = ""
      cur_state = ""
    }
    END {
      if (!found) print "No active Pritunl profile"
    }
  '
}

# Connect: stop any active profile, then start the selected one
# Usage: vpnon [ovpn|wg]
vpnon() {
  local mode="${1:-ovpn}"
  local selected id label

  selected=$(pritunlpick)
  [[ -z "$selected" ]] && return 1
  id="${selected%% *}"
  label="${selected#* }"

  echo "→ Disconnecting any active profile…"
  # Best-effort: stop all Active profiles (should be 0/1)
  pritunl list | awk -F'|' '
    $0 ~ /^\|/ {
      gsub(/^[ \t]+|[ \t]+$/, "", $2)
      gsub(/^[ \t]+|[ \t]+$/, "", $4)  # STATE
      if ($2 != "" && $4 == "Active") print $2
    }' | while read -r pid; do
      pritunl stop "$pid" >/dev/null 2>&1 || true
    done

  echo "→ Connecting $label (mode=$mode)"
  pritunl start "$id" --mode="$mode"
}

# Disconnect: stop the currently active profile
vpnoff() {
  local active_line active_id active_label
  active_line=$(
    pritunl list | awk '
      $0 ~ /^\+/ { next }
      $0 ~ /^\|[[:space:]]*ID[[:space:]]*\|/ { next }

      function flush(    label) {
        if (cur_id == "" || cur_state != "Active") {
          cur_id = ""; cur_name = ""; cur_state = ""; cur_extra = ""; return
        }
        if (match(cur_extra, /\([^)]*\)/)) label = substr(cur_extra, RSTART, RLENGTH)
        else if (match(cur_name, /\([^)]*\)/)) label = substr(cur_name, RSTART, RLENGTH)
        else label = cur_extra != "" ? cur_extra : cur_name
        if (label == "" || label == "-") label = "(" cur_name ")"
        print cur_id " " label
      }

      $0 ~ /^\|/ {
        n = split($0, c, "|")
        for (i=1; i<=n; i++) gsub(/^[ \t]+|[ \t]+$/, "", c[i])
        id = c[2]; name = c[3]; state = c[4]
        if (id != "") {
          flush()
          cur_id = id; cur_name = name; cur_state = state; cur_extra = ""
        } else if (cur_id != "") {
          cur_extra = name
        }
      }
      END { flush() }
    '
  )

  if [[ -z "$active_line" ]]; then
    echo "No active Pritunl profile"
    return 0
  fi

  active_id="${active_line%% *}"
  active_label="${active_line#* }"

  echo "→ Disconnecting $active_label"
  pritunl stop "$active_id"
}
