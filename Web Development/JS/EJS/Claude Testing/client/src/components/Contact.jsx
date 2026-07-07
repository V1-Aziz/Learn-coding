import { useState } from "react";

export default function Contact() {
  const [form, setForm] = useState({ name: "", email: "", message: "" });
  const [status, setStatus] = useState(null);

  function handleChange(e) {
    setForm({ ...form, [e.target.name]: e.target.value });
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setStatus(null);
    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (res.ok) {
        setStatus({ type: "success", text: data.message });
        setForm({ name: "", email: "", message: "" });
      } else {
        setStatus({ type: "error", text: data.error });
      }
    } catch {
      setStatus({ type: "error", text: "Something went wrong. Try again." });
    }
  }

  return (
    <section id="contact" className="section">
      <div className="section-label">Contact</div>
      <h2 className="section-title">Let's connect</h2>
      <div className="contact-card">
        <h3>Send me a message</h3>
        <form className="contact-form" onSubmit={handleSubmit}>
          <input
            type="text"
            name="name"
            placeholder="Your name"
            value={form.name}
            onChange={handleChange}
            required
          />
          <input
            type="email"
            name="email"
            placeholder="Your email"
            value={form.email}
            onChange={handleChange}
            required
          />
          <textarea
            name="message"
            placeholder="Your message"
            value={form.message}
            onChange={handleChange}
            required
          />
          <button type="submit" className="btn btn-primary">Send Message</button>
          {status && (
            <p className={`form-status ${status.type}`}>{status.text}</p>
          )}
        </form>
      </div>
    </section>
  );
}
