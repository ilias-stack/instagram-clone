const router = require("express").Router();
const path = require("path");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const asyncHandler = require("express-async-handler");
const { format } = require("morgan");
const ip = require("ip");
require("dotenv").config();
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_ADDRESS,
    pass: process.env.EMAIL_PASSWORD,
  },
});

router.get("/login", (req, res) => {
  const { identifier, password } = req.query;
  prisma.user
    .findFirstOrThrow({
      where: { OR: [{ email: identifier }, { username: identifier }] },
    })
    .then((result) => {
      if (result.password == password) {
        req.session.currentUser = result;
        res.json(result);
      } else {
        res.status(401).end("Wrong Password");
      }
    })
    .catch((err) => {
      res.status(404).end(err.message);
    });
});

router.post(
  "/signin",
  asyncHandler(async (req, res) => {
    const {
      email,
      username,
      password,
      birthday,
      fullname,
      description,
      profilePictureId,
    } = req.body;
    try {
      const user = await prisma.user.create({
        data: {
          username,
          email,
          password,
          description,
          fullname,
          birthday: new Date(birthday),
          profilePictureId: profilePictureId ? +profilePictureId : undefined,
        },
      });
      req.session.currentUser = user;
      res.json(user);
    } catch (error) {
      if (error.code === "P2002" && error.meta.target.includes("username")) {
        res.status(407).send("Username");
      } else if (
        error.code === "P2002" &&
        error.meta.target.includes("email")
      ) {
        res.status(407).send("Email");
      } else {
        res.status(407).send(error.message);
      }
    }
  })
);

router.get(
  "/session",
  asyncHandler(async (req, res) => {
    try {
      const { id } = req.session.currentUser;
      if (id == undefined) res.status(404).end("No Info");
      else res.json(await prisma.user.findUnique({ where: { id } }));
    } catch (error) {
      res.status(404).json({ message: "No Info" });
    }
  })
);

router.get(
  "/changeOnlineStatus",
  asyncHandler(async (req, res) => {
    const { status } = req.query;
    if (req.session.currentUser) {
      const { id } = req.session.currentUser;
      await prisma.user.update({
        where: { id },
        data: { isOnline: status == "true" },
      });
      res.send("Done!");
    } else {
      res.status(400).send("No session!");
    }
  })
);

router.get(
  "/logout",
  asyncHandler(async (req, res) => {
    if (req.session.currentUser) {
      const { id } = req.session.currentUser;

      await prisma.user.update({
        where: { id },
        data: { isOnline: false },
      });
      req.session.destroy();
      res.send("Logout!");
    } else res.status(400).send("No session!");
  })
);

router.get(
  "/suggestUsersFor",
  asyncHandler(async (req, res) => {
    const identifier = +req.query.userId;
    try {
      const suggestedUsers =
        await prisma.$queryRaw`SELECT id,username,fullname,profilePictureId FROM User where id!=${identifier} and id not in (select followingId from Follow where followerId=${identifier}) ORDER BY id DESC LIMIT 30`;
      res.json(suggestedUsers.sort(() => 0.5 - Math.random()));
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.post(
  "/recover/:email",
  asyncHandler(async (req, res) => {
    const { email } = req.params;
    try {
      const address = ip.address();
      const user = await prisma.user.findUniqueOrThrow({ where: { email } });
      const accountRecovery = await prisma.accountRecovery.create({
        data: { userId: user.id },
      });
      const mailOptions = {
        from: process.env.EMAIL_ADDRESS,
        to: user.email,
        subject: "Account recovery:",
        html: `<h2>Dear ${user.fullname},</h2>
        <p>We received a request to recover your account.<b> If you did not make this request, please ignore this email.</b></p>
        <p>Please note that this link expires after <b>${new Date(
          new Date().getTime() + 5 * 60000
        ).toLocaleString()}</b></p>
        <p>To recover your account, please follow the link below:</p>
        <a href="http://${ip.address()}:5000/user/recover/${
          accountRecovery.id
        }">Recover Account</a>
        <p>Thank you,</p><p>NOT INSTAGRAM Team</p>`,
      };

      transporter.sendMail(mailOptions, function (error, info) {
        if (!error) {
          res.send("Done!");
          return;
        } else {
          res.status(409).send("Email sent: " + info.response);
        }
      });
    } catch (error) {
      res.status(404).send(error.message);
    }
  })
);

router.get(
  "/recover/:id",
  asyncHandler(async (req, res) => {
    const { id } = req.params;
    try {
      const recoveryLink = await prisma.accountRecovery.findFirstOrThrow({
        where: { id: +id },
      });
      if (recoveryLink.expiresAt > new Date() && !recoveryLink.isUsed) {
        const filePath = path.join(__dirname, "../views/recover.html");
        res.sendFile(filePath);
      } else {
        res.status(401).send("Time out");
      }
    } catch (error) {
      res.status(404).json({ message: error.message });
    }
  })
);

router.post(
  "/recovery/:id",
  asyncHandler(async (req, res) => {
    try {
      const id = req.params.id;

      const recoveryLink = await prisma.accountRecovery.update({
        where: { id: +id },
        data: { isUsed: true },
      });
      const userId = recoveryLink.userId;
      const { password } = req.body;
      const user = await prisma.user.update({
        where: { id: +userId },
        data: { password },
      });
      res.send(user);
    } catch (error) {
      res.status(404).send(error.message);
    }
  })
);

router.get(
  "/changeVisibility/:id",
  asyncHandler(async (req, res) => {
    try {
      const id = +req.params.id;
      const visibility = req.query.visibility;
      const user = await prisma.user.update({
        where: { id },
        data: { accountStatus: visibility },
      });
      res.json(user);
    } catch (error) {
      res.status(404).send("No corresponding user");
    }
  })
);

router.put(
  "/updateData/:id",
  asyncHandler(async (req, res) => {
    try {
      const id = +req.params.id;
      const { username, fullname, description, profilePictureId } = req.body;
      if (profilePictureId !== undefined) {
        const user = await prisma.user.update({
          where: { id },
          data: {
            username,
            fullname,
            description,
            profilePictureId:
              profilePictureId === null
                ? null
                : profilePictureId
                ? +profilePictureId
                : undefined,
          },
        });
        res.json(user);
      } else {
        const user = await prisma.user.update({
          where: { id },
          data: {
            username,
            fullname,
            description,
          },
        });
        res.json(user);
      }
    } catch (error) {
      if (error.code === "P2002" && error.meta.target.includes("username")) {
        res.status(400).send("Username");
      } else {
        res.status(404).send(error.message);
      }
    }
  })
);

router.get(
  "/findUsers/:str",
  asyncHandler(async (req, res) => {
    const name = req.params.str;
    try {
      const users = await prisma.$queryRawUnsafe(
        `SELECT * FROM User WHERE LOWER(username) LIKE LOWER('%${name}%') OR LOWER(fullname) LIKE LOWER('%${name}%') LIMIT 5`
      );

      res.json(
        users.map((user) => {
          return {
            id: user.id,
            username: user.username,
            fullname: user.fullname,
            photo: user.profilePictureId,
          };
        })
      );
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

router.get(
  "/findUser/:id",
  asyncHandler(async (req, res) => {
    const userId = req.params.id;
    try {
      const user = await prisma.user.findUniqueOrThrow({
        where: { id: +userId },
      });

      res.json(user);
    } catch (error) {
      res.status(400).send(error.message);
    }
  })
);

module.exports = router;
