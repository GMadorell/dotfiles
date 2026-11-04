-- Unit tests for choose.lua. Run: luajit config/mpv/scripts/pick-tracks/choose_test.lua
-- Track lists mirror mpv's `track-list` property, modeled on real release files.
package.path = arg[0]:gsub("[^/]+$", "") .. "?.lua;" .. package.path
local choose = require("choose")

local failures = 0
local function check(name, tracks, want_aid, want_sid)
  local aid, sid = choose.pick(tracks)
  if aid ~= want_aid or sid ~= want_sid then
    failures = failures + 1
    print(("FAIL %s: got aid=%s sid=%s, want aid=%s sid=%s"):format(
      name, tostring(aid), tostring(sid), tostring(want_aid), tostring(want_sid)))
  else
    print("ok   " .. name)
  end
end

local function a(id, lang, extra) local t = extra or {}; t.type, t.id, t.lang = "audio", id, lang; return t end
local function s(id, lang, title, extra) local t = extra or {}; t.type, t.id, t.lang, t.title = "sub", id, lang, title; return t end

-- Layout A: full English first, Signs/Songs second.
check("full-first", {
  { type = "video", id = 1 },
  a(1, "jpn"), a(2, "eng"),
  s(1, "eng", "English"), s(2, "eng", "English [Signs/Songs]"), s(3, "fre", "French"),
}, 1, 1)

-- Layout B: English audio default; Signs track default+forced.
check("signs-default", {
  a(1, "eng", { default = true }), a(2, "jpn"),
  s(1, "eng", "Signs", { default = true, forced = true }), s(2, "eng", "Dialogue"), s(3, "eng", "SDH"),
}, 2, 2)

-- Layout C: untitled default English, dub-sync track, CC, signs.
check("untitled-default", {
  a(1, "jpn", { default = true }), a(2, "eng"),
  s(1, "eng", nil, { default = true }), s(2, "eng", "For ENG Dub"), s(3, "chi", "Traditional"),
  s(8, "eng", "English"), s(9, "eng", "English Signs"), s(10, "eng", "English cc"),
}, 1, 1)

-- Dub-sync track listed before the real one must lose.
check("dub-first", {
  a(1, "ja"), s(1, "en", "English (For Dub)"), s(2, "en-US", "English"),
}, 1, 2)

-- Only SDH available beats signs-only.
check("sdh-over-signs", {
  a(1, "jpn"), s(1, "eng", "Signs & Songs"), s(2, "eng", "English SDH"),
}, 1, 2)

-- mpv's hearing-impaired flag (untitled track) ranks below plain dialogue.
check("hi-flag", {
  a(1, "ja"), s(1, "en", nil, { ["hearing-impaired"] = true }), s(2, "en", nil),
}, 1, 2)

-- Signs-only is still better than nothing.
check("signs-fallback", { a(1, "jpn"), s(1, "eng", "Signs") }, 1, 1)

-- Japanese audio but no English subs: switch audio, leave subs alone.
check("no-eng-subs", { a(1, "eng"), a(2, "jpn"), s(1, "spa", "Spanish") }, 2, nil)

-- No Japanese audio (regular English content): touch nothing.
check("english-only", { a(1, "eng"), s(1, "eng", "English") }, nil, nil)

-- No tracks at all.
check("empty", {}, nil, nil)

if failures > 0 then print(failures .. " failure(s)"); os.exit(1) end
print("all passed")
