const fs = require("fs");
const path = require("path");

const distDir = path.join(__dirname, "..", "dist");
fs.mkdirSync(distDir, { recursive: true });

console.log("Build completed. Dist directory is ready.");
