const cacheName = 'azimutt'
const assets = [
    '/',
    '/assets/bootstrap.bundle.min.js',
    '/assets/bootstrap.bundle.min.js.map',
    '/assets/bootstrap.min.css',
    '/assets/bootstrap.min.css.map',
    '/assets/insights.js',
    '/assets/sentry-268b122ecafb4f20b6316b87246e509c.min.js',
    '/assets/uuidv4.min.js',
    '/dist/elm.js',
    '/samples/basic.json',
    '/samples/gospeak.sql',
    '/samples/wordpress.sql',
    '/android-chrome-192x192.png',
    '/android-chrome-512x512.png',
    '/apple-touch-icon.png',
    '/browserconfig.xml',
    '/favicon.ico',
    '/favicon-16x16.png',
    '/favicon-32x32.png',
    '/index.html',
    '/logo.png',
    '/mstile-150x150.png',
    '/safari-pinned-tab.svg',
    '/screenshot.png',
    '/screenshot-complex.png',
    '/script.js',
    '/styles.css',
]

self.addEventListener('install', installEvent => {
    installEvent.waitUntil(
        caches.open(cacheName).then(cache => {
            cache.addAll(assets)
        })
    )
})

self.addEventListener('fetch', fetchEvent => {
    fetchEvent.respondWith(
        caches.match(fetchEvent.request).then(res => {
            return res || fetch(fetchEvent.request)
        })
    )
})
