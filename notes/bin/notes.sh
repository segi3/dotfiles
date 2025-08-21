#!/usr/bin/env bash
set -e

EDITOR=nvim
NOTES_DIR="/home/dans/.notes"

main() {
  previous_file="$1"
  file_to_edit=$(select_file "$previous_file")

  if [ -n "$file_to_edit" ] ; then
    # use full path for the editor
    full_path="$NOTES_DIR/$file_to_edit"

    # create dir structure if it doesnt exists
    dir_path=$(dirname "$full_path")
    mkdir -p "$dir_path"

    "$EDITOR" "$full_path"
    main "$file_to_edit"
  fi
}

select_file() {
  given_file="$1"
  cd "$NOTES_DIR"
  
  # fzf to list notes 
  selection=$(
    find . -type f | sed 's|^\./||' | \
    fzf --preview="cat '$NOTES_DIR'/{}" \
        --preview-window=right:70%:wrap \
        --query="$given_file" \
        --bind="enter:accept" \
        --bind="ctrl-u:preview-page-up" \
        --bind="ctrl-d:preview-page-down" \
        --bind="ctrl-k:preview-up" \
        --bind="ctrl-j:preview-down" \
        --bind="ctrl-n:print-query" \
        --header="Enter: open file | Ctrl+N: create new file with current query" \
        --print-query
  )
  
  # fzf returns query on first line, selection on second line when using --print-query
  query=$(echo "$selection" | head -n1)
  file=$(echo "$selection" | tail -n1)
  
  # <ctrl+n> was pressed or no existing file was selected but query exists
  if [[ "$file" == "$query" ]] && [[ -n "$query" ]] && [[ ! -f "$query" ]]; then
    echo "$query"
  else
    echo "$file"
  fi
}

main ""
