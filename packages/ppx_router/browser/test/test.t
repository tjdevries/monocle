
  $ node ./js/browser/test/test.js test
  node:internal/modules/cjs/loader:1242
    throw err;
    ^
  
  Error: Cannot find module '$TESTCASE_ROOT/js/browser/test/test.js'
      at Function._resolveFilename (node:internal/modules/cjs/loader:1239:15)
      at Function._load (node:internal/modules/cjs/loader:1064:27)
      at TracingChannel.traceSync (node:diagnostics_channel:322:14)
      at wrapModuleLoad (node:internal/modules/cjs/loader:218:24)
      at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:170:5)
      at node:internal/main/run_main_module:36:49 {
    code: 'MODULE_NOT_FOUND',
    requireStack: []
  }
  
  Node.js v23.3.0
  [1]
