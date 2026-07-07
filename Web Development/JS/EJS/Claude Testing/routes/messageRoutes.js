import { Router } from "express";
import { getMessages, postMessage, readMessage, removeMessage } from "../controllers/messageController.js";

const router = Router();

router.get("/", getMessages);
router.post("/", postMessage);
router.patch("/:id/read", readMessage);
router.delete("/:id", removeMessage);

export default router;
