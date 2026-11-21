"""Composes the 1080x1920 presentation images: a phone frame with a real screenshot
on a blue gradient, and a three-line title below, in the style of the old set."""
import subprocess, pathlib, sys

HERE = pathlib.Path(__file__).parent
OUT = pathlib.Path(sys.argv[1])
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

SLIDES = [
    ("01-track", "01_library_raw.png", "TRACK", "YOUR STEAM AND PLAYSTATION GAMES", "NOT AFFILIATED WITH STEAM OR PLAYSTATION"),
    ("02-explore", "02_explore_raw.png", "EXPLORE", "BY GENRE OR IN THE WHOLE STEAM CATALOG", "FIND YOUR NEXT GAME"),
    ("03-details", "03_details_raw.png", "DETAILS", "EVERY TROPHY, WITH ITS RARITY", "SEE WHAT IS LEFT TO UNLOCK"),
    ("04-stats", "04_stats_raw.png", "STATS", "YOUR PROGRESS AT A GLANCE", "ACTIVITY HEAT MAP AND TOP GAMES"),
    ("05-link", "05_settings_raw.png", "LINK", "STEAM AND PLAYSTATION", "TWO ACCOUNTS, ONE LIST"),
]

TEMPLATE = """<!doctype html><html><head><meta charset="utf-8"><style>
*{{box-sizing:border-box;margin:0;padding:0}}
html,body{{width:1080px;height:1920px;overflow:hidden}}
body{{background:linear-gradient(180deg,#1d4ed8 0%,#15318f 36%,#0c1233 68%,#07070c 100%);
  font-family:'Avenir Next','Helvetica Neue',Arial,sans-serif;color:#fff;position:relative}}
.phone{{position:absolute;left:220px;top:42px;width:640px;height:1368px;border-radius:104px;
  background:linear-gradient(145deg,#4a4d52 0%,#17181b 30%,#0d0e10 70%,#3a3c40 100%);
  padding:7px;box-shadow:0 30px 80px rgba(0,0,0,.55)}}
.bezel{{width:100%;height:100%;border-radius:98px;background:#050506;padding:17px}}
.screen{{position:relative;width:100%;height:100%;border-radius:82px;overflow:hidden;background:#000}}
.screen img{{width:100%;height:100%;object-fit:cover;object-position:top;display:block}}
.hole{{position:absolute;left:50%;top:26px;width:30px;height:30px;margin-left:-15px;border-radius:50%;
  background:#000;box-shadow:0 0 0 3px rgba(255,255,255,.06)}}
.btn{{position:absolute;right:-3px;width:5px;border-radius:3px;background:#2b2d31}}
.text{{position:absolute;left:0;right:0;top:1432px;text-align:center;padding:0 50px}}
.t1{{font-size:172px;line-height:1;font-weight:900;letter-spacing:-2px;margin-bottom:34px}}
.t2{{font-size:56px;line-height:1.12;font-weight:800;letter-spacing:.5px;margin-bottom:24px;text-wrap:balance}}
.t3{{font-size:38px;line-height:1.1;font-weight:700;letter-spacing:1.5px;opacity:.92;text-wrap:balance}}
</style></head><body>
<div class="phone"><div class="btn" style="top:330px;height:120px"></div><div class="btn" style="top:520px;height:210px"></div>
<div class="bezel"><div class="screen"><img src="file://{img}"><div class="hole"></div></div></div></div>
<div class="text"><div class="t1">{a}</div><div class="t2">{b}</div><div class="t3">{c}</div></div>
</body></html>"""

OUT.mkdir(parents=True, exist_ok=True)
for name, shot, a, b, c in SLIDES:
    html = HERE / f"{name}.html"
    html.write_text(TEMPLATE.format(img=HERE / shot, a=a, b=b, c=c), encoding="utf-8")
    target = OUT / f"{name}.png"
    subprocess.run(
        [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
         "--window-size=1080,1920", f"--screenshot={target}", f"file://{html}"],
        check=True, capture_output=True, timeout=120,
    )
    print("wrote", target)
