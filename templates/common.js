// lightweight and very fast web framework
// https://github.com/withastro/astro
// clumsy big angular
// https://github.com/biomejs/biome
// smaller angular alternative with similar perf (no build runner): vue.js
// interesting test runner with pile of goodies: https://wallabyjs.com/
//
// complex visualizations
// * generally: graph-like, chart-like or what kind of visualizations?
// * https://github.com/d3/d3 very powerful, but not super fast to setup and run
// * fast to setup visualizations: requires proprietary solutions
// * fast(est) to run
//   - charts: lightning charts
//   - WebGPU-based charts, wasm with threads?

// all web dev tutorials are annoying, because they forget to tediously mention all versions or pin everything
// * problem: for some reasons web dev languages and tools break very often without stability
// * possible solution: use stable format like wasm + access with it dom (API) specified by w3c
// * other solution: dont use web dev things, because frameworks dont care about stability

// complex/bigger projects or monorepos with multi-include files need build
// system with better cache etc
// * type-script focused (unfortunately startup-based on cloud integration): https://github.com/nrwl/nx
// * zig build system
// * bun (not anymore zig based)

// Angular best practice
// Use
// * pnpm
// * nx

// Angular Best Practices
// maybe_good_sources
// * https://github.com/alfredoperez/angular-best-practices
// * https://github.com/evoytenkoapps/angular-best-practices
// * https://github.com/andredesousa/angular-best-practices
// * https://github.com/angular/skills
// * https://angular.dev/
// * https://github.com/angular/angular/tree/main/adev
//
// * https://v17.angular.io/guide/reactive-forms
// project structure
// https://www.angular.courses/blog/angular-folder-structure-guide
//     core/
//         services
//     pages/
//         modules**/
//             service
//             tests
//             template
//     router
//     shared/
//         reusable components
//         UI
//         pipes
//         directives
//         config
// alternative:
//     core/
//     shared/
//     modules**/
