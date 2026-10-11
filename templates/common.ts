//=design
//=angular_release_bundle

//=design
// 1. Typescript as language is too lazy for very fast incremental compilation.
// 2. The ecosystem is horrible and plastered with CVEs.
// 3. Hopefully this changes over time for the better, but I am very skeptical.

//=angular_release_bundle
// * index.html: website main entry
// * main-FFFFFFFF.js: bundled code of app
// * styles-FFFFFFFF.css: global CSS of app
// * chunk-*.js: lazy-loading-fragments splitted by Angular based on existing routes
// * assets/config.json: runtime configuration file, ie for API URLs
// * silent-check-sso.html: necessary for Keycloak/OIDC-Login-Flow in background
//   nice to have
// * 3rdpartylicenses.txt: licenses
// * favicon.ico: website icon in browser task bar
