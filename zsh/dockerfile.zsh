# Containerized POV-Ray runner with CA-repair / TLS-bypass fallback
povray-ctn () {
  set -euo pipefail

  _say() { printf "%s\n" "$*" >&2; }
  _err() { printf "ERROR: %s\n" "$*" >&2; }
  _hr()  { printf "%s\n" "----------------------------------------" >&2; }

  # allow non-interactive control (for Tcl etc.)
  # POVRAY_BUILD_MODE = normal | bypass | ca
  # POVRAY_CA_PEM     = /path/to/org-root.pem
  : "${POVRAY_BUILD_MODE:=normal}"
  : "${POVRAY_BASE:=docker.io/library/debian:stable-slim}"  # switch from fedora:40

  # 0) Ensure Podman VM is up
  podman machine start >/dev/null 2>&1 || true

  # 1) Build helper (returns 0 on success)
  _build_image() {
    local tlsflag=${1:-}  # e.g. "--tls-verify=false" or empty
    _say "Building local povray image…"
    # expand ${POVRAY_BASE} inside heredoc with eval
    eval "cat <<'DOCKER'
FROM ${POVRAY_BASE}
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    povray ca-certificates libjpeg62-turbo libpng16-16 zlib1g && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /work
ENTRYPOINT [\"povray\"]
DOCKER" | podman build ${tlsflag:+$tlsflag} -t povray:local -f - .
  }

  # 2) Try to build if image missing
  if ! podman image exists povray:local; then
    case "$POVRAY_BUILD_MODE" in
      bypass) _build_image "--tls-verify=false" || { _err "Bypass build failed."; return 1; } ;;
      ca)
        [[ -f "${POVRAY_CA_PEM:-}" ]] || { _err "POVRAY_CA_PEM not set or missing."; return 1; }
        _say "Installing CA into Podman VM…"
        podman machine scp "$POVRAY_CA_PEM" podman-machine-default:/tmp/org-root.pem
        podman machine ssh 'sudo mkdir -p /etc/pki/ca-trust/source/anchors &&
          sudo install -m 0644 /tmp/org-root.pem /etc/pki/ca-trust/source/anchors/org-root.pem &&
          sudo update-ca-trust &&
          sudo mkdir -p /etc/containers/certs.d/registry-1.docker.io /etc/containers/certs.d/docker.io &&
          sudo cp /etc/pki/ca-trust/source/anchors/org-root.pem /etc/containers/certs.d/registry-1.docker.io/ca.crt &&
          sudo cp /etc/pki/ca-trust/source/anchors/org-root.pem /etc/containers/certs.d/docker.io/ca.crt'
        _build_image || { _err "Build failed after CA install."; return 1; }
        ;;
      normal)
        if _build_image; then
          _say "Image built successfully."
        else
          _hr; _err "Initial build failed."
          set +e
          build_log="$(_build_image 2>&1)"; build_rc=$?
          set -e
          if [[ "$build_log" == *"x509: certificate signed by unknown authority"* || "$build_log" == *"tls: failed to verify certificate"* ]]; then
            _say "TLS/CA trust problem detected while pulling ${POVRAY_BASE}."
            # only prompt if interactive and vared exists
            if [[ -t 0 && -t 1 && $+commands[vared] -eq 1 ]]; then
              vared -p "Bypass TLS verification just for this build? [y/N]: " -c _ans || _ans=n
              [[ ${_ans:l} == y || ${_ans:l} == yes ]] && _build_image "--tls-verify=false" || { _err "Build failed"; return 1; }
            else
              _err "Non-interactive shell. Set POVRAY_BUILD_MODE=bypass to proceed."
              return 1
            fi
          else
            printf "%s\n" "$build_log" >&2
            return $build_rc
          fi
        fi
        ;;
      *) _err "Unknown POVRAY_BUILD_MODE: $POVRAY_BUILD_MODE"; return 2 ;;
    esac
  fi

  # 3) Guard against '-I' or '-O' with spaces
  for bad in "-I" "-O"; do
    if [[ " $* " == *" $bad "* ]]; then
      _err "POV-Ray expects '+I<input.pov>' and '+O<output>' with NO space."
      _say "Example: +Iscene.pov +Oscene.png"
      return 2
    fi
  done

  # 4) Run in current directory as /work; ensure host-writable files
  exec podman run --rm \
    -v "$PWD":/work -w /work \
    --user "$(id -u)":"$(id -g)" \
    povray:local \
    "$@"
}
