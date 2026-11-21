// Cache delle risposte di Steam uguali per tutti (vedi docs/features/rate-limiting.md).
//
// Si usa solo per dati che non dipendono da chi chiede: mai per una rotta con
// un token di sessione o con dati di un utente (`/library`, `/user`,
// `/playerAchievements`) e mai per `/psn/*`. Due test lo impongono.
//
// Il Worker gira prima della cache: una risposta servita da qui conta come
// richiesta lo stesso. Serve a non rifare a Steam la stessa domanda.

/** Quanto tenere ogni risposta, in secondi. */
export const TTL = {
  // Dettagli di un gioco: più corto, così una risposta vuota per un guasto dura poco.
  game: 6 * 60 * 60,
  achievements: 24 * 60 * 60,
  rarity: 24 * 60 * 60,
  covers: 24 * 60 * 60,
  catalog: 24 * 60 * 60,
  category: 60 * 60,
};

/**
 * Le opzioni di `fetch` che fanno tenere a Cloudflare la risposta per
 * [seconds]. Solo una risposta riuscita: per gli altri stati il valore
 * negativo vuol dire "non salvare" (lo 0 vorrebbe dire "scade subito").
 */
export function shared(seconds) {
  return {
    cf: {
      cacheEverything: true,
      cacheTtlByStatus: { "200-299": seconds, "300-599": -1 },
    },
  };
}

/**
 * L'intestazione che dice se la risposta di Steam è venuta dalla cache
 * (`HIT`) o no (`MISS`), per verificare che funzioni. Contiene solo quella
 * parola, e niente se Cloudflare non la dà.
 */
export function cacheStatus(response) {
  const status = response.headers.get("cf-cache-status");
  return status ? { "X-Cache": status } : {};
}
