import projects from "../models/projectModel.js";

export function getProjects(req, res) {
  res.json(projects);
}
