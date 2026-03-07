# find ./* -type l | while read -r link; do
#   echo "$link -> $(realpath "$link")"
# done >saved_symlinks.txt

while read -r line; do
  # Extract the link path (everything before " -> ")
  link="${line%% -> *}"

  # Extract the absolute target path (everything after " -> ")
  target="${line##* -> }"

  # Print what the command WOULD do
  echo "Would run: ln -srf \"$target\" \"$link\""
  ln -srf "$target" "$link"

done <saved_symlinks.txt
