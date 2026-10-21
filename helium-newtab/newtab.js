// Personal settings (links, folders, weather location) live in config.js.
const cfg = window.NEWTAB_CONFIG || {};

// ---- background: line bg.jpg (a full-screen render of the wallpaper) up with the desktop
const bg = document.querySelector('.bg');
function alignBackground() {
  // all values are CSS pixels, so this also works with display scaling
  const border = (window.outerWidth - window.innerWidth) / 2;          // invisible resize border
  const left = window.screenX + border;
  const top = window.screenY + (window.outerHeight - window.innerHeight) - border;
  bg.style.backgroundSize = `${screen.width}px ${screen.height}px`;
  bg.style.backgroundPosition = `${-left}px ${-top}px`;
}
alignBackground();
window.addEventListener('resize', alignBackground);
setInterval(alignBackground, 500);   // there is no "window moved" event

// ---- shortcut pills
const nav = document.getElementById('links');
for (const [name, url] of cfg.links || []) {
  const a = document.createElement('a');
  a.href = url;
  const icon = document.createElement('img');
  icon.src = `https://www.google.com/s2/favicons?sz=32&domain=${new URL(url).hostname}`;
  icon.alt = '';
  a.append(icon, name);
  nav.append(a);
}

// ---- 家 folder menu (file:// links need "Allow access to file URLs" on the extension)
const menu = document.getElementById('menu');
for (const [name, path] of cfg.folders || []) {
  const a = document.createElement('a');
  a.textContent = name;
  a.href = '#';
  a.addEventListener('click', (e) => {
    e.preventDefault();
    chrome.tabs.update({ url: 'file:///' + path.replace(/\\/g, '/') });
  });
  menu.append(a);
}
document.getElementById('homeBtn').addEventListener('click', (e) => {
  e.stopPropagation();
  menu.classList.toggle('open');
});
document.addEventListener('click', () => menu.classList.remove('open'));

// ---- clock
const clock = document.getElementById('clock');
const date = document.getElementById('date');
function tick() {
  const now = new Date();
  const hh = String(now.getHours()).padStart(2, '0');
  const mm = String(now.getMinutes()).padStart(2, '0');
  clock.innerHTML = `${hh}<span class="sep">:</span>${mm}`;
  date.textContent = now.toLocaleDateString('es-AR', { weekday: 'long', day: 'numeric', month: 'long' });
}
tick();
setInterval(tick, 1000);

// ---- weather (Open-Meteo, cached for 30 min like the bar)
const CODES = {
  0: ['☀', 'Despejado'], 1: ['🌤', 'Mayormente despejado'], 2: ['⛅', 'Parcialmente nublado'], 3: ['☁', 'Nublado'],
  45: ['🌫', 'Niebla'], 48: ['🌫', 'Niebla'], 51: ['🌦', 'Llovizna'], 53: ['🌦', 'Llovizna'], 55: ['🌦', 'Llovizna'],
  61: ['🌧', 'Lluvia'], 63: ['🌧', 'Lluvia'], 65: ['🌧', 'Lluvia fuerte'], 71: ['🌨', 'Nieve'], 73: ['🌨', 'Nieve'],
  75: ['🌨', 'Nieve'], 80: ['🌦', 'Chaparrones'], 81: ['🌦', 'Chaparrones'], 82: ['⛈', 'Chaparrones fuertes'],
  95: ['⛈', 'Tormenta'], 96: ['⛈', 'Tormenta'], 99: ['⛈', 'Tormenta'],
};
async function weather() {
  const w = cfg.weather;
  if (!w) return;
  const box = document.getElementById('weather');
  let data;
  try {
    const cached = JSON.parse(localStorage.getItem('weather') || 'null');
    if (cached && Date.now() - cached.t < 30 * 60 * 1000) data = cached.d;
  } catch {}
  if (!data) {
    const url = `https://api.open-meteo.com/v1/forecast?latitude=${w.lat}&longitude=${w.lon}` +
      `&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=1`;
    try {
      data = await (await fetch(url)).json();
      try { localStorage.setItem('weather', JSON.stringify({ t: Date.now(), d: data })); } catch {}
    } catch { return; }
  }
  const [icon, text] = CODES[data.current.weather_code] || ['🌡', ''];
  box.innerHTML =
    `<span style="font-size:24px">${icon}</span>` +
    `<span class="temp">${Math.round(data.current.temperature_2m)}°</span>` +
    `<span class="meta">${w.name} · ${text}</span>` +
    `<span class="range">↓${Math.round(data.daily.temperature_2m_min[0])}° ↑${Math.round(data.daily.temperature_2m_max[0])}°</span>`;
  box.hidden = false;
}
weather();
