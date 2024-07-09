```bash
#!/bin/bash

# Create the directory
mkdir -p transcription_pwa/icons

# Navigate to the directory
cd transcription_pwa

# Create manifest.json with content
cat <<EOL > manifest.json
{
  "name": "Transcription Service",
  "short_name": "Transcriber",
  "description": "A web app for transcribing audio and video files.",
  "start_url": "/index.html",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    {
      "src": "icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "permissions": [
    "notifications"
  ]
}
EOL

# Create service-worker.js with content
cat <<EOL > service-worker.js
const CACHE_NAME = 'transcription-cache-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/styles.css',
  '/script.js',
  '/manifest.json',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        return response || fetch(event.request);
      })
  );
});

self.addEventListener('activate', event => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (!cacheWhitelist.includes(cacheName)) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

self.addEventListener('sync', event => {
  if (event.tag === 'transcribe') {
    event.waitUntil(transcribe());
  }
});

self.addEventListener('push', event => {
  const options = {
    body: event.data.text(),
    icon: 'icons/icon-192x192.png',
    badge: 'icons/icon-192x192.png'
  };
  event.waitUntil(
    self.registration.showNotification('Transcription Service', options)
  );
});
EOL

# Create index.html with content
cat <<EOL > index.html
