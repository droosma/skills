import fs from "node:fs";
import path from "node:path";

const [operation, ...args] = process.argv.slice(2);

if (operation === "fields") {
  const [manifestPath, tool] = args;
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  const target = manifest.targets?.[tool] ?? {};
  const fields = [
    manifest.name,
    target.mode ?? "",
    target.command ?? "",
    target.marketplaceSource ?? "",
    target.marketplaceMatch ?? "",
    target.plugin ?? "",
    target.installedMatch ?? "",
    target.source ?? "",
    target.skill ?? "",
    target.yes ? "true" : "false",
  ];
  process.stdout.write(`${fields.join("\x1f")}\n`);
} else if (operation === "add-opencode") {
  const [configPath, plugin] = args;
  const config = fs.existsSync(configPath)
    ? JSON.parse(fs.readFileSync(configPath, "utf8"))
    : {};
  const plugins = config.plugin ?? [];

  if (!Array.isArray(plugins)) {
    throw new Error(`Expected 'plugin' to be an array in ${configPath}.`);
  }
  if (plugins.includes(plugin)) {
    process.stdout.write("unchanged\n");
    process.exit(0);
  }

  plugins.push(plugin);
  config.plugin = plugins;
  fs.mkdirSync(path.dirname(configPath), { recursive: true });
  const tempPath = `${configPath}.${process.pid}.tmp`;
  fs.writeFileSync(tempPath, `${JSON.stringify(config, null, 2)}\n`, "utf8");
  fs.renameSync(tempPath, configPath);
  process.stdout.write("changed\n");
} else {
  throw new Error(`Unknown operation '${operation}'.`);
}
