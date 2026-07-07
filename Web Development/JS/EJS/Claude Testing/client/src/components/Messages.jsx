import { useEffect, useState } from "react";

export default function Messages() {
  const [messages, setMessages] = useState([]);

  function load() {
    fetch("/api/messages")
      .then((res) => res.json())
      .then(setMessages);
  }

  useEffect(() => { load(); }, []);

  async function markRead(id) {
    await fetch(`/api/messages/${id}/read`, { method: "PATCH" });
    load();
  }

  async function remove(id) {
    await fetch(`/api/messages/${id}`, { method: "DELETE" });
    load();
  }

  return (
    <div className="messages-page">
      <div className="messages-header">
        <h1>Inbox <span className="msg-count">{messages.length}</span></h1>
      </div>

      {messages.length === 0 ? (
        <p className="no-messages">No messages yet.</p>
      ) : (
        <div className="messages-list">
          {messages.map((msg) => (
            <div className={`msg-card ${msg.read ? "read" : "unread"}`} key={msg.id}>
              <div className="msg-meta">
                <div>
                  <span className="msg-name">{msg.name}</span>
                  <span className="msg-email">{msg.email}</span>
                </div>
                <span className="msg-date">{new Date(msg.created_at).toLocaleString()}</span>
              </div>
              <p className="msg-body">{msg.message}</p>
              <div className="msg-actions">
                {!msg.read && (
                  <button className="btn btn-ghost btn-sm" onClick={() => markRead(msg.id)}>
                    Mark as read
                  </button>
                )}
                <button className="btn btn-danger btn-sm" onClick={() => remove(msg.id)}>
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
