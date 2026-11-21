// Match listeners by process ancestry, so spaces sharing a folder stay separate.
export function portsBySpace(spaces, terminals, processList, listeners, machine = null) {
  const mine = spaces.filter(s => (s.machine ?? null) === machine);
  const byAddress = new Map(terminals.map(t => [t.address, t]));
  const roots = new Map();
  for (const terminal of terminals) {
    if (terminal.state !== "live" || !terminal.pid) continue;
    const on = terminal.address.includes("/") ? terminal.address.split("/")[0] : null;
    if (on !== machine) continue;
    const seen = new Set();
    let current = terminal;
    while (current && !seen.has(current.address)) {
      seen.add(current.address);
      const id = current.labels?.["herdr.space"];
      const space = mine.find(s => s.id === id || (machine && s.id === `${machine}/${id}`));
      if (space) {
        roots.set(terminal.pid, space.id);
        break;
      }
      current = byAddress.get(current.parent);
    }
  }
  const parents = new Map();
  for (const line of processList.split("\n")) {
    const match = line.trim().match(/^(\d+)\s+(\d+)$/);
    if (match) parents.set(Number(match[1]), Number(match[2]));
  }
  const owner = pid => {
    const seen = new Set();
    while (pid > 0 && !seen.has(pid)) {
      if (roots.has(pid)) return roots.get(pid);
      seen.add(pid);
      pid = parents.get(pid);
    }
    return null;
  };
  const found = new Map();
  let space = null;
  let process = "";
  for (const line of listeners.split("\n")) {
    if (/^p\d+$/.test(line)) {
      space = owner(Number(line.slice(1)));
      process = "";
    }
    if (line.startsWith("c")) process = line.slice(1).trim();
    if (!space || !line.startsWith("n")) continue;
    const match = line.match(/:(\d+)$/);
    const port = match ? Number(match[1]) : 0;
    if (port < 1 || port > 65535) continue;
    if (!found.has(space)) found.set(space, new Map());
    const ports = found.get(space);
    if (!ports.has(port)) ports.set(port, new Set());
    if (process) ports.get(port).add(process);
  }
  return Object.fromEntries([...found].map(([id, ports]) => [id,
    [...ports].sort(([a], [b]) => a - b).map(([port, names]) => ({ port, processes: [...names].sort() })),
  ]));
}

export const formatPort = ({ port, processes }) => (processes.length ? processes : ["processo desconhecido"]).map(name => `${name}:${port}`).join(", ");
