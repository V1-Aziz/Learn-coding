import skills from "../models/skillModel.js";

export function getSkills(req, res) {
  res.json(skills);
}
