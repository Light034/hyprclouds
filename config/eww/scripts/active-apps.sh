#!/bin/bash

default_fields=( "view-id" "client-pid" "output" "workspace" "app-id" "title" "role" "geometry" "xwayland" "focused" "icon-path" "desktop" )
selected_fields=()

if [ "$#" -eq 0 ]; then
    selected_fields=("${default_fields[@]}")
else
    for arg in "$@"; do
        field=$(echo "$arg" | sed 's/^--//' | tr '[:upper:]' '[:lower:]')
        selected_fields+=("$field")
    done
fi

if [ ! -f "$HOME/.cache/installed_apps.json" ]; then
    echo "Error: $HOME/.cache/installed_apps.json not found." >&2
    exit 1
fi
installed_apps=$(cat "$HOME/.cache/installed_apps.json")

trim() {
    echo "$1" | sed 's/^ *//;s/ *$//'
}

output_json="[]"
current_block=""

while IFS= read -r line; do
    if [[ "$line" =~ ^=+$ ]]; then
        if [ -n "$current_block" ]; then
            declare -A block_data
            while IFS= read -r blk_line; do
                [ -z "$blk_line" ] && continue
                key=$(echo "$blk_line" | cut -d':' -f1 | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
                value=$(echo "$blk_line" | cut -d':' -f2- | sed 's/^ //')
                block_data["$key"]="$value"
            done <<< "$current_block"

            if [ "${block_data[role]}" == "TOPLEVEL" ] && [ "${block_data[app-id]}" != "nil" ]; then
                echo "Processing app: ${block_data[app-id]}"
                app_id="${block_data[app-id]}"
                match=$(echo "$installed_apps" | jq --arg appid "$app_id" 'map(select(.name | test($appid; "i"))) | .[0]')
                icon_path=$(echo "$match" | jq -r '.icon')
                desktop=$(echo "$match" | jq -r '.desktop')
                block_data["icon-path"]="$icon_path"
                block_data["desktop"]="$desktop"

                echo "Collected Data:"
                for key in "${!block_data[@]}"; do
                    echo "$key: ${block_data[$key]}"
                done

                json_obj="{"
                first=1
                for field in "${selected_fields[@]}"; do
                    value="${block_data[$field]}"
                    if [ -n "$value" ]; then
                        if [ $first -eq 0 ]; then
                            json_obj+=","
                        fi
                        esc_value=$(echo "$value" | sed 's/\"/\\\\\"/g')
                        json_obj+="\"$field\":\"$esc_value\""
                        first=0
                    fi
                done
                json_obj+="}"
                output_json=$(echo "$output_json" | jq --argjson new "$json_obj" '. + [$new]')
            fi
            current_block=""
            unset block_data
        fi
    else
        current_block+="$line"$'\n'
    fi
done < <(wf-info -l)

echo "$output_json" | jq .
