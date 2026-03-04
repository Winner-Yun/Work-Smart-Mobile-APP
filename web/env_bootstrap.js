async function loadGoogleMapsFromEnv() {
  try {
    const response = await fetch("assets/.env", { cache: "no-store" });
    if (!response.ok) return;

    const envContent = await response.text();
    const keyLine = envContent
      .split("\n")
      .map((line) => line.trim())
      .find((line) => line.startsWith("GOOGLE_MAPS_API_KEY="));

    if (!keyLine) return;

    const key = keyLine.split("=").slice(1).join("=").trim();
    if (!key) return;

    const mapsScript = document.createElement("script");
    mapsScript.src = `https://maps.googleapis.com/maps/api/js?key=${encodeURIComponent(key)}`;
    document.head.appendChild(mapsScript);

    await new Promise((resolve, reject) => {
      mapsScript.onload = resolve;
      mapsScript.onerror = reject;
    });
  } catch (_) {
    // Continue bootstrapping app even if Maps script loading fails.
  }
}

async function bootstrapFlutter() {
  await loadGoogleMapsFromEnv();
  const flutterBootstrap = document.createElement("script");
  flutterBootstrap.src = "flutter_bootstrap.js";
  flutterBootstrap.async = true;
  document.body.appendChild(flutterBootstrap);
}

bootstrapFlutter();
