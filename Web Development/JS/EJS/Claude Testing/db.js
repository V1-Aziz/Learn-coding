import { DatabaseSync } from "node:sqlite";

const db = new DatabaseSync("portfolio.db");

db.exec(`
  CREATE TABLE IF NOT EXISTS messages (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT NOT NULL,
    email      TEXT NOT NULL,
    message    TEXT NOT NULL,
    read       INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
  )
`);

export default db;
