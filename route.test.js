import { test, expect } from "vitest";
import request from "supertest";
import app from "index.js";

test("GET /QuestBoard redirects to QuestBoard/login", async () => {
    const res = await request(app).get("/QuestBoard");
    expect([301, 302, 303]).toContain(res.status);

    const loc = res.headers.location;
    expect(loc).toBeTruthy();
    expect(loc).toMatch(/^\/?QuestBoard\/login$/); // works with or without the slash
});

test("GET /QuestBoard/login works", async () => {
    const res = await request(app).get("/QuestBoard/login");
    expect(res.status).toBe(200);
    expect(res.headers["content-type"]).toMatch(/html/);
});

test("GET /QuestBoard/signup works", async () => {
    const res = await request(app).get("/QuestBoard/signup");
    expect(res.status).toBe(200);
    expect(res.headers["content-type"]).toMatch(/html/);
});

test("logged-in user can access dashboard", async () => {
    const agent = request.agent(app);

    const email = `test${Date.now()}@ex.com`;
    const password = "Pw123456.";

    await agent
    .post("/QuestBoard/signup")
    .type("form")
    .send({ email, password });

    const login = await agent
    .post("/QuestBoard/login")
    .type("form")
    .send({ email, password });

    expect([200, 301, 302, 303]).toContain(login.status);

    const res = await agent.get("/QuestBoard/dashboard");
    expect(res.status).toBe(200);
    expect(res.text).toMatch(/QuestBoard/i);
});
