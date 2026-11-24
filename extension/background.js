// If a Puffer Party tab is already open, focus it instead of joining a second game.
chrome.runtime.onMessage.addListener((msg, sender, reply) => {
  if (msg !== "krillion-autojoin?") return;
  chrome.tabs.query({ url: "https://krillion.io/party*" }).then((tabs) => {
    const other = tabs.find((t) => t.id !== sender.tab.id);
    if (other) {
      chrome.tabs.update(other.id, { active: true });
      chrome.windows.update(other.windowId, { focused: true });
      chrome.tabs.remove(sender.tab.id);
      reply({ go: false });
    } else {
      reply({ go: true });
    }
  });
  return true;
});
