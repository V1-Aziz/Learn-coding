import express from "express";
import cors from "cors";

import skillRoutes from "./routes/skillRoutes.js";
import projectRoutes from "./routes/projectRoutes.js";
import messageRoutes from "./routes/messageRoutes.js";

const app = express();
const port = 3000;

app.use(cors({ origin: "http://localhost:5173" }));
app.use(express.json());

app.use("/api/skills", skillRoutes);
app.use("/api/projects", projectRoutes);
app.use("/api/messages", messageRoutes);

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
