{
  lib,
  buildGoModule,
  fetchFromGitHub,
  olm,
  withGoolm ? false,
}:

buildGoModule (finalAttrs: {
  pname = "mautrix-telegram";
  version = "26.08";
  tag = "v0.2608.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    inherit (finalAttrs) tag;
    hash = "sha256-EQ7c98GOaXaMcLF5xJfZ6tV+X9TKjNnd8a3ToJahNsE=";
  };

  vendorHash = "sha256-sh3CejNXhSLp2l4ZnfWwdwxqF+yzCn7/T4EWfVX84m8=";

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Tag=${finalAttrs.tag}"
  ];

  buildInputs = (lib.optional (!withGoolm) olm);

  checkFlags =
    let
      skippedTests = [
        "TestOnLoginToken"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  tags = lib.optional withGoolm "goolm";

  meta = {
    homepage = "https://github.com/mautrix/telegram";
    description = "Matrix-Telegram hybrid puppeting/relaybot bridge";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [
      bartoostveen
      nyanloutre
      nickcao
      renesat
    ];
    mainProgram = "mautrix-telegram";
  };
})
