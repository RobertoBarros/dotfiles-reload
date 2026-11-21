const { readFileSync } = require("node:fs");
const { runInNewContext } = require("node:vm");
const assert = require("node:assert/strict");
const { test } = require("node:test");

const source = readFileSync(`${__dirname}/ports.js`, "utf8").replace(/export /g, "");
const context = {};
runInNewContext(`${source}\nglobalThis.scan = portsBySpace; globalThis.format = formatPort;`, context);
const scan = (...args) => JSON.parse(JSON.stringify(context.scan(...args)));
const sp = [{ id: "one", machine: null }, { id: "two", machine: null }, { id: "vps/one", machine: "vps" }];
const ts = [
  { address: "t1", pid: 100, state: "live", labels: { "herdr.space": "one" } },
  { address: "t2", pid: 200, state: "live", labels: { "herdr.space": "two" } },
  { address: "vps/t1", pid: 100, state: "live", labels: { "herdr.space": "one" } },
];

test("assigns listeners to terminal descendants, deduplicates IPv4/IPv6 and sorts ports", () => {
  assert.deepEqual(scan(sp, ts, "100 1\n110 100\n111 110\n200 1\n210 200\n999 1", "p111\nn*:3000\nn[::1]:3000\nn127.0.0.1:8080\np110\nn*:4000\np210\nn*:3001\np999\nn*:5432"), {
    one: [{ port: 3000, processes: [] }, { port: 4000, processes: [] }, { port: 8080, processes: [] }], two: [{ port: 3001, processes: [] }],
  });
});

test("uses the nearest terminal when Herdr terminals are nested", () => {
  assert.deepEqual(scan(sp, ts, "100 1\n200 100\n210 200", "p210\nn*:3000"), { two: [{ port: 3000, processes: [] }] });
});

test("keeps remote PIDs separate from this machine", () => {
  assert.deepEqual(scan(sp, ts, "100 1\n110 100", "p110\nn*:3000", "vps"), { "vps/one": [{ port: 3000, processes: [] }] });
});

test("includes child core terminals that inherit their space through a parent", () => {
  const children = [...ts,
    { address: "t3", pid: 300, state: "live", parent: "t1", labels: {} },
    { address: "t4", pid: 400, state: "live", parent: "t3", labels: {} },
  ];
  assert.deepEqual(scan(sp, children, "400 1\n410 400", "p410\nn*:3000"), { one: [{ port: 3000, processes: [] }] });
});

test("closed listeners and finished terminals disappear", () => {
  assert.deepEqual(scan(sp, ts, "100 1", ""), {});
  assert.deepEqual(scan(sp, [{ ...ts[0], state: "finished" }], "100 1", "p100\nn*:3000"), {});
});

test("ignores malformed ports and cyclic process ancestry", () => {
  assert.deepEqual(scan(sp, ts, "100 1\n800 801\n801 800", "p100\nn*:0\nn*:65536\nn*:x\np800\nn*:3000"), {});
});

test("keeps process names with each port and deduplicates shared listeners", () => {
  assert.deepEqual(scan(sp, ts, "100 1\n110 100\n111 100\n200 1", "p110\ncnode\nn*:3000\nn[::1]:3000\np111\ncruby\nn*:3000\np200\ncpython3\nn*:8000"), {
    one: [{ port: 3000, processes: ["node", "ruby"] }],
    two: [{ port: 8000, processes: ["python3"] }],
  });
});

test("displays listeners as process:port", () => {
  assert.equal(context.format({ port: 3000, processes: ["node"] }), "node:3000");
  assert.equal(context.format({ port: 3000, processes: ["node", "ruby"] }), "node:3000, ruby:3000");
  assert.equal(context.format({ port: 3000, processes: [] }), "processo desconhecido:3000");
});
