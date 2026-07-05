APP="Omniwm"

find \
  /Applications \
  "$HOME/Applications" \
  "$HOME/.nix-profile/Applications" \
  "/nix/var/nix/profiles/per-user/$USER/profile/Applications" \
  -maxdepth 3 -type d -iname "*${APP}*.app" -prune -print 2>/dev/null
