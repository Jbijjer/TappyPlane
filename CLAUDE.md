# TappyPlane

Godot 4.1 (GDScript) mobile runner. The project is named "TappyPlane" but the
character is a dragon (art asset chosen after the name was already set — the
name itself carries no design meaning, don't read into it).

## Core mechanic — read this before designing any obstacle

The world auto-scrolls at a constant horizontal speed. The player's sprite
stays at a **fixed x position** on screen at all times. The player has
**exactly one primary lever**: tap to apply an upward impulse (gravity pulls
back down). There is no player control over horizontal position or scroll
speed from the primary input.

**Consequence:** at any given x, the only thing the player has influenced by
playing is their own **Y position** (and derived state like velocity). An
obstacle is only fair/dodgeable if the danger is conditioned on the player's Y
state at that x. An obstacle whose danger is conditioned on anything else
(a global timer, elapsed time, "being there") is not something the player can
react to — it's predetermined the moment it spawns. This exact mistake was
made once already (a full-height blinking "laser" obstacle) and had to be
reverted — see git history (`git log --oneline` around "laser" commits) if
useful context.

Confirmed game design decisions (from direct conversation with the repo
owner, not to be re-litigated without asking):
- Scroll speed and pipe spawn rate are **constant**, not scaled by
  score/time. Difficulty should come from new mechanics unlocking with
  progression, not from cranking existing constants.
- A **dual-form system** is in progress: the character can switch between a
  Dragon and a Unicorn form via a dedicated on-screen button (bottom-left
  corner, sized for a second thumb, fully independent from the flight tap —
  the player must be able to fly and switch forms in the same instant).
  Switching is instant/free, no cooldown. Each form has different flight
  physics (gravity/power) and a different global scroll speed (scroll speed
  transitions are *smoothed*, not instant — see `GameManager._process`).
  Each form is planned to have a resistance/weakness to a themed hazard
  (fire vs. rainbow) with universal hazards (pipes) still killing both forms.
  See `singletons/game_manager.gd` (`Form` enum, `current_form`,
  `switch_form()`) and `scenes/bat_cb/bat_cb.gd`.
- No unicorn/rainbow art exists yet — current unicorn look is a placeholder
  tint (`UNICORN_TINT` in `bat_cb.gd`), swap once real art is sourced.
- Hitbox (`CollisionShape2D` on `BatCB`) is the same regardless of form —
  don't change it per-form.

## Testing without a GUI

No Godot editor/APK is preinstalled in a fresh session — set this up each
time (a few minutes):

### Headless validation (no rendering needed)

```bash
curl -sSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/4.1.4-stable/Godot_v4.1.4-stable_linux.x86_64.zip"
cd /tmp && unzip -q godot.zip && mkdir -p /root/.local/bin && cp Godot_v4.1.4-stable_linux.x86_64 /root/.local/bin/godot4 && chmod +x /root/.local/bin/godot4
```

- Import/parse check: `godot4 --headless --editor --quit --path .` (run
  twice — the first pass just populates the `.godot/` import cache and its
  own errors are noise; the second pass is the real signal).
- Runtime check: `godot4 --headless --path . --quit-after 300 res://scenes/game/game.tscn`
  runs the actual game scene for N frames and surfaces runtime script errors.

### Visual capture (see actual rendered frames)

Useful to verify a visual change actually looks right, not just "doesn't
crash." Needs a virtual display + software GL (no GPU in this sandbox):

```bash
apt-get install -y xvfb   # usually already present
godot4 --path . --rendering-driver opengl3 --write-movie /tmp/out/frame.png \
  --fixed-fps 30 --quit-after 200 res://scenes/game/game.tscn
```
wrapped in `xvfb-run -a`. A `.png` path for `--write-movie` writes one
numbered PNG per frame (readable directly) instead of a video container.

To drive input during a capture (simulate taps, force a specific game state
for testing), write a small `extends SceneTree` script and pass it via
`--script res://debug_capture.gd` instead of a scene path. **Do not
reference autoload singletons (`GameManager`, `SoundManager`) by their bare
global name in such a script** — that identifier isn't resolved when
`--script` overrides the main loop and throws a compile error. Use
`root.get_node_or_null("/root/GameManager")` instead. Delete the debug
script and confirm `git status` is clean before committing — it's scratch
tooling, never part of the repo.

### Android APK export

`export_presets.cfg` has `gradle_build/use_gradle_build=false`, so this uses
Godot's prebuilt APK template directly — no Gradle/Android Studio needed,
just `apksigner`/`zipalign` and a debug keystore.

**`dl.google.com` is blocked by network policy in this environment** — don't
try the official Android command-line tools / sdkmanager route. Ubuntu
packages `apksigner` and `zipalign` separately (from `archive.ubuntu.com`,
which is allowed):

```bash
apt-get install -y apksigner zipalign adb
```

These install as standalone binaries in `/usr/bin`, but Godot's Android
export expects a real SDK layout (`<sdk>/build-tools/<version>/apksigner`).
Fake that layout with symlinks (safe — the underlying scripts resolve their
jar via a hardcoded path, not `$0`):

```bash
mkdir -p /opt/android-sdk-fake/build-tools/34.0.0 /opt/android-sdk-fake/platform-tools
ln -sf /usr/bin/apksigner /opt/android-sdk-fake/build-tools/34.0.0/apksigner
ln -sf /usr/bin/zipalign /opt/android-sdk-fake/build-tools/34.0.0/zipalign
ln -sf /usr/bin/adb /opt/android-sdk-fake/platform-tools/adb
```

Generate a standard debug keystore (Godot's default expected
alias/passwords, matches the fallback already in a fresh
`editor_settings-4.tres`):

```bash
mkdir -p /root/.android
keytool -genkeypair -v -keystore /root/.android/debug.keystore -storepass android \
  -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 \
  -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
```

Download the export templates matching the project's Godot version (check
`config_version`/engine version, currently 4.1.4-stable) and install just the
Android ones (the full `.tpz` is ~800MB, delete the rest after extracting to
save disk):

```bash
curl -sSL -o /tmp/templates.tpz "https://github.com/godotengine/godot/releases/download/4.1.4-stable/Godot_v4.1.4-stable_export_templates.tpz"
mkdir -p /tmp/tpl && cd /tmp/tpl && unzip -q /tmp/templates.tpz
mkdir -p /root/.local/share/godot/export_templates/4.1.4.stable
cp templates/android_debug.apk templates/android_release.apk /root/.local/share/godot/export_templates/4.1.4.stable/
```

Point Godot's editor settings (`/root/.config/godot/editor_settings-4.tres`)
at the fake SDK and the keystore — a fresh file already has the right keys,
just empty, so `sed` them in:

```bash
sed -i \
  -e 's|export/android/android_sdk_path = ""|export/android/android_sdk_path = "/opt/android-sdk-fake"|' \
  -e 's|export/android/debug_keystore = ""|export/android/debug_keystore = "/root/.android/debug.keystore"|' \
  /root/.config/godot/editor_settings-4.tres
```

Then export:

```bash
godot4 --headless --path . --export-debug "Android" build/Tappy-debug.apk
```

`build/` is gitignored. The resulting APK is signed with a locally-generated
debug key (not the repo owner's real signing key, not Play Store) — fine for
direct sideload testing, expect an Android "unknown source" prompt on
install.
