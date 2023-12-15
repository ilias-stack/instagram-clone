const router = require("express").Router();
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const asyncHandler = require("express-async-handler");

const multer = require("multer");
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

router.post(
  "/create",
  asyncHandler(async (req, res) => {
    try {
      const { description, userId, length } = req.body;
      const post = await prisma.post.create({
        data: {
          description,
          userId,
          length,
        },
      });
      res.json(post);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  })
);

router.get(
  "/delete/:id",
  asyncHandler(async (req, res) => {
    try {
      const postId = +req.params.id;
      const deletedPost = await prisma.post.delete({
        where: { id: postId },
      });
      res.json(deletedPost);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/suggestfor",
  asyncHandler(async (req, res) => {
    const userId = req.query.userId;
    try {
      const follows = await prisma.follow.findMany({
        where: { followerId: +userId },
      });
      const suggestions = new Array();
      for (let i = 0; i < follows.length; i++) {
        const suggestion = await prisma.post.findMany({
          where: { userId: follows[i].followingId },
          select: { id: true },
        });
        suggestions.push(suggestion.map((e) => e.id));
      }

      res.json(suggestions.flat().sort(() => Math.random() - 0.5));
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/discover",
  asyncHandler(async (req, res) => {
    try {
      const discover = await prisma.post.findMany({
        orderBy: { id: "desc" },
        take: 10,
      });
      res.json(discover);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/savedPosts",
  asyncHandler(async (req, res) => {
    const userId = +req.query.userId;
    try {
      const savedPosts = await prisma.save.findMany({
        where: { userId },
        select: { postId: true },
        orderBy: { id: "desc" },
      });
      res.json(savedPosts.map((e) => e.postId));
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/:id",
  asyncHandler(async (req, res) => {
    const post = await prisma.post.findUnique({
      where: { id: +req.params.id },
      include: {
        User: {
          select: {
            id: true,
            username: true,
            profilePictureId: true,
          },
        },
        PostImage: {
          select: {
            id: true,
          },
        },
      },
    });
    if (!post) {
      res.status(404).send("Post not found");
      return;
    }
    res.json(post);
  })
);

router.get(
  "/postImages/:id",
  asyncHandler(async (req, res) => {
    const postImg = await prisma.postImage.findMany({
      where: { postId: +req.params.id },
    });
    if (!postImg) {
      res.status(404).send("Images were not found");
      return;
    }

    res.json(postImg.map((p) => p.id));
  })
);

router.post(
  "/postImage",
  upload.single("file"),
  asyncHandler(async (req, res) => {
    if (req.file) {
      const { buffer, mimetype } = req.file;
      const postId = req.body.postId;

      const media = await prisma.postImage.create({
        data: {
          data: buffer,
          type: mimetype,
          postId: +postId,
        },
      });

      res.status(200).json(media.id);
    } else {
      res.status(400).json({ error: "No file uploaded" });
    }
  })
);

router.get(
  "/postImage/:id",
  asyncHandler(async (req, res) => {
    const media = await prisma.postImage.findUnique({
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

router.get(
  "/userPostsReview/:id",
  asyncHandler(async (req, res) => {
    const userId = parseInt(req.params.id);
    try {
      const postsReview = await prisma.post.findMany({
        where: {
          userId: userId,
        },
        select: {
          id: true,
          length: true,
        },
        orderBy: { id: "desc" },
      });

      const promises = postsReview.map(async (pr) => {
        pr.reviewImage = await prisma.postImage.findFirst({
          where: { postId: pr.id },
          select: { id: true },
        });
        pr.reviewImage = pr.reviewImage != null ? pr.reviewImage.id : null;

        return pr;
      });

      const postsWithReviewImages = await Promise.all(promises);

      res.json({ P: postsWithReviewImages, L: postsWithReviewImages.length });
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/:id/commentsCount",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    try {
      const commentCount = await prisma.comment.count({ where: { postId } });
      res.json(commentCount);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/:id/likesCount",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    try {
      const likeCount = await prisma.like.count({ where: { postId } });
      res.json(likeCount);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/:id/postComment",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    const { text, userId } = req.body;
    try {
      const comment = await prisma.comment.create({
        data: { text, userId, postId },
      });
      res.json(
        await prisma.comment.findUnique({
          where: { id: comment.id },
          include: {
            user: {
              select: {
                id: true,
                username: true,
                profilePictureId: true,
              },
            },
          },
        })
      );
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/:id/getAllComments",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    try {
      const comments = await prisma.comment.findMany({
        where: { postId },
        orderBy: { id: "desc" },
        include: {
          user: {
            select: {
              id: true,
              username: true,
              profilePictureId: true,
            },
          },
        },
      });
      res.json(comments);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/:id/likePost",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    const { userId } = req.body;
    try {
      const like = await prisma.like.create({
        data: { userId, postId },
      });
      res.json(like);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/:id/unlikePost",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    const { userId } = req.body;
    try {
      const like = await prisma.like.deleteMany({
        where: { userId, postId },
      });
      res.json(like);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/:id/alreadyLikes",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    const userId = +req.query.userId;
    try {
      const likes = await prisma.like.findFirst({ where: { postId, userId } });
      if (likes) res.json(true);
      else res.json(false);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/:id/savePost",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    const { userId } = req.body;
    try {
      const saveEntity = await prisma.save.create({
        data: { userId, postId },
      });
      res.json(saveEntity);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/:id/alreadySaved",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    const userId = +req.query.userId;
    try {
      const saved = await prisma.save.findFirst({ where: { postId, userId } });
      if (saved) res.json(true);
      else res.json(false);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/:id/unsavePost",
  asyncHandler(async (req, res) => {
    const postId = parseInt(req.params.id);
    const { userId } = req.body;
    try {
      const save = await prisma.save.deleteMany({
        where: { userId, postId },
      });
      res.json(save);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/:id/deleteComment",
  asyncHandler(async (req, res) => {
    const commentId = parseInt(req.params.id);
    try {
      const deletedComment = await prisma.comment.delete({
        where: { id: commentId },
      });
      res.json(deletedComment);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

module.exports = router;
