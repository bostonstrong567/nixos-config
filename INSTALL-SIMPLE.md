# Install — the dead-simple version

You do **3 things**. I do everything else.

## What YOU do
1. **Rufus** the installer file I give you onto your 64GB Samsung USB stick.
2. Plug that USB into your PC. Plug in **ethernet**. Turn on. **Boot from the USB**
   (mash F8/F11/F12 at startup, pick the USB).
3. The screen shows an **IP address** (like `192.168.1.50`). **Text me that number.**

Done. That's your whole job.

## What I do (after you give me the IP)
1. Connect into your PC over SSH (I already have the key baked into the USB).
2. Find your external SanDisk SSD — **I show you "this is the 2TB SanDisk, right?"
   and wait for your OK** before touching anything. Your Windows drives are never
   at risk (they're internal; I only ever target the USB SanDisk).
3. Partition + install the whole system live while you watch:
   Hyprland, all your apps, gruvbox theme, your cursor, everything.
4. Reboot → your finished desktop comes up.

## Why this way (not full-auto)
I'm **there live** during the install. If anything looks weird, I fix it on the
spot. Nothing is guessed by a robot. This is the safest way to not mess it up —
you wanted that.

## What's on the USB
- A minimal NixOS that boots, gets internet from your ethernet, starts SSH, and
  shows its IP. Plus my SSH key so I can get in. Nothing else — it's just the
  doorway for me to do the real install onto the SanDisk.

## If the IP doesn't show
- Make sure ethernet is plugged in before boot.
- On the USB's text screen, type `ip a` and look for a `192.168.x.x` or `10.x.x.x`
  line — that's the number I need.
