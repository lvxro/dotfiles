// Personal settings (name, links, weather location, AniList user) live in config.js.
const cfg = window.NEWTAB_CONFIG || {};
const $ = (id) => document.getElementById(id);

// ---- clock, greeting, dates and the day progress bar
const JP_DAYS = ['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'];
function greeting(h) {
  if (h < 6) return ['Still up', 'おやすみ'];
  if (h < 12) return ['Good morning', 'おはよう'];
  if (h < 20) return ['Good afternoon', 'こんにちは'];
  return ['Good evening', 'こんばんは'];
}
function tick() {
  const now = new Date();
  const hh = String(now.getHours()).padStart(2, '0');
  const mm = String(now.getMinutes()).padStart(2, '0');
  $('time').innerHTML = `${hh}<span class="sep">:</span>${mm}`;
  const [es, jp] = greeting(now.getHours());
  $('greet').innerHTML = `${es}, <span>${cfg.name || 'lvxro'}</span>`;
  $('date').textContent = now.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  $('jp').textContent = `${now.getMonth() + 1}月${now.getDate()}日 ${JP_DAYS[now.getDay()]} · ${jp}`;
  const pct = ((now.getHours() * 60 + now.getMinutes()) / 1440) * 100;
  $('dayBar').style.width = `${pct}%`;
  $('dayPct').textContent = `${Math.round(pct)}% of the day`;
}
tick();
setInterval(tick, 1000);

// ---- calendar: current month, Monday first
function calendar() {
  const now = new Date();
  const y = now.getFullYear(), m = now.getMonth();
  $('calMonth').textContent = now.toLocaleDateString('en-US', { month: 'long' });
  $('calYear').textContent = y;
  const first = (new Date(y, m, 1).getDay() + 6) % 7;
  const days = new Date(y, m + 1, 0).getDate();
  let html = '<tr>' + ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) => `<th>${d}</th>`).join('') + '</tr><tr>';
  for (let i = 0; i < first; i++) html += '<td class="out"></td>';
  for (let d = 1; d <= days; d++) {
    const col = (first + d - 1) % 7;
    const cls = [d === now.getDate() ? 'today' : '', col >= 5 ? 'we' : ''].join(' ').trim();
    html += `<td class="${cls}"><span>${d}</span></td>`;
    if (col === 6 && d < days) html += '</tr><tr>';
  }
  $('cal').innerHTML = html + '</tr>';
}
calendar();

// ---- search with a few bangs; "/" focuses it (Chromium gives the address bar focus on a new tab)
const BANGS = {
  yt: 'https://www.youtube.com/results?search_query=',
  gh: 'https://github.com/search?q=',
  al: 'https://anilist.co/search/anime?search=',
  w: 'https://en.wikipedia.org/w/index.php?search=',
};
$('form').addEventListener('submit', (e) => {
  e.preventDefault();
  const q = $('q').value.trim();
  if (!q) return;
  const bang = q.match(/^!(\w+)\s*(.*)$/);
  if (bang && BANGS[bang[1]]) location.href = BANGS[bang[1]] + encodeURIComponent(bang[2]);
  else if (/^[\w-]+(\.[\w-]+)+(\/\S*)?$/.test(q)) location.href = 'https://' + q;
  else location.href = 'https://www.google.com/search?q=' + encodeURIComponent(q);
});
document.addEventListener('keydown', (e) => {
  if (e.key === '/' && document.activeElement !== $('q')) { e.preventDefault(); $('q').focus(); }
  if (e.key === 'Escape') $('q').blur();
});

// ---- shortcuts
const links = cfg.links || [];
$('linkCount').textContent = links.length;
for (const [name, url] of links) {
  const a = document.createElement('a');
  a.href = url;
  const icon = document.createElement('img');
  icon.src = `https://www.google.com/s2/favicons?sz=64&domain=${new URL(url).hostname}`;
  icon.alt = '';
  a.append(icon, name);
  $('links').append(a);
}

