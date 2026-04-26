const request = require("supertest");
const app = require("../../src/app");

describe("integration tests", () => {
  test("GET /health returns 200 and status UP", async () => {
    const response = await request(app).get("/health");

    expect(response.status).toBe(200);
    expect(response.body.status).toBe("UP");
    expect(response.body.service).toBe("task2-express-pipeline-app");
  });

  test("GET /accounts/:id/balance returns account balance", async () => {
    const response = await request(app).get("/accounts/1001/balance");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      accountId: "1001",
      balance: 1250.5
    });
  });

  test("GET /accounts/:id/balance returns 404 for unknown account", async () => {
    const response = await request(app).get("/accounts/9999/balance");

    expect(response.status).toBe(404);
    expect(response.body.message).toBe("Account not found");
  });
});
