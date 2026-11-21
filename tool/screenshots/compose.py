"""Composes the 1080x1920 presentation images from real captures of the app.

Each image has an eyebrow label, a headline and a line of text on top, a large phone
that runs off the bottom edge and fades into the background, and a "lens" card: a
zoomed crop of the real interface that sticks out of the phone. The backgrounds are
slices of one wide gradient, so the five images read as a single strip.

Run it from this folder; the raw captures are in the folder given second (this one if
it is left out):
    python3 compose.py ../../docs/screenshots [folder with the raw captures]
It needs Google Chrome (headless, macOS path) and network, for the Google Fonts.
"""
import pathlib
import subprocess
import sys

HERE = pathlib.Path(__file__).parent
OUT = pathlib.Path(sys.argv[1])
RAW = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else HERE
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
ICON = (HERE / "../../assets/output-onlinepngtools.png").resolve()

RAW_W, RAW_H = 1280, 2856  # size of a capture
PHONE_W = 780              # outer width of the phone
SCREEN_W = PHONE_W - 40    # inside the frame and the bezel
SHOT_SCALE = SCREEN_W / RAW_W

# eyebrow, headline, text, accent, capture, lens (capture, x, y, w, h in capture pixels,
# scale, left, top, rotation) , footnote
SLIDES = [
    dict(
        name="01-track", shot="01_library_raw.png", accent="#60a5fa", icon=True,
        eyebrow="Trophies Tracker",
        title="All your games,<br>one list",
        text="Steam and PlayStation, always up to date.",
        lens=("03_details_raw.png", 50, 1195, 1181, 384, 0.56, 30, 1450, -2.4),
        note="Independent app. Not affiliated with Steam, Valve, Sony or PlayStation.",
    ),
    dict(
        name="02-explore", shot="02_explore_raw.png", accent="#a78bfa",
        eyebrow="Explore",
        title="Find your<br>next game",
        text="Browse twelve genres or search the whole Steam catalog.",
        lens=("02_explore_raw.png", 60, 1950, 1163, 600, 0.56, 410, 1370, 2.2),
    ),
    dict(
        name="03-trophies", shot="03b_trophies_raw.png", accent="#fbbf24",
        eyebrow="Trophies",
        title="Know what is<br>left to unlock",
        text="Every trophy with its rarity and the day you got it.",
        lens=("03b_trophies_raw.png", 50, 1966, 1181, 322, 0.56, 30, 1470, -2.2),
    ),
    dict(
        name="04-stats", shot="04_stats_raw.png", accent="#fbbf24",
        eyebrow="Stats",
        title="Your progress<br>at a glance",
        text="A heat map of your unlocks and the games you finished most.",
        lens=("04_stats_raw.png", 60, 1905, 1163, 320, 0.56, 410, 1650, 2.2),
    ),
    dict(
        name="05-link", shot="05_settings_raw.png", accent="#22d3ee",
        eyebrow="Connect",
        title="Link Steam<br>and PlayStation",
        text="You sign in on their own pages. The app keeps no password.",
        lens=("05_settings_raw.png", 45, 480, 1190, 455, 0.74, 24, 1500, -2.0),
    ),
]

