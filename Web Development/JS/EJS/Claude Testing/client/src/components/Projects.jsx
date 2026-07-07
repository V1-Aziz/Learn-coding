import { useEffect, useState } from "react";

export default function Projects() {
  const [projects, setProjects] = useState([]);

  useEffect(() => {
    fetch("/api/projects")
      .then((res) => res.json())
      .then(setProjects);
  }, []);

  return (
    <section id="projects" className="section">
      <div className="section-label">Projects</div>
      <h2 className="section-title">Things I've built</h2>
      <p className="section-sub">A selection of projects from my learning journey.</p>
      <div className="projects-grid">
        {projects.map((project) => (
          <div className="project-card" key={project.id}>
            <div className="project-tag">{project.tag}</div>
            <h3>{project.title}</h3>
            <p>{project.description}</p>
            <div className="project-footer">
              {project.stack.map((tech) => (
                <span className="tag" key={tech}>{tech}</span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
