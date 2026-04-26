const fs = require("fs");
const path = require("path");

const distDir = path.join(__dirname, "..", "dist");
const artifacts = fs.existsSync(distDir) ? fs.readdirSync(distDir) : [];

if (artifacts.length === 0) {
  throw new Error("No package artifacts found in dist/. Run npm run package first.");
}

console.log("Deploy simulation complete. Artifacts:");
for (const artifact of artifacts) {
  console.log(`- ${artifact}`);
}
