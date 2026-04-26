const express = require("express");

const app = express();
app.use(express.json());

const accounts = {
  "1001": 1250.5,
  "1002": 980.0
};

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "UP",
    service: "task2-express-pipeline-app",
    timestamp: new Date().toISOString()
  });
});

app.get("/accounts/:id/balance", (req, res) => {
  const { id } = req.params;
  if (!(id in accounts)) {
    return res.status(404).json({ message: "Account not found" });
  }

  return res.status(200).json({
    accountId: id,
    balance: accounts[id]
  });
});

module.exports = app;
