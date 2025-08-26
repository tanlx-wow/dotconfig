# Containerized POV-Ray runner with CA-repair / TLS-bypass fallback
povray-ctn () {
  set -euo pipefail

  _say() { printf "%s\n" "$*" >&2; }
  _err() { printf "ERROR: %s\n" "$*" >&2; }
  _hr()  { printf "%s\n" "----------------------------------------" >&2; }

  # 0) Ensure Podman VM is up
  podman machine start >/dev/null 2>&1 || true

  # 1) Build helper (returns 0 on success)
  _build_image() {
    local tlsflag=${1:-}  # e.g. "--tls-verify=false" or empty
    _say "Building local povray image…"
    podman build ${tlsflag:+$tlsflag} -t povray:local - <<'EOF'
FROM registry.fedoraproject.org/fedora:40
RUN dnf -y install povray && dnf clean all
WORKDIR /work
ENTRYPOINT ["povray"]
EOF
  }

  # 2) Try to build if image missing
  if ! podman image exists povray:local; then
    if _build_image; then
      _say "Image built successfully."
    else
      _hr
      _err "Initial build failed."
      # Capture last build log to detect TLS/CA issue
      # Re-run once to capture stderr (no -e in this subshell)
      set +e
      build_log="$( ( _build_image 2>&1 ) )"
      build_rc=$?
      set -e
      if [[ $build_log == *"x509: certificate signed by unknown authority"* \
         || $build_log == *"tls: failed to verify certificate"* \
         || $build_log == *"certificate"* ]]; then
        _say "It looks like a TLS/CA trust problem when pulling base images."
        _hr
        # Ask to install a corporate/root CA into the Podman VM
        vared -p "Install a root CA into the Podman VM to fix trust? [y/N]: " -c _ans_ca || _ans_ca=n
        _ans_ca=${_ans_ca:l}
        if [[ $_ans_ca == y || $_ans_ca == yes ]]; then
          # Ask for PEM path
          local pem
          vared -p "Path to your root/intercepting CA PEM (e.g., /path/to/org-root.pem): " -c pem
          if [[ -f "$pem" ]]; then
            _say "Installing CA into Podman VM…"
            podman machine scp "$pem" podman-machine-default:/tmp/org-root.pem
            podman machine ssh 'sudo mkdir -p /etc/pki/ca-trust/source/anchors &&
              sudo install -m 0644 /tmp/org-root.pem /etc/pki/ca-trust/source/anchors/org-root.pem &&
              sudo update-ca-trust &&
              sudo mkdir -p /etc/containers/certs.d/registry-1.docker.io /etc/containers/certs.d/docker.io &&
              sudo cp /etc/pki/ca-trust/source/anchors/org-root.pem /etc/containers/certs.d/registry-1.docker.io/ca.crt &&
              sudo cp /etc/pki/ca-trust/source/anchors/org-root.pem /etc/containers/certs.d/docker.io/ca.crt'
            _say "CA installed. Retrying build…"
            _build_image || { _err "Build still failed after CA install."; return 1; }
          else
            _err "PEM file not found: $pem"
            return 1
          fi
        else
          # Ask to bypass TLS
          vared -p "Bypass TLS verification just for this build? [y/N]: " -c _ans_tls || _ans_tls=n
          _ans_tls=${_ans_tls:l}
          if [[ $_ans_tls == y || $_ans_tls == yes ]]; then
            _say "Retrying build with --tls-verify=false (one-time bypass)…"
            _build_image "--tls-verify=false" || { _err "Bypass build failed."; return 1; }
          else
            _err "Aborting. You can rerun after adding CA trust or choose TLS bypass."
            return 1
          fi
        fi
      else
        _err "Build failed for a non-TLS reason. Last log:"
        printf "%s\n" "$build_log" >&2
        return 1
      fi
    fi
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