TEMPLATE = """<!doctype html><html><head><meta charset="utf-8"><style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Kanit:wght@600;700;800&display=swap');
*{{box-sizing:border-box;margin:0;padding:0}}
html,body{{width:1080px;height:1920px;overflow:hidden}}
body{{position:relative;color:#fff;font-family:'Inter','Avenir Next',sans-serif;background-color:#070a1c;
  background-image:
    radial-gradient(1200px 1000px at 560px 120px, rgba(37,99,235,.78), transparent 70%),
    radial-gradient(1000px 900px at 1900px 1300px, rgba(124,58,237,.52), transparent 70%),
    radial-gradient(1100px 900px at 3000px 250px, rgba(245,158,11,.30), transparent 70%),
    radial-gradient(1100px 1000px at 4000px 1250px, rgba(8,145,178,.46), transparent 70%),
    radial-gradient(1100px 900px at 5000px 300px, rgba(37,99,235,.55), transparent 70%),
    linear-gradient(180deg, rgba(5,6,15,0) 0%, rgba(5,6,15,.55) 100%);
  background-size:5400px 1920px;background-position:-{x0}px 0;background-repeat:no-repeat}}
.grain{{position:absolute;inset:0;opacity:.07;mix-blend-mode:overlay;
  background-image:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='220' height='220'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>")}}
.eyebrow{{position:absolute;left:0;right:0;top:104px;display:flex;justify-content:center}}
.pill{{display:inline-flex;align-items:center;gap:14px;padding:11px 26px 11px 20px;border-radius:999px;
  background:rgba(255,255,255,.09);border:1.5px solid rgba(255,255,255,.14);
  font-weight:600;font-size:26px;letter-spacing:3px;text-transform:uppercase}}
.pill i{{width:14px;height:14px;border-radius:50%;background:{accent};box-shadow:0 0 18px {accent}}}
.pill img{{width:36px;height:36px;border-radius:9px}}
h1{{position:absolute;left:0;right:0;top:184px;text-align:center;font-family:'Kanit','Avenir Next',sans-serif;
  font-weight:700;font-size:112px;line-height:1.05;letter-spacing:-0.5px}}
.text{{position:absolute;left:150px;right:150px;top:424px;text-align:center;font-weight:500;font-size:37px;
  line-height:1.36;color:rgba(255,255,255,.74);text-wrap:balance}}
.phone{{position:absolute;left:{px}px;top:610px;width:{pw}px;height:{ph}px;border-radius:118px;padding:5px;
  background:linear-gradient(140deg,#9ba0a9 0%,#3b3e45 16%,#15161b 48%,#2d3036 84%,#757a83 100%);
  box-shadow:0 70px 130px rgba(0,0,0,.65)}}
.bezel{{width:100%;height:100%;border-radius:113px;background:#000;padding:15px}}
.screen{{position:relative;width:100%;height:100%;border-radius:98px;overflow:hidden;background:#000}}
.screen img{{display:block;width:100%;height:100%;object-fit:cover;object-position:top}}
.screen:after{{content:'';position:absolute;inset:0;background:linear-gradient(115deg,rgba(255,255,255,.08) 0%,transparent 32%)}}
.hole{{position:absolute;left:50%;top:30px;width:32px;height:32px;margin-left:-16px;border-radius:50%;background:#000;
  box-shadow:0 0 0 3px rgba(255,255,255,.05);z-index:2}}
.btn{{position:absolute;right:-4px;width:6px;border-radius:3px;background:linear-gradient(90deg,#2b2d32,#5b5f67)}}
.glow{{position:absolute;left:90px;top:640px;width:900px;height:900px;border-radius:50%;opacity:.55;filter:blur(70px);
  background:radial-gradient(closest-side,{accent},transparent)}}
.fade{{position:absolute;left:0;right:0;bottom:0;height:380px;
  background:linear-gradient(180deg,rgba(6,8,22,0) 0%,rgba(6,8,22,.78) 62%,rgba(6,8,22,.96) 100%)}}
.lens{{position:absolute;left:{lx}px;top:{ly}px;width:{lw}px;height:{lh}px;border-radius:34px;overflow:hidden;
  background-image:url("file://{lshot}");background-repeat:no-repeat;
  background-size:{lbw}px {lbh}px;background-position:-{lbx}px -{lby}px;
  transform:rotate({lr}deg);box-shadow:0 46px 90px rgba(0,0,0,.6),0 0 0 2px rgba(255,255,255,.14)}}
.note{{position:absolute;left:60px;right:60px;bottom:46px;text-align:center;font-size:22px;letter-spacing:.4px;
  color:rgba(255,255,255,.6)}}
</style></head><body>
<div class="grain"></div>
<div class="eyebrow"><span class="pill">{pill}{eyebrow}</span></div>
<h1>{title}</h1>
<div class="text">{text}</div>
<div class="glow"></div>
<div class="phone"><div class="btn" style="top:300px;height:130px"></div><div class="btn" style="top:470px;height:230px"></div>
<div class="bezel"><div class="screen"><img src="file://{shot}"><div class="hole"></div></div></div></div>
<div class="fade"></div>
<div class="lens"></div>
{note}
</body></html>"""


def render(index, slide):
    lens_shot, cx, cy, cw, ch, scale, lx, ly, rot = slide["lens"]
    html = TEMPLATE.format(
        x0=index * 1080,
        accent=slide["accent"],
        px=(1080 - PHONE_W) // 2,
        pw=PHONE_W,
        ph=round(SCREEN_W * RAW_H / RAW_W) + 40,
        shot=RAW / slide["shot"],
        pill=f'<img src="file://{ICON}">' if slide.get("icon") else "<i></i>",
        eyebrow=slide["eyebrow"],
        title=slide["title"],
        text=slide["text"],
        lx=lx, ly=ly, lw=round(cw * scale), lh=round(ch * scale),
        lshot=RAW / lens_shot,
        lbw=round(RAW_W * scale), lbh=round(RAW_H * scale),
        lbx=round(cx * scale), lby=round(cy * scale), lr=rot,
        note=f'<div class="note">{slide["note"]}</div>' if slide.get("note") else "",
    )
    page = RAW / f"{slide['name']}.html"
    page.write_text(html, encoding="utf-8")
    target = OUT / f"{slide['name']}.png"
    subprocess.run(
        [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
         "--window-size=1080,1920", "--virtual-time-budget=12000", f"--screenshot={target}", f"file://{page}"],
        check=True, capture_output=True, timeout=180,
    )
    print("wrote", target)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for i, s in enumerate(SLIDES):
        render(i, s)
