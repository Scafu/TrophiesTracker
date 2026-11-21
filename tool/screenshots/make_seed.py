"""Builds seed.sql: a believable Steam library for the screenshots, made of real
games, real achievement schemas and real cover art read from the public routes of
the Worker. Progress and unlock dates are generated (seeded, so it is repeatable).
Nothing here comes from a real account."""
import json, random, time, datetime, subprocess, sys

W = "https://trophiestracker.alessandro-mazzariol04.workers.dev"
OUT = sys.argv[1]

# appid, share of trophies unlocked
GAMES = [
    (620, 1.00),      # Portal 2
    (504230, 1.00),   # Celeste
    (1145360, 0.62),  # Hades
    (105600, 0.78),   # Terraria
    (413150, 0.86),   # Stardew Valley (almost there)
    (367520, 0.92),   # Hollow Knight (almost there)
    (1245620, 0.34),  # Elden Ring
    (292030, 0.47),   # The Witcher 3
    (1091500, 0.28),  # Cyberpunk 2077
    (646570, 0.55),   # Slay the Spire
    (1794680, 0.95),  # Vampire Survivors (almost there)
    (1086940, 0.12),  # Baldur's Gate 3
    (892970, 0.0),    # Valheim (not started)
    (2379780, 0.70),  # Balatro
]


def get(path):
    for attempt in range(3):
        try:
            # curl is a plain client; Cloudflare's browser check blocks Python's default agent
            out = subprocess.run(["curl", "-s", "-m", "30", "-f", W + path], capture_output=True, check=True)
            return json.loads(out.stdout)
        except Exception as e:  # noqa
            time.sleep(1.5)
    return None


def q(value):
    if value is None:
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


rng = random.Random(20261121)
now = datetime.datetime.now()

# Days of activity over the last 20 weeks: more on weekends, with streaks and quiet spells.
days = []
for back in range(0, 139):
    d = (now - datetime.timedelta(days=back)).date()
    weight = 0.55 if d.weekday() >= 5 else 0.32
    if rng.random() < 0.18:        # a streak start
        weight = 0.95
    if rng.random() < weight:
        days.append((d, 1 + int(rng.random() ** 2 * 5)))
day_pool = [d for d, w in days for _ in range(w)]

covers = get("/covers?ids=" + ",".join(str(a) for a, _ in GAMES)) or {}
rows_games, rows_trophies = [], []
ts = lambda dt: int(dt.timestamp())

for position, (appid, share) in enumerate(GAMES):
    detail = get(f"/game?appid={appid}")
    data = (detail or {}).get(str(appid), {}).get("data") if detail else None
    schema = get(f"/achievements?appid={appid}&l=english")
    rarity = get(f"/rarity?appid={appid}") or {}
    achievements = ((schema or {}).get("game", {}).get("availableGameStats", {}) or {}).get("achievements", [])
    if not data or not achievements:
        print(f"skip {appid}: no data", file=sys.stderr)
        continue

    name = data["name"]
    publisher = json.dumps(data.get("developers") or data.get("publishers") or [])
    library = (covers.get(str(appid)) or {}).get("library")
    added = now - datetime.timedelta(days=200 - position * 9)
    rows_games.append(
        "INSERT OR REPLACE INTO games (platform,code,name,publisher,description,header_image,library_image,added_at,platform_source,is_synced) VALUES "
        f"('steam',{q(str(appid))},{q(name)},{q(publisher)},{q(data.get('short_description'))},{q(data.get('header_image'))},{q(library)},{ts(added)},'steam',1);"
    )

    # the most common achievements are unlocked first, like in a real playthrough
    order = sorted(range(len(achievements)), key=lambda i: -rarity.get(achievements[i]["name"], 0))
    unlocked = set(order[: round(share * len(achievements))])
    stamps = sorted(rng.choice(day_pool) for _ in unlocked)
    stamp_of = {}
    for index, when in zip(sorted(unlocked, key=lambda i: order.index(i)), stamps):
        evening = datetime.datetime.combine(when, datetime.time(rng.randint(17, 23), rng.randint(0, 59)))
        stamp_of[index] = ts(evening)

    for i, ach in enumerate(achievements):
        achieved = i in unlocked
        rows_trophies.append(
            "INSERT OR REPLACE INTO trophies (api_name,display_name,description,icon,colored_icon,is_achieved,achieved_at,hidden,game_platform,game_code) VALUES "
            f"({q(ach['name'])},{q(ach.get('displayName') or ach['name'])},{q(ach.get('description') or '')},"
            f"{q(ach.get('icongray') or ach.get('icon'))},{q(ach.get('icon'))},{1 if achieved else 0},"
            f"{q(stamp_of.get(i)) if achieved else 'NULL'},0,'steam',{q(str(appid))});"
        )
    print(f"{name}: {len(achievements)} trophies, {len(unlocked)} unlocked", file=sys.stderr)

with open(OUT, "w", encoding="utf-8") as f:
    f.write("BEGIN;\nDELETE FROM trophies; DELETE FROM activities; DELETE FROM games;\n")
    f.write("\n".join(rows_games) + "\n" + "\n".join(rows_trophies) + "\nCOMMIT;\n")
print(f"{len(rows_games)} games, {len(rows_trophies)} trophies -> {OUT}", file=sys.stderr)
