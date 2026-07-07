import { getAllMessages, createMessage, markAsRead, deleteMessage } from "../models/messageModel.js";

export function getMessages(req, res) {
  const messages = getAllMessages();
  res.json(messages);
}

export function postMessage(req, res) {
  const { name, email, message } = req.body;
  if (!name || !email || !message) {
    return res.status(400).json({ error: "All fields are required." });
  }
  createMessage(name, email, message);
  res.json({ success: true, message: "Message received!" });
}

export function readMessage(req, res) {
  markAsRead(req.params.id);
  res.json({ success: true });
}

export function removeMessage(req, res) {
  deleteMessage(req.params.id);
  res.json({ success: true });
}
