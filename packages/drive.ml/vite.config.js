import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "node:path";

// TODO: Publish this so we can import it.
import { melangeWithoutDune, melangeWithDune } from "/home/tjdevries/git/vite-plugin-ocaml/dist/index.mjs";

// IDK WHAT THIS IS
// // add the beginning of your app entry
// import 'vite/modulepreload-polyfill'

// https://vitejs.dev/config/
export default defineConfig({
  // resolve: { alias: { "@": path.resolve(__dirname, "./src"), "_build/": false } },
  build: {
	manifest: true,
    // rollupOptions: {
    //   // overwrite default .html entry
    //   input: '/path/to/main.js',
    // },
  },
  server: {
    watch: {
      ignored: [
		'**/_build/**',
		'**/dune.lock/**',
		'**/dev-tools.locks/**'
	  ], // Exclude from watcher
    },
  },
    plugins: [
        react(),
		// melangeWithoutDune({ root: "blog", target: "generated", prefix: "@melange" }),
        melangeWithDune({ root: "blog", target: "generated", prefix: "@melange" }),
        // melangeWithDune({ root: "src", target: "generated", }),
    ],
});
