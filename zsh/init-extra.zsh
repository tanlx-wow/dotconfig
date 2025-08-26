# dotconfig_repo/zsh/init-extra.zsh
# --- extra zsh helpers ---

# Optional proxy pass-through for the Podman VM (uncomment & edit if you need it)
# export HTTP_PROXY="http://snowman.ornl.gov:3128"
# export HTTPS_PROXY="$HTTP_PROXY"
# export NO_PROXY="localhost,127.0.0.1,::1"

# Containerized POV-Ray runner
povray-ctn () {
  # Ensure Podman VM is up
  podman machine start >/dev/null 2>&1 || true

  # Ensure we have the local image; build it on demand (no network auth needed)
  if ! podman image exists povray:local; then
    echo "Building local povray image… (first run only)"
    podman build -t povray:local - <<'EOF' || { echo "Build failed"; return 1; }
FROM debian:stable-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends povray \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /work
ENTRYPOINT ["povray"]
EOF
  fi

  # Basic guidance if the user passed -I/-O with spaces (POV-Ray requires +Ifoo +Obar)
  for bad in "-I" "-O"; do
    if [[ " $* " == *" $bad "* ]]; then
      echo "Error: POV-Ray expects '+I<input.pov>' and '+O<output>' with NO space."
      echo "       Example: +Iscene.pov +Oscene.png"
      return 2
    fi
  done

  # Optional: mount a host povray.conf to silence warnings (uncomment to use)
  # mkdir -p "$HOME/.povray/3.7"
  # : > "$HOME/.povray/3.7/povray.conf"

  # Run in current directory mounted as /work
  exec podman run --rm \
    -v "$PWD":/work -w /work \
    # -v "$HOME/.povray/3.7":/root/.povray/3.7:ro \
    povray:local \
    "$@"
}

# If you prefer just typing `povray`, uncomment:
# alias povray='povray-ctn'

