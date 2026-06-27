#!/usr/bin/env bash
set -euo pipefail

while IFS= read -r -d '' icon; do
  svg="$(tr -d '\n' < "$icon")"

  if [[ ! "$svg" =~ viewBox=\"0[[:space:]]+0[[:space:]]+([0-9.]+)[[:space:]]+([0-9.]+)\" ]]; then
    continue
  fi

  width="${BASH_REMATCH[1]}"
  height="${BASH_REMATCH[2]}"

  if [[ "$width" == "24" && "$height" == "24" ]]; then
    continue
  fi

  inner="${svg#*>}"
  inner="${inner%</svg>}"
  scale_x="$(awk -v width="$width" 'BEGIN { printf "%.8g", 24 / width }')"
  scale_y="$(awk -v height="$height" 'BEGIN { printf "%.8g", 24 / height }')"

  if [[ "$scale_x" == "$scale_y" ]]; then
    transform="scale($scale_x)"
  else
    transform="scale($scale_x $scale_y)"
  fi

  printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><g transform="%s">%s</g></svg>\n' "$transform" "$inner" > "$icon"
done < <(find _components/icon -type f -name '*.svg' -print0)
