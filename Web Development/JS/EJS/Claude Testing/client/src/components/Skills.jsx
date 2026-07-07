import { useEffect, useState } from "react";

export default function Skills() {
  const [skills, setSkills] = useState([]);

  useEffect(() => {
    fetch("/api/skills")
      .then((res) => res.json())
      .then(setSkills);
  }, []);

  const categories = ["Language", "Framework", "Tool"];

  return (
    <section id="skills" className="section">
      <div className="section-label">Skills</div>
      <h2 className="section-title">Technologies I work with</h2>
      <p className="section-sub">A growing toolkit of languages, frameworks, and tools.</p>

      {categories.map((cat) => {
        const group = skills.filter((s) => s.category === cat);
        if (!group.length) return null;
        return (
          <div key={cat} className="skills-group">
            <h4 className="skills-group-label">{cat}s</h4>
            <div className="skills-grid">
              {group.map((skill) => (
                <div className="skill-card" key={skill.name}>
                  <div className="skill-icon">{skill.icon}</div>
                  <div className="skill-name">{skill.name}</div>
                </div>
              ))}
            </div>
          </div>
        );
      })}
    </section>
  );
}
