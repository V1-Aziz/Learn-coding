import db from "../db.js";

export function getAllMessages() {
  return db.prepare("SELECT * FROM messages ORDER BY created_at DESC").all();
}

export function createMessage(name, email, message) {
  db.prepare("INSERT INTO messages (name, email, message) VALUES (?, ?, ?)").run(name, email, message);
}

export function markAsRead(id) {
  db.prepare("UPDATE messages SET read = 1 WHERE id = ?").run(id);
}

export function deleteMessage(id) {
  db.prepare("DELETE FROM messages WHERE id = ?").run(id);
}
