{
  description = "Rizer Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustToolchain
            git
            pre-commit
            nodejs
            glow
            just
            jq
          ];

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

          shellHook = ''
            # Create local dependency directories
            mkdir -p .dependencies/nodejs
            mkdir -p .dependencies/rust

            # Configure Node.js/npm to use local directory
            export NPM_CONFIG_PREFIX="$PWD/.dependencies/nodejs"
            export NPM_CONFIG_CACHE="$PWD/.dependencies/nodejs/cache"
            export NODE_PATH="$PWD/.dependencies/nodejs/lib/node_modules"
            export PATH="$PWD/.dependencies/nodejs/bin:$PATH"

            # Configure Cargo to use local directory
            export CARGO_HOME="$PWD/.dependencies/rust/cargo"
            export RUSTUP_HOME="$PWD/.dependencies/rust/rustup"
            export PATH="$PWD/.dependencies/rust/cargo/bin:$PATH"

            CARGO_AUDIT_VERSION="0.22.0"
            CARGO_NEXTEST_VERSION="0.9.122"
            CARGO_MUTANTS_VERSION="26.1.2"

            mkdir -p $NPM_CONFIG_PREFIX
            mkdir -p $NPM_CONFIG_CACHE
            mkdir -p $NODE_PATH
            mkdir -p $CARGO_HOME
            mkdir -p $RUSTUP_HOME


            # Check cargo-nextest version
            if ! command -v cargo-nextest >/dev/null 2>&1 || [ "$(cargo-nextest --version 2>/dev/null | awk '{print $2}')" != "$CARGO_NEXTEST_VERSION" ]; then
              echo "Installing cargo-nextest $CARGO_NEXTEST_VERSION"
              cargo install cargo-nextest --version "$CARGO_NEXTEST_VERSION" --locked
            fi

            # Check cargo-audit version
            if ! command -v cargo-audit >/dev/null 2>&1 || [ "$(cargo-audit --version 2>/dev/null | awk '{print $2}')" != "$CARGO_AUDIT_VERSION" ]; then
              echo "Installing cargo-audit $CARGO_AUDIT_VERSION"
              cargo install cargo-audit --version "$CARGO_AUDIT_VERSION" --locked
            fi

            # Check cargo-mutants version
            if ! command -v cargo-mutants >/dev/null 2>&1 || [ "$(cargo-mutants --version 2>/dev/null | awk '{print $2}')" != "$CARGO_MUTANTS_VERSION" ]; then
              echo "Installing cargo-mutants $CARGO_MUTANTS_VERSION"
              cargo install cargo-mutants --version "$CARGO_MUTANTS_VERSION" --locked
            fi

            # Check beads_rust
            if ! command -v br >/dev/null 2>&1; then
              echo "Installing beads_rust"
              cargo install --git https://github.com/Dicklesworthstone/beads_rust.git
            fi

            # Check opencode
            npm install -g opencode-ai

            # Use project-local advisory database
            alias cargo-audit='cargo audit --db "$PWD/.cargo-advisory-db"'
          '';
        };
      }
    );
}
