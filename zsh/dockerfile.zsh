# Containerized POV-Ray runner with CA-repair / TLS-bypass fallback
povray-ctn () {
  set -euo pipefail

  _say() { printf "%s\n" "$*" >&2; }
  _err() { printf "ERROR: %s\n" "$*" >&2; }

  : "${POVRAY_BUILD_MODE:=normal}"                       # normal | bypass | ca
  : "${POVRAY_BASE:=docker.io/library/debian:stable-slim}"

  # Ensure Podman VM is up
  podman machine start >/dev/null 2>&1 || true

  _build_image() {
    local tlsflag=${1:-}   # e.g. "--tls-verify=false"
    _say "Building local povray image…"
    cat <<DOCKER | podman build ${tlsflag:+$tlsflag} -t povray:local -f - .
FROM ${POVRAY_BASE}
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    povray ca-certificates libjpeg62-turbo libpng16-16 zlib1g && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /work
ENTRYPOINT ["povray"]
DOCKER
  }

  # Build if missing
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
        if ! _build_image; then
          # detect TLS error and offer one-time bypass (only if interactive)
          local log rc
          set +e
          log="$(_build_image 2>&1)"; rc=$?
          set -e
          if [[ "$log" == *"x509: certificate signed by unknown authority"* || "$log" == *"tls: failed to verify certificate"* ]]; then
            if [[ -t 0 && -t 1 ]]; then
              read -r "?TLS error pulling ${POVRAY_BASE}. Bypass TLS just for this build? [y/N]: " ans
              [[ ${ans:l} == y || ${ans:l} == yes ]] && _build_image "--tls-verify=false" || { _err "Build failed."; return 1; }
            else
              _err "TLS error. Re-run with POVRAY_BUILD_MODE=bypass for non-interactive build."
              return 1
            fi
          else
            printf "%s\n" "$log" >&2
            return $rc
          fi
        fi
        ;;
      *) _err "Unknown POVRAY_BUILD_MODE: $POVRAY_BUILD_MODE"; return 2 ;;
    esac
  fi

  # Guard against '-I'/'-O' with a space
  for bad in "-I" "-O"; do
    [[ " $* " == *" $bad "* ]] && { _err "Use +I<input> and +O<output> with NO space."; return 2; }
  done

  # Run (no exec → your shell stays alive)
  # set +e
  # podman run --rm \
  #   -v "$PWD":/work -w /work \
  #   --user "$(id -u)":"$(id -g)" \
  #   povray:local \
  #   "$@"
  # rc=$?
  # set -e
  # return $rc
}
