// api/main-loader.js  ← GANTI YANG LAMA JADI INI

const REAL_SCRIPT_URL = "https://raw.githubusercontent.com/Andrazx23/vorahub/refs/heads/main/keysystem.lua"; // ganti punya kamu

export default async function handler(req, res) {
  // Kalau request minta text/plain → kasih script asli (buat executor)
  if (req.headers.accept?.includes('text/plain')) {
    try {
      const r = await fetch(REAL_SCRIPT_URL);
      const code = await r.text();
      res.setHeader('Content-Type', 'text/plain');
      res.send(`loadstring(game:HttpGet('${REAL_SCRIPT_URL}'))()`);
    } catch {
      res.status(500).send('-- Error');
    }
    return;
  }

  // Kalau bukan text/plain (browser biasa) → kasih halaman loader cantik
  res.status(200).setHeader('Content-Type', 'text/html').send(`
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Vora Hub Premium</title>
  <style>
    body{background:#0d1117;color:#58a6ff;font-family:Segoe UI;text-align:center;padding-top:20vh;}
    h1{font-size:30px;margin-bottom:35px;}
    .code{background:#161b22;padding:20px 28px;border:1px solid #30363d;border-radius:10px;display:inline-block;font-family:'Courier New';font-size:18px;color:#8fbfff;box-shadow:0 4px 12px rgba(0,0,0,0.4);}
    .footer{margin-top:60px;color:#8b949e;font-size:14px;}
  </style>
</head>
<body>
  <h1>Vora hubScript Premium!</h1>
  <div class="code">loadstring(game:HttpGet("https://vorahub1.vercel.app/api/loader"))()</div>
  <div class="footer">Script Protected • Vora Hub</div>

  <script>
    fetch('/api/main-loader', {headers:{'Accept':'text/plain'}})
      .then(r=>r.text())
      .then(c=>navigator.clipboard.writeText(c));
  </script>
</body>
</html>
  `);
}


