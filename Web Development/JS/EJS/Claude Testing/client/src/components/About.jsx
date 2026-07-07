export default function About() {
  return (
    <section id="about" className="section">
      <div className="section-label">About</div>
      <h2 className="section-title">A little about me</h2>
      <div className="about-grid">
        <div className="about-text">
          <p>I'm a web developer with a strong interest in building products that live on the internet. Currently learning and growing through hands-on projects — from frontend styling to full-stack applications with Node.js, Express, and React.</p>
          <p>When I'm not coding, I enjoy exploring new technologies and continuously expanding my skill set.</p>
        </div>
        <div className="about-stats">
          {[
            { number: "5", label: "Projects Built" },
            { number: "5+",  label: "Technologies" },
            { number: "100%", label: "Passion" },
            { number: "∞",   label: "Curiosity" },
          ].map((s) => (
            <div className="stat-card" key={s.label}>
              <div className="stat-number">{s.number}</div>
              <div className="stat-label">{s.label}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
