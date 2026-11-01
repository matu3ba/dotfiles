{
  lib,
  stdenv,
  zig,
  makeWrapper,
  callPackage,
  llvmPackages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "appname";
  version = "0.0.1";
  src = ../.;
  zigDeps = zig.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-soiQ+vrE7JC2esovJbpz4OhigTZ40qpi4MEW/IMCpjk=";
    # initially use 'hash = lib.fakeHash;' being implicit 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
  };

  nativeBuildInputs = [
    zig
    makeWrapper
  ];
  buildInputs = [
    llvmPackages.openmp
  ];
  postConfigure = ''
    mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
    cp -rLT "${finalAttrs.zigDeps}" "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  # skip the hook's default "-Dcpu=baseline --release=safe" etc,
  # we set our own flags below
  dontSetZigDefaultFlags = true;
  zigBuildFlags = [
    "-Dcpu=baseline"
    "-Doptimize=ReleaseFast"
  ];
  postInstall = ''
    wrapProgram $out/bin/appname \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [llvmPackages.openmp]}
  '';
  meta = {
    description = "what app does";
    homepage = "https://codeberg.org/user/appname";
    license = lib.licenses.mit;
    mainProgram = "appname";
  };
})
