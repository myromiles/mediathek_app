const express = require('express');
const cors = require('cors');
const path = require('path');
const app = express();
const PORT = 7000;

app.use(cors());
app.use(express.json());

// Serviert die fertig kompilierte Flutter Web-App direkt aus build/web
app.use(express.static(path.join(__dirname, 'build', 'web')));

async function fetchMediathekData(query = "", channel = "Alle", length = 30) {
  const url = "https://mediathekviewweb.de/api/query";
  
  const queries = [];
  if (query && query.trim() !== "") {
    queries.push({
      fields: ["title", "topic"],
      query: query.trim()
    });
  }
  if (channel && channel !== "Alle") {
    queries.push({
      fields: ["channel"],
      query: channel
    });
  }

  const bodyData = {
    queries: queries,
    sortBy: "timestamp",
    sortOrder: "desc",
    future: false,
    size: length
  };

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(bodyData)
    });

    const data = await response.json();
    if (!data.result || !data.result.results) return [];

    return data.result.results;
  } catch (error) {
    console.error("Fehler beim Abrufen der MediathekView API:", error);
    return [];
  }
}

app.get('/api/mediathek', async (req, res) => {
  const searchQuery = req.query.q || "";
  const channel = req.query.channel || "Alle";
  const size = parseInt(req.query.size) || 30;
  const items = await fetchMediathekData(searchQuery, channel, size);

  res.json({
    "result": {
      "results": items
    }
  });
});

// Fallback für Flutter Web-Routing
app.use((req, res, next) => {
  if (!req.path.startsWith('/api')) {
    res.sendFile(path.join(__dirname, 'build', 'web', 'index.html'));
  } else {
    next();
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`MediathekView App läuft auf http://localhost:${PORT}`);
});
