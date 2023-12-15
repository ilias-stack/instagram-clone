const router = require("express").Router();
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const asyncHandler = require("express-async-handler");

const multer = require("multer");
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024,
  },
});

router.post(
  "/profilePic",
  upload.single("file"),
  asyncHandler(async (req, res) => {
    if (req.file) {
      const { buffer, mimetype } = req.file;

      const media = await prisma.profilePicture.create({
        data: {
          data: buffer,
          type: mimetype,
        },
      });

      res.status(200).json(media.id);
    } else {
      res.status(400).json({ error: "No file uploaded" });
    }
  })
);

router.get(
  "/profilePic/:id",
  asyncHandler(async (req, res) => {
    const media = await prisma.profilePicture.findUnique({
      where: { id: +req.params.id },
    });

    if (!media) {
      return res.status(404).send("Media not found");
    }

    const mediaData = Buffer.from(media.data, "base64");
    res.writeHead(200, {
      "Content-Type": media.type,
      "Content-Length": mediaData.length,
    });
    res.end(mediaData);
  })
);

module.exports = router;
