const { readFileSync } = require("node:fs");
const { runInNewContext } = require("node:vm");
const assert = require("node:assert/strict");

async function test() {
  const source = readFileSync(`${__dirname}/main.js`, "utf8")
    .replace(/^import .*;\n/gm, "").replace(/export default /g, "").replace(/export /g, "");
  const tasks = [];
  const terminal = { cwd: "/repo", foreground: { cwd: "/repo" } };
  const context = {
    View: class {},
    window: () => ({ active: true }),
    appHome: () => "/herdr",
    readTextFile: async () => "session helper",
    hc: async args => ({ code: 0, stdout: args[0] === "get" ? JSON.stringify(terminal) : "Ask Codex to do anything\n92% context left" }),
    exec: async () => ({ code: 0, stdout: JSON.stringify({ label: "gpt-6.1-sol high" }) }),
  };
  runInNewContext(`${source}\nglobalThis.Status = WorkspaceStatus;`, context);
  const status = new context.Status();
  status.sessions = {};
  const cx = { spawn: fn => tasks.push(fn(cx)), notify() {} };
  status.refreshSession(cx, { address: "t1" });
  await Promise.all(tasks);
  assert.equal(status.sessions.t1.label, "gpt-6.1-sol high");
  console.log("Footer reads session model and reasoning with the Codex status line hidden");
}

test().catch(error => { console.error(error); process.exitCode = 1; });
