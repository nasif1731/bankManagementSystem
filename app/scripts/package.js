const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const appRoot = path.join(__dirname, "..");
const distDir = path.join(appRoot, "dist");

fs.mkdirSync(distDir, { recursive: true });
execSync("npm pack --pack-destination dist", { cwd: appRoot, stdio: "inherit" });

console.log("Package created in dist/.");
