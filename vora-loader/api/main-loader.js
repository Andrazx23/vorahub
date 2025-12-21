// ISI SCRIPT ASLI KAMU TARUH DI SINI (atau ambil dari raw GitHub)
const REAL_SCRIPT_URL = "https://raw.githubusercontent.com/Andrazx23/vorahub/refs/heads/main/keysystem.lua";
// atau kalau mau langsung tulis scriptnya di sini juga boleh (tetap aman)

export default async function handler(req, res) {
  try {
    const response = await fetch(REAL_SCRIPT_URL);
    const luaCode = await response.text();

    const finalCode = `loadstring(game:HttpGet('${REAL_SCRIPT_URL}'))()`;

    res.setHeader('Content-Type', 'text/plain');
    res.setHeader('Cache-Control', 'no-store');
    res.send(finalCode);
  } catch (e) {
    res.status(500).send('-- Error loading script');
  }
}