// ---- weather (Open-Meteo, cached for 30 min like the bar)
const CODES = {
  0: ['☀', 'Clear'], 1: ['🌤', 'Mostly clear'], 2: ['⛅', 'Partly cloudy'], 3: ['☁', 'Cloudy'],
  45: ['🌫', 'Fog'], 48: ['🌫', 'Fog'], 51: ['🌦', 'Drizzle'], 53: ['🌦', 'Drizzle'], 55: ['🌦', 'Drizzle'],
  61: ['🌧', 'Rain'], 63: ['🌧', 'Rain'], 65: ['🌧', 'Heavy rain'], 71: ['🌨', 'Snow'], 73: ['🌨', 'Snow'],
  75: ['🌨', 'Snow'], 80: ['🌦', 'Showers'], 81: ['🌦', 'Showers'], 82: ['⛈', 'Heavy showers'],
  95: ['⛈', 'Thunderstorm'], 96: ['⛈', 'Thunderstorm'], 99: ['⛈', 'Thunderstorm'],
};
async function weather() {
  const w = cfg.weather;
  if (!w) { $('wx').hidden = true; return; }
  $('wxCity').textContent = w.name;
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
    } catch { $('wxDesc').textContent = 'offline'; return; }
  }
  const [icon, text] = CODES[data.current.weather_code] || ['🌡', ''];
  $('wxIcon').textContent = icon;
  $('wxTemp').textContent = `${Math.round(data.current.temperature_2m)}°`;
  $('wxDesc').textContent = text;
  $('wxRange').innerHTML = `<span class="lo">↓${Math.round(data.daily.temperature_2m_min[0])}°</span>  ` +
    `<span class="hi">↑${Math.round(data.daily.temperature_2m_max[0])}°</span>`;
}
weather();

// ---- airing today (AniList). With cfg.anilistUser it lists the next episodes of the shows you are
// watching; without it, the most popular shows that air in the next 24 hours.
const ANILIST = 'https://graphql.anilist.co';
async function anilist(query, variables) {
  const r = await fetch(ANILIST, { method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }) });
  return (await r.json()).data;
}
async function airingShows() {
  const now = Math.floor(Date.now() / 1000);
  if (cfg.anilistUser) {
    const d = await anilist(`query($u:String){MediaListCollection(userName:$u,type:ANIME,status:CURRENT){lists{entries{media{
      title{romaji english} siteUrl coverImage{medium} nextAiringEpisode{airingAt episode}}}}}}`, { u: cfg.anilistUser });
    return d.MediaListCollection.lists.flatMap((l) => l.entries.map((e) => e.media))
      .filter((m) => m.nextAiringEpisode)
      .map((m) => ({ ...m, at: m.nextAiringEpisode.airingAt, ep: m.nextAiringEpisode.episode }))
      .sort((a, b) => a.at - b.at);
  }
  const d = await anilist(`query($s:Int,$e:Int){Page(perPage:50){airingSchedules(airingAt_greater:$s,airingAt_lesser:$e,sort:TIME){
    airingAt episode media{title{romaji english} siteUrl coverImage{medium} popularity isAdult}}}}`, { s: now, e: now + 86400 });
  return d.Page.airingSchedules.filter((s) => !s.media.isAdult)
    .sort((a, b) => b.media.popularity - a.media.popularity).slice(0, 3)
    .map((s) => ({ ...s.media, at: s.airingAt, ep: s.episode }))
    .sort((a, b) => a.at - b.at);
}
function until(at) {
  const m = Math.max(0, Math.round((at * 1000 - Date.now()) / 60000));
  if (m >= 1440) return `in ${Math.floor(m / 1440)}d ${Math.floor((m % 1440) / 60)}h`;
  return m >= 60 ? `in ${Math.floor(m / 60)}h ${m % 60}m` : `in ${m}m`;
}
async function airing() {
  const list = $('air');
  if (cfg.anilistUser) $('airTitle').textContent = 'up next';
  let shows;
  try {
    const cached = JSON.parse(localStorage.getItem('airing') || 'null');
    if (cached && cached.u === (cfg.anilistUser || '') && Date.now() - cached.t < 30 * 60 * 1000) shows = cached.d;
  } catch {}
  if (!shows) {
    try {
      shows = await airingShows();
      try { localStorage.setItem('airing', JSON.stringify({ t: Date.now(), u: cfg.anilistUser || '', d: shows })); } catch {}
    } catch { list.innerHTML = '<li class="empty">anilist is offline</li>'; return; }
  }
  shows = shows.filter((s) => s.at * 1000 > Date.now()).slice(0, 3);
  if (!shows.length) { list.innerHTML = '<li class="empty">nothing airing soon</li>'; return; }
  list.innerHTML = '';
  for (const s of shows) {
    const li = document.createElement('li');
    const a = document.createElement('a');
    a.href = s.siteUrl;
    const img = document.createElement('img');
    img.src = s.coverImage.medium;
    img.alt = '';
    const text = document.createElement('div');
    const title = document.createElement('div');
    title.className = 't';
    title.textContent = s.title.english || s.title.romaji;
    const meta = document.createElement('div');
    meta.className = 'm';
    const time = new Date(s.at * 1000).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
    meta.innerHTML = `<i>ep ${s.ep}</i> · ${time} · <b>${until(s.at)}</b>`;
    text.append(title, meta);
    a.append(img, text);
    li.append(a);
    list.append(li);
  }
}
airing();
setInterval(airing, 60 * 1000);
