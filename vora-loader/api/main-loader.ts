// api/main-loader.ts  (Vercel akan otomatis deteksi ini sebagai fallback)

export default function handler(req, res) {
  // Kalau ada yang akses /api/main-loader langsung → redirect ke halaman utama
  res.status(200).setHeader('Content-Type', 'text/html').send(`
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Vora Hub Premium</title>
  <meta http-equiv="refresh" content="0;url=/">
  <style>
    body{background:#0d1117;color:#58a6ff;font-family:Segoe UI;text-align:center;padding-top:20vh;}
    h1{font-size:30px;}
    .code{background:#161b22;padding:20px;border:1px solid #30363d;border-radius:10px;display:inline-block;font-family:'Courier New';color:#8fbfff;}
    .footer{margin-top:60px;color:#8b949e;font-size:14px;}
  </style>
</head>
<body>
  <h1>Vora hubScript Premium!</h1>
  <div class="code">loadstring(game:HttpGet("https://vorahub-2fcw.vercel.app/api/main-loader"))()</div>
  <div class="footer">Script Protected • Walvy Community</div>

  <script>
    // Otomatis copy script asli
    fetch('/api/main-loader')
      .then(r => r.text())
      .then(code => navigator.clipboard.writeText(code));
  </script>
</body>
</html>
  `);
}

// Biar Vercel tahu ini route yang sama
export const config = {
  api: {
    bodyParser: false,
  },
};
