// Guarda la app en el teléfono para abrirla sin internet.
// Los datos viajan por Supabase y no pasan por aquí.
const CACHE = 'jardin39-v3';
const SHELL = ['./', 'index.html', 'config.js', 'manifest.webmanifest', 'vendor/jspdf.umd.min.js', 'vendor/supabase.js', 'logo.png', 'logo-pdf.png', 'fonts/limelight-latin-400-normal.woff2', 'fonts/josefin-sans-latin-400-normal.woff2', 'fonts/josefin-sans-latin-500-normal.woff2', 'fonts/josefin-sans-latin-700-normal.woff2', 'icon-180.png', 'icon-192.png', 'icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET' || u.origin !== location.origin) return;
  e.respondWith(caches.open(CACHE).then(async c => {
    const hit = await c.match(e.request, { ignoreSearch: true });
    const net = fetch(e.request).then(r => { if (r && r.ok) c.put(e.request, r.clone()); return r; }).catch(() => null);
    return hit || (await net) || c.match('index.html');
  }));
});
