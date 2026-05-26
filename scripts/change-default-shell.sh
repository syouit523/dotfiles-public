#!/bin/bash

select_shell_noninteractive() {
  local target="$1"
  local found
  found=$(grep -E "^[^#]" /etc/shells | grep -E "/${target}$" | head -n1)
  if [ -z "$found" ]; then
    found=$(command -v "$target" 2>/dev/null)
  fi
  echo "$found"
}

if [ -n "$DEFAULT_SHELL" ]; then
  selected_shell=$(select_shell_noninteractive "$DEFAULT_SHELL")
  if [ -z "$selected_shell" ]; then
    echo "DEFAULT_SHELL=$DEFAULT_SHELL not found in /etc/shells. Skipping."
    exit 0
  fi
  echo "Using DEFAULT_SHELL: $selected_shell"
elif [ "$NONINTERACTIVE" = "1" ]; then
  echo "NONINTERACTIVE: DEFAULT_SHELL not set, skipping shell change."
  exit 0
else
  tmpfile=$(mktemp /tmp/available_shells.XXXXXX)
  cat /etc/shells > "$tmpfile"

  echo "Current shell: $SHELL"
  echo -e "\nAvailable shells:"

  counter=1
  while IFS= read -r shell; do
    echo "$shell" | grep -q '^#' && continue
    [ -z "$shell" ] && continue
    echo "$counter) $shell"
    eval "shell_$counter=\"$shell\""
    counter=$((counter + 1))
  done < "$tmpfile"
  rm -f "$tmpfile"

  echo -e "\nEnter the number of the shell you want to set as default:"
  read -r choice
  eval "selected_shell=\"\$shell_$choice\""
fi

if [ -n "$selected_shell" ]; then
  if sudo -n chsh -s "$selected_shell" "$USER"; then
    echo "Default shell changed to $selected_shell"
    echo "You need to log out and log back in for changes to take effect"
  else
    echo "Failed to change shell"
  fi
else
  echo "Invalid selection"
fi
