// Runs on krillion.io/party. Only acts when the URL has #autojoin=<size>[-rated],
// e.g. #autojoin=3s or #autojoin=3s-rated. Sizes: 1v1, 3s, 4-6, 8-10.
(() => {
  const m = location.hash.match(/^#autojoin=([\w–-]+?)(-rated)?$/i);
  if (!m) return;
  const size = m[1].toLowerCase().replace("–", "-");
  const rated = !!m[2];
  history.replaceState(null, "", location.pathname + location.search); // don't re-join on reload

  const norm = (s) => s.trim().toLowerCase().replace("–", "-");
  const findBtn = (sel, test) => [...document.querySelectorAll(sel)].find((b) => test(norm(b.innerText)));

  function waitFor(fn, ms = 15000) {
    return new Promise((resolve) => {
      const t0 = Date.now();
      (function poll() {
        const el = fn();
        if (el || Date.now() - t0 > ms) return resolve(el);
        setTimeout(poll, 150);
      })();
    });
  }

  async function join() {
    const sizeBtn = await waitFor(() => findBtn("button.pf-size", (t) => t === size));
    if (!sizeBtn) return console.warn("[krillion] size button not found:", size);
    sizeBtn.click();
    // Quick Play needs a name. The site remembers it after your first game;
    // until then, leave the name box focused for you to type in.
    const nameBox = document.querySelector('input[placeholder*="ring"], .pf-name input, input[type="text"]');
    if (nameBox && !nameBox.value.trim()) {
      nameBox.focus();
      return console.info("[krillion] enter a name once, then auto-join takes over");
    }
    await new Promise((r) => setTimeout(r, 300));
    const play = await waitFor(() =>
      findBtn("button.ds-begin-btn", (t) => (rated ? t.includes("rated") : t.includes("quick play")))
    );
    if (!play) return console.warn("[krillion] play button not found");
    play.click();
  }

  try {
    chrome.runtime.sendMessage("krillion-autojoin?", (res) => {
      if (chrome.runtime.lastError || !res || res.go) join();
    });
  } catch {
    join();
  }
})();
