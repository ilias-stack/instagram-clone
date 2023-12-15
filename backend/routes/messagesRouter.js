const router = require("express").Router();
const path = require("path");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const asyncHandler = require("express-async-handler");

router.get(
  "/conversationsof",
  asyncHandler(async (req, res) => {
    try {
      const userId = req.query.userId;
      const convos = await prisma.conversation.findMany({
        where: {
          OR: [{ senderId: +userId }, { receiverId: +userId }],
        },
      });

      const response = await Promise.all(
        convos.map(async (conversation) => {
          const lastMessage = await prisma.message.findMany({
            where: { conversationId: conversation["id"] },
            select: {
              message: true,
              sharedPostId: true,
              directionIsPositive: true,
              sendingTime: true,
            },
            orderBy: {
              id: "desc",
            },
            take: 1,
          });
          return { conversation, lastMessage };
        })
      );

      response.sort((a, b) => {
        const sendingTimeA = a.lastMessage[0]?.sendingTime || ""; // Default to empty string if sendingTime is not available
        const sendingTimeB = b.lastMessage[0]?.sendingTime || "";

        return new Date(sendingTimeB) - new Date(sendingTimeA);
      });

      res.json(response);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/createConvo",
  asyncHandler(async (req, res) => {
    const { senderId, receiverId } = req.body;
    let receiver = await prisma.user.findFirst({
      where: { id: +receiverId },
      select: { isOnline: true, profilePictureId: true, username: true },
    });
    try {
      let convo = await prisma.conversation.findFirst({
        where: {
          OR: [
            { senderId: +senderId, receiverId: +receiverId },
            { senderId: +receiverId, receiverId: +senderId },
          ],
        },
      });
      if (!convo)
        convo = await prisma.conversation.create({
          data: { senderId: +senderId, receiverId: +receiverId },
        });
      res.json({ data: convo, receiver });
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/deleteConvo/:id",
  asyncHandler(async (req, res) => {
    try {
      const deletedConvo = await prisma.conversation.delete({
        where: { id: +req.params.id },
      });
      res.json(deletedConvo);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/sendMessage",
  asyncHandler(async (req, res) => {
    try {
      const { conversationId, directionIsPositive, message, sharedPostId } =
        req.body;
      const sentMessage = await prisma.message.create({
        data: {
          conversationId: +conversationId,
          directionIsPositive,
          message,
          sharedPostId: sharedPostId != null ? +sharedPostId : undefined,
        },
      });
      res.json(sentMessage);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/getMessages",
  asyncHandler(async (req, res) => {
    try {
      const convoId = req.query.convoId;
      const page = req.query.page || 0;
      const messages = await prisma.message.findMany({
        skip: +page * 8,
        take: 8,
        where: { conversationId: +convoId },
        orderBy: { sendingTime: "desc" },
      });
      res.json(messages.reverse());
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/getMessagesSince",
  asyncHandler(async (req, res) => {
    try {
      const convoId = req.query.convoId;
      const lastMsgId = req.query.messageId;
      const messages = await prisma.message.findMany({
        where: { conversationId: +convoId, id: { gt: +lastMsgId } },
        orderBy: { sendingTime: "desc" },
      });
      res.json(messages.reverse());
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

module.exports = router;
