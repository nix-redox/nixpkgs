{
  lib,
  rustPlatform,
  rust-cbindgen,
  expect,
  stdenv,
  fetchFromGitLab,
}:
rustPlatform.buildRustPackage {
  pname = "relibc";
  version = "0.2.5";

  src = fetchFromGitLab {
    owner = "redox-os";
    repo = "relibc";
    rev = "0e506e97af6a834386cc424f0cb500866a3d658d";
    hash = "sha256-pm2xL6BdPVYUMLkphW5ZZ+7p3pG2ohAgzxDKl1Pgf98=";
    fetchSubmodules = true;
    domain = "gitlab.redox-os.org";
  };

  cargoHash = "sha256-E5WUvb9kg+IbEVTSEv6YZLn4pLPHFAV5loc5dwD52PU=";

  RUSTC_BOOTSTRAP = 1;
  TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;

  # error: Usage of `RUSTC_WORKSPACE_WRAPPER` requires `-Z unstable-options`
  auditable = false;

  doCheck = false;
  patchPhase = ''
    runHook prePatch

    patchShebangs --build renamesyms.sh stripcore.sh

    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    make CC=$CC AR=$AR LD=$LD NM=$NM CARGO_COMMON_FLAGS="" all

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    DESTDIR=$out make CC=$CC AR=$AR LD=$LD NM=$NM install

    runHook postInstall
  '';

  nativeBuildInputs = [
    rust-cbindgen
    expect
  ];

  meta = {
    homepage = "https://gitlab.redox-os.org/redox-os/relibc";
    description = "C Library in Rust for Redox and Linux";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.eveeifyeve ];
    platforms = lib.platforms.redox ++ lib.platforms.linux;
    teams = [ lib.teams.redox ];
  };
}
