{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  zstd,
  libgit2,
  libssh2,
  openssl,
  darwin,
  libiconv,
  nix-update-script,
  testers,
  jujutsu,
}:

let
  version = "0.21.0";
in

rustPlatform.buildRustPackage {
  pname = "jujutsu";
  inherit version;

  src = fetchFromGitHub {
    owner = "martinvonz";
    repo = "jj";
    rev = "v${version}";
    hash = "sha256-uZsfHhcYpobatWaDQczuc9Z3BWHN5VO0qr/8mu5kEio=";
  };

  cargoHash = "sha256-BOO1jP1Y5CNbE97zj+tpariiBdcuxKb1wyvI7i/VpYI=";

  cargoBuildFlags = [
    "--bin"
    "jj"
  ]; # don't install the fake editors
  useNextest = false; # nextest is the upstream integration framework, but is problematic for test skipping

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs =
    [
      zstd
      libgit2
      libssh2
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
      libiconv
    ];

  env = {
    # Disable vendored libraries.
    ZSTD_SYS_USE_PKG_CONFIG = "1";
    LIBGIT2_NO_VENDOR = "1";
    LIBSSH2_SYS_USE_PKG_CONFIG = "1";
  };

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/jj util mangen > ./jj.1
    installManPage ./jj.1

    installShellCompletion --cmd jj \
      --bash <($out/bin/jj util completion bash) \
      --fish <($out/bin/jj util completion fish) \
      --zsh <($out/bin/jj util completion zsh)
  '';

  checkFlags = [
    # signing tests spin up an ssh-agent and do git checkouts
    "--skip=test_ssh_signing"
  ];

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      version = testers.testVersion {
        package = jujutsu;
        command = "jj --version";
      };
    };
  };

  meta = {
    description = "Git-compatible DVCS that is both simple and powerful";
    homepage = "https://github.com/martinvonz/jj";
    changelog = "https://github.com/martinvonz/jj/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      _0x4A6F
      thoughtpolice
    ];
    mainProgram = "jj";
  };
}
