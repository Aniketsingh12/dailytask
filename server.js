// Signal Deck server — serves dashboard.html and a shared /api/state endpoint
// backed by tasks.json, so every device hitting this URL sees the same list.
// Railway sets PORT automatically; falls back to 8000 for local runs.
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8000;
const ROOT = __dirname;
const STATE_FILE = path.join(ROOT, 'tasks.json');

const MIME = {
  '.html': 'text/html', '.htm': 'text/html', '.js': 'application/javascript',
  '.css': 'text/css', '.json': 'application/json', '.svg': 'image/svg+xml',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.ico': 'image/x-icon'
};

function send(res, status, body, contentType){
  res.writeHead(status, { 'Content-Type': contentType });
  res.end(body);
}

const server = http.createServer((req, res) => {
  const urlPath = decodeURIComponent(req.url.split('?')[0]);

  if (urlPath === '/api/state' && req.method === 'GET') {
    fs.readFile(STATE_FILE, 'utf8', (err, data) => {
      send(res, 200, err ? 'null' : data, 'application/json');
    });
    return;
  }

  if (urlPath === '/api/state' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        JSON.parse(body); // validate before writing
        fs.writeFile(STATE_FILE, body, 'utf8', (err) => {
          if (err) return send(res, 500, JSON.stringify({ error: 'write failed' }), 'application/json');
          send(res, 200, JSON.stringify({ ok: true }), 'application/json');
        });
      } catch (e) {
        send(res, 400, JSON.stringify({ error: 'invalid JSON' }), 'application/json');
      }
    });
    return;
  }

  let filePath = urlPath === '/' ? '/dashboard.html' : urlPath;
  filePath = path.join(ROOT, filePath);

  // Prevent path traversal outside ROOT.
  if (!filePath.startsWith(ROOT)) {
    return send(res, 403, 'Forbidden', 'text/plain');
  }

  fs.readFile(filePath, (err, data) => {
    if (err) return send(res, 404, `404 Not Found: ${urlPath}`, 'text/plain');
    const ext = path.extname(filePath);
    send(res, 200, data, MIME[ext] || 'application/octet-stream');
  });
});

server.listen(PORT, () => {
  console.log(`Signal Deck listening on port ${PORT}`);
});
