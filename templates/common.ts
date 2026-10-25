//=design
//=angular_release_bundle
//=angular_hardening_flags
//=image container mount

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

//=angular_hardening_flags
//  cat client/tsconfig.json
// /* To learn more about Typescript configuration file: https://www.typescriptlang.org/docs/handbook/tsconfig-json.html. */
// /* To learn more about Angular compiler options: https://angular.dev/reference/configs/angular-compiler-options. */
// {
//   "compileOnSave": false,
//   "compilerOptions": {
//     // strict and types
//     "strict": true,
//     "noImplicitOverride": true,
//     "noPropertyAccessFromIndexSignature": true,
//     "noImplicitReturns": true,
//     "noFallthroughCasesInSwitch": true,
//     // module handling
//     "skipLibCheck": true,
//     "isolatedModules": true,
//     "experimentalDecorators": true,
//     "importHelpers": true,
//     "target": "ES2022",
//     "module": "preserve",
//     // hardening
//     "exactOptionalPropertyTypes": true,
//     "noUncheckedIndexedAccess": true,
//     "noUnusedLocals": true,
//     "noUnusedParameters": true,
//     "noEmitOnError": true,
//     // no surprises
//     "forceConsistentCasingInFileNames": true
//   },
//   "angularCompilerOptions": {
//     "enableI18nLegacyMessageIdFormat": false,
//     "strictInjectionParameters": true,
//     "strictTemplates": true,
//     "strictTargetEmit": true, // abort on template emit errors
//     "strictStandalone": true,
//     "extendedDiagnostics": {
//       "defaultCategory": "error"
//     },
//     "strictContextGenerics": true, // check generic component types in template
//     "strictDomEventTypes": true,
//     "typeCheckHostBindings": true  // check properties und attribute in @HostBinding()
//   },
//   "files": [],
//   "references": [
//     {
//       "path": "./tsconfig.app.json"
//     },
//     {
//       "path": "./tsconfig.spec.json"
//     }
//   ]
// }
// >podman run --rm -v ./client/:/app:z docker.io/library/node:26-alpine sh -c "cd /app && npm ci --verbose && npm run build && tree ."

//=image container mount
// >cat cbuild.angular_website
// FROM scratch
// COPY ./client/dist/client/browser/ /
// >CONTAINER_TAG=$(git describe --tags --exact-match 2>/dev/null || git rev-parse HEAD)
// >podman build -t client:$CONTAINER_TAG -f cbuild.angular_website .
// >docker run --rm --name nginx -p "127.0.0.1:4200:80" -v "./nginx.conf:/etc/nginx/conf.d/default.conf" --mount "type=image,source=client:$CONTAINER_TAG,target=/usr/share/nginx/html" docker.io/library/nginx:1.31.6-alpine
