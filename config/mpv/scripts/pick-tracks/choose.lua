-- Pure track-choice logic, no mpv dependency (unit-tested by choose_test.lua).
-- Policy: when a file has Japanese audio, play it with full English subtitles.
-- Files without Japanese audio are left to mpv's defaults.
local M = {}

local function lang_is(track, codes)
  local lang = (track.lang or ""):lower():gsub("[-_].*$", "")
  for _, c in ipairs(codes) do if lang == c then return true end end
  return false
end

local JAPANESE = { "jpn", "ja", "jp" }
local ENGLISH = { "eng", "en" }

-- Lower is better. Full dialogue tracks (which include song lyrics) win;
-- hearing-impaired next; dub-sync and signs-only tracks last.
local function sub_rank(track)
  local title = (track.title or ""):lower()
  if title:find("sign") or track.forced then return 4 end
  if title:find("dub") then return 3 end
  if track["hearing-impaired"] or title:find("sdh") or title:find("%f[%w]cc%f[%W]") or title:find("hearing") then return 2 end
  return 1
end

local function best(tracks, type_, codes, rank)
  local pick, pick_rank
  for _, t in ipairs(tracks) do
    if t.type == type_ and lang_is(t, codes) then
      local r = rank and rank(t) or 1
      if not t.default then r = r + 0.5 end -- default flag breaks ties only
      if not pick or r < pick_rank then pick, pick_rank = t, r end
    end
  end
  return pick and pick.id or nil
end

-- Returns aid, sid to select (nil = leave as mpv chose).
function M.pick(tracks)
  local aid = best(tracks, "audio", JAPANESE)
  if not aid then return nil, nil end
  return aid, best(tracks, "sub", ENGLISH, sub_rank)
end

return M
