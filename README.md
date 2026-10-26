# eeshan-claude-mods

Two [Claude Code mods](https://code.claude.com/docs/en/plugins/mods/overview) I use every day. A mod is a plugin that runs inside Claude Code and changes how it looks and works.

| Mod | What it does |
|---|---|
| `pr-band` | One line above the prompt for the pull request you're working on: checks passed, running and failed (each failed one links to its log), whether GitHub will let it merge (`mergeable`, `conflicts with main`, `behind main`, `blocked`), and `main is red` when your base branch is failing. After the merge it follows what the merge started, each deployment included, then goes away. A toast tells you when checks finish, when it merges and when the deploys land. |
| `clickable` | A `[copy]` link under every code block in Claude's replies: Cmd-click it and the block's exact text is on your clipboard, without the line breaks a mouse copy picks up when the terminal wraps a long command. A block that is only a URL or a path also gets `[open]`. URLs and file paths in the reply become links that open whole, even when they hold spaces or wrap. |

## Install

Needs Claude Code 2.1.287 or later. At the prompt of a terminal session:

```
/plugin install pr-band --marketplace eeshankulk1/eeshan-claude-mods
```

```
/plugin install clickable --marketplace eeshankulk1/eeshan-claude-mods
```

Answer `y` to add the marketplace, then pick a scope (user is the first one). The mod is on right away.

From a shell instead:

```
claude plugin install pr-band --marketplace eeshankulk1/eeshan-claude-mods
```

## What each one needs

- **pr-band** reads GitHub with the `gh` CLI, so `gh` must be installed and signed in (`gh auth status`). It finds the PR from your folder's branch, or from the URL a `gh pr create` in the session printed, and polls GitHub every 20 seconds while something runs, less often once things settle. It only draws and toasts: it never adds anything to the conversation.
- **clickable** works in the classic terminal view. Copy links are macOS only: there a click reaches the terminal, never Claude Code, and a terminal can only open a link, so the first session after install builds a small helper app, `~/Library/Application Support/clickable/Clickable Copy.app`, that opens `clickable-copy://` links and copies the saved text. The text of each block is kept in `~/.claude/clickable/copy/` for 30 days. On other systems you still get the URL and path links.

## Read before you install

Mods aren't sandboxed: they run with your permissions. These two are short, and the code is all here (`mods/<name>/hooks/`). `claude plugin validate mods/<name>` lists every event a mod hooks and every call it makes.

## Make your own

Ask Claude Code for one in plain words, for example "make a mod that shows my git branch above the prompt". Its built-in `plugin-authoring` skill writes it and reloads it as you go.

## Tests

```
claude plugin test mods/pr-band && claude plugin test mods/clickable
```

Found a bug? Open an issue.

## License

MIT
