# home-manager/zsh/init-extra.zsh

# POV-Ray via Podman helper (pulls image if missing)
povray-ctn () {
  podman machine start >/dev/null 2>&1 || true
  local IMG="docker.io/bradleybossard/docker-povray"
  if ! podman image exists "$IMG"; then
    podman pull "$IMG" || return $?
  fi
  podman run --rm -v "$PWD":/work -w /work "$IMG" povray "$@"
}
# your other shell functions/aliases go here...
