const router = require("express").Router();
const path = require("path");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const asyncHandler = require("express-async-handler");

router.post(
  "/follow",
  asyncHandler(async (req, res) => {
    try {
      const { follower, following } = req.body;
      const followEntity = await prisma.follow.create({
        data: { followerId: +follower, followingId: +following },
      });
      res.send(followEntity);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/unfollow",
  asyncHandler(async (req, res) => {
    try {
      const { follower, following } = req.body;
      const followDelete = await prisma.follow.delete({
        where: {
          followerId_followingId: {
            followerId: +follower,
            followingId: +following,
          },
        },
      });
      res.send(followDelete);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/followcheck",
  asyncHandler(async (req, res) => {
    try {
      const { follower, following } = req.query;
      await prisma.follow.findFirstOrThrow({
        where: { followerId: +follower, followingId: +following },
      });
      res.send(true);
    } catch (error) {
      res.status(404).send(false);
    }
  })
);

router.get(
  "/followsCount",
  asyncHandler(async (req, res) => {
    try {
      const { userId } = req.query;
      const followers = await prisma.follow.count({
        where: { followingId: +userId },
      });
      const followings = await prisma.follow.count({
        where: { followerId: +userId },
      });
      res.send({ followers, followings });
    } catch (error) {
      res.status(404).send(error.message);
    }
  })
);

module.exports = router;
