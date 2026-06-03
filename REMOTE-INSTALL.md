# Remote install over SSH (nixos-anywhere) + dev tooling notes

## nixos-anywhere — let me install to your SSD over SSH

`nixos-anywhere` runs **from one machine** (nebula, the cloud box) and installs a
full NixOS onto **another** (your PC) over SSH — partitioning, formatting, and
deploying this flake in one shot. No manual ISO partitioning.

### What it needs (the catch)
The target PC must already be running **some Linux with SSH reachable** when the
install starts. Two ways to get there:

1. **Boot the NixOS installer ISO** on your PC (USB stick), enable SSH on it, note
   its IP. Then from nebula I run nixos-anywhere → it wipes the external SSD and
   installs. *(You still boot a USB once — but you don't do any partitioning/config;
   I drive the whole install remotely.)*
2. **Any live Linux** with SSH + the disk attached works as the launch environment.

> ⚠️ nixos-anywhere **erases the target disk** it's pointed at. The disk selector
> (via `disko`) must point at the external SanDisk, never the internal Windows
> NVMe. We pin it by disk model/serial in a `disko` config before running. I will
> show you the exact target before anything is wiped.

### The flow (once you're on the installer ISO)
```bash
# On the PC: boot NixOS ISO, set a root password, enable sshd, find IP:
sudo systemctl start sshd
sudo passwd root          # temp password for the install
ip a                      # note the LAN IP, e.g. 192.168.1.50
```
```bash
# From nebula (me), after we add a disko config pinning the SanDisk:
nix run github:nix-community/nixos-anywhere -- \
  --flake /etc/nixos#nebula-ext \
  --target-host root@192.168.1.50
```
nixos-anywhere then: partitions the SanDisk (per disko) → installs the flake →
reboots into your finished system. Everything from this repo lands in one go.

### Tailscale auto-join during remote install
To have the box join your tailnet automatically on first boot, place the auth key
on the target during install with `--extra-files`:
```bash
# Generate a reusable key at https://login.tailscale.com/admin/settings/keys
mkdir -p /tmp/extra/etc
echo "tskey-auth-XXXXXXXX" > /tmp/extra/etc/tailscale-authkey
chmod 600 /tmp/extra/etc/tailscale-authkey

nix run github:nix-community/nixos-anywhere -- \
  --flake /etc/nixos#nebula-ext \
  --extra-files /tmp/extra \
  --target-host root@192.168.1.50
```
The key lands at `/etc/tailscale-authkey` (where `modules/remote.nix` expects it)
and the machine joins your tailnet the moment it boots — reachable from nebula
immediately, no manual `tailscale up`.

### Why this needs a `disko` config first
To partition declaratively + safely, we add `modules/disko.nix` describing the
SanDisk layout (ESP + root, pinned by `/dev/disk/by-id/...` so it can't grab the
wrong disk). I'll write that when you're ready to do the remote install — it
replaces the manual partitioning in README.md steps 2–3.

### Honest tradeoff vs the manual install
- **Manual (README.md):** you boot ISO, run ~6 commands, done. Full control, you
  see every step. Best for a first NixOS install.
- **nixos-anywhere:** you boot ISO + enable ssh, I do the rest remotely. Slick, but
  the disk-targeting must be exact (disko pins it). Best once you trust the setup /
  for re-installs.

Both end at the identical system (same flake). Pick per comfort.

---

## Dev tooling added (modules/dev-tools.nix)

| Tool | Use it like |
|---|---|
| **comma** | `, cowsay hi` — run any pkg once, no install. (Run `nix-index` once first to build the lookup DB.) |
| **nix-index** | `nix-locate bin/ffmpeg` — which package ships a file |
| **direnv + nix-direnv** | drop a `.envrc` (`use flake`) in a project dir → tools auto-load on `cd`, cached |
| **devenv** | `devenv init` → fast reproducible per-project dev shell |
| **nixd / nil** | Nix LSP — point VSCode's Nix extension at `nixd` for autocomplete while editing this repo |
| **alejandra** | `alejandra .` — format all .nix files |
| **nix-tree** | `nix-tree` — browse the dependency graph, spot bloat |
| **nix-alien** | `nix-alien ./some-random-binary` — run an unpatched binary without manual FHS wrapping |

### Point VSCode at the Nix LSP
In VSCode settings (or declaratively later), set the Nix extension's server path to
`nixd`. Then editing `*.nix` in this repo gets completion + option docs inline.

---

## MCP-NixOS (mcp/claude-mcp.json) — smarter AI help on your box

`mcp/claude-mcp.json` is a ready Model-Context-Protocol server config. Adding it to
claude-code/opcode/Claude Desktop on the NixOS box gives the AI **live, accurate**
NixOS data: 130K+ packages, 23K+ options, 4K+ home-manager settings, version
history. Means fewer wrong package names / option guesses when I (or you) edit this
config from the machine itself.

Add to claude-code:
```bash
claude mcp add nixos -- nix run github:utensils/mcp-nixos --
```
Or paste the `mcpServers` block into the Claude Desktop / opcode MCP config.
