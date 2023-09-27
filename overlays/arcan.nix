final: prev: {
  __dontExport = true;

  arcanPackages = prev.arcanPackages.overrideScope' (finalScope: prevScope: {
    arcan = prevScope.arcan.overrideAttrs (finalAttrs: prevAttrs: {
      version = "581df5665a18432197662c569ed9a1bc60308461";

      src = final.fetchFromGitHub {
        owner = "letoram";
        repo = "arcan";
        rev = "581df5665a18432197662c569ed9a1bc60308461";
        hash = "sha256-XlJcp7H/8rnDxXzrf1m/hyYdpaz+nTqy/R6YHj7PGdQ=";
      };

      patches = [];
    });
  });
}
