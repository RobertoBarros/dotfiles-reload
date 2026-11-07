import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, agents, theme, run, window, keys, exec, readTextFile, appHome, hc } from "herdr";

function codexAgent(space, agentList) {
  if (!space) return null;
  const list = agentList.filter(a => a.space === space.id && (a.app === "codex" || a.program?.key === "codex"));
  const tab = space.tabs?.find(t => t.active);
  return list.find(a => a.focused) ?? list.find(a => a.tab === tab?.id) ?? list[0] ?? null;
}

export function sessionLabel(screen) {
  for (const line of screen.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "").split("\n").reverse()) {
    const match = line.match(/^\s*((?:GPT|gpt)-[\w.-]+)\s+(minimal|none|low|medium|high|xhigh|max|ultra)\s*(?:·|$)/);
    if (match) {
      const context = line.match(/(?:^|·)\s*Context\s+(\d{1,3})%\s+left\b/);
      const remaining = context && Number(context[1]) <= 100 ? ` · Context ${context[1]}% left` : "";
      return `${match[1]} ${match[2]}${remaining}`;
    }
  }
  return null;
}

export function formatLimits(limits) {
  return [limits.primary, limits.secondary].filter(limit => limit && Number.isFinite(limit.usedPercent) && Number.isFinite(limit.windowDurationMins))
    .map(limit => {
      const minutes = limit.windowDurationMins;
      const window = minutes === 10080 ? "weekly" : minutes % 60 === 0 ? `${minutes / 60}h` : `${minutes}m`;
      const remaining = Math.round(Math.max(0, Math.min(100, 100 - limit.usedPercent)));
      return `${window} ${remaining}% left`;
    }).join(" · ");
}

export default class WorkspaceStatus extends View {
  init(_props, cx) {
    this.usage = {};
    this.busy = false;
    this.sessions = {};
    this.sessionBusy = false;
    const update = cx => {
      const space = spaces().find(s => s.active);
      const agent = codexAgent(space, agents());
      this.refresh(cx, space, agent);
      this.refreshSession(cx, agent);
    };
    update(cx);
    cx.timer.every(1000, update);
  }

  refreshSession(cx, agent) {
    if (!agent || !window().active || this.sessionBusy) return;
    const previous = this.sessions[agent.address];
    if (Date.now() - (previous?.at ?? 0) < 5000) return;
    this.sessionBusy = true;
    cx.spawn(async cx => {
      let label = null;
      try {
        const result = await hc(["read", agent.address]);
        if (result.code === 0) label = sessionLabel(result.stdout);
      } catch {}
      this.sessions[agent.address] = { label, at: Date.now() };
      this.sessionBusy = false;
      if (previous?.label !== label) cx.notify();
    });
  }

  refresh(cx, space, agent) {
    if (!agent || !window().active || this.busy) return;
    const machine = space.machine ?? "local";
    if (Date.now() - (this.usage[machine]?.at ?? 0) < 60000) return;
    this.busy = true;
    cx.spawn(async cx => {
      let label = "Limites indisponíveis";
      try {
        this.source ??= await readTextFile(`${appHome()}/mods/codex-status/rate_limits.rb`);
        const result = await exec("ruby", ["-e", this.source], { on: space.machine });
        if (result.code === 0) label = formatLimits(JSON.parse(result.stdout)) || label;
      } catch {}
      this.usage[machine] = { label, at: Date.now() };
      this.busy = false;
      cx.notify();
    });
  }

  // The palette key as actually bound, not a hardcoded one; without a
  // binding the hint stays useful ("commands") instead of lying.
  hint(t) {
    const mac = window()?.platform === "macos";
    const mod = { cmd: mac ? "⌘" : "Ctrl+", ctrl: mac ? "⌃" : "Ctrl+", shift: mac ? "⇧" : "Shift+", alt: mac ? "⌥" : "Alt+", option: mac ? "⌥" : "Alt+" };
    const b = keys().find((k) => k.section === "global" && k.action === "app.palette");
    const parts = b && b.keys.endsWith("--") ? [...b.keys.slice(0, -2).split("-"), "-"] : b?.keys.split("-");
    const key = parts && parts.map((p) => mod[p.toLowerCase()] ?? p.toUpperCase()).join("");
    return key ? `${key}  commands` : "commands";
  }

  render() {
    const t = theme();
    const space = spaces().find(s => s.active);
    const list = agents();
    const needs = list.filter(a => a.status === "blocked").length;
    const agent = codexAgent(space, list);
    const model = agent && this.sessions[agent.address]?.label;
    const label = (icon, text) => h_flex().gap(6).items_center().child(svg(`mods/workspace-chrome/${icon}.svg`).size(13)).child(text);
    return h_flex().size_full().px(14).gap(16).items_center().bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .child(label(space?.machine ? "server" : "monitor", space?.machine ?? "This computer"))
      .when(Boolean(space?.branch), el => el.child(label("branch", space.branch)))
      .child(h_flex().gap(6).items_center().child(div().size(6).rounded(3).bg(t.dim)).child(`${list.length} agents`)
        .when(needs > 0, el => el.child(div().text_color(t.blocked).child(`· ${needs} needs you`))))
      .child(div().flex_1())
      .when(Boolean(agent), el => el.child(div().text_color(t.muted)
        .tooltip("Modelo, esforço e contexto restante da sessão · limites da conta atualizados a cada minuto")
        .child(`${model || "Codex"} · ${this.usage[space.machine ?? "local"]?.label ?? "Carregando limites…"}`)))
      .child(div().id("palette").text_color(t.dim).on_click(() => run("app.palette")).child(this.hint(t)));
  }
}
