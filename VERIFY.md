# How we verify this works BEFORE touching your PC

You were right to ask — we should be careful. Here's the safety net.

## The problem
This cloud box has no `nix`, so I can't locally run `nix flake check`. And you
don't want to find out something's broken *after* booting the install on your PC.

## The solution: cloud CI builds the whole thing
`.github/workflows/ci.yml` runs on every push to GitHub and:

1. **`nix flake check`** — validates the flake, resolves every input, type-checks
   every option. Catches: bad package names, wrong option names, missing args,
   input that won't fetch.
2. **Builds the full system closure** — `nixosConfigurations.nebula-ext...toplevel`.
   This is the EXACT derivation `nixos-rebuild` produces. It downloads + hash-checks
   opcode/cliamp, builds Stylix, compiles everything.

**If CI is green, the config builds on your PC.** Same Nix, same inputs, same
result — that's the whole point of Nix reproducibility. The only things CI can't
test are runtime/hardware-specific (does the SSD enumerate, does the 4080 light up)
— but every *software* failure mode is caught here.

## What CI does NOT catch (the honest caveats)
- **Disk enumeration** — whether the SanDisk shows up at boot (USB initrd modules
  are set, but real hardware is the test).
- **NVIDIA at runtime** — driver builds in CI, but "does Wayland light up on the
  4080" needs the actual GPU. Rollback-safe if not.
- **The `REPLACE_ME` values** — disko disk-id, SSH keys, username. CI builds with
  placeholders; you fill real values before install. (CI may even flag the disko
  device path — that's fine, it's a known placeholder.)

## How to read the result
- Green check on the repo = build passed, safe to install.
- Red X = something's broken; click it → read the failing step → I fix → re-push.

## Watch it
- Web: the repo's **Actions** tab.
- CLI: `gh run watch` / `gh run list`.

## The ultimate safety net (even if something slips through)
Every `nixos-rebuild` creates a **generation**. If a boot ever fails, you pick the
previous generation in the GRUB menu → back to working. You cannot brick it in a
way a reboot doesn't fix. That's why installing NixOS — even bleeding-edge — is
low-risk: the floor is "reboot to the last good state."
