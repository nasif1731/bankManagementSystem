const {
  normalizeAmount,
  deposit,
  withdraw,
  transfer,
  calculateInterest
} = require("../../src/utils/banking");

describe("banking utility unit tests", () => {
  test("normalizeAmount returns rounded positive value", () => {
    expect(normalizeAmount(15.678)).toBe(15.68);
  });

  test("deposit adds amount to balance", () => {
    expect(deposit(100, 25.5)).toBe(125.5);
  });

  test("withdraw subtracts amount from balance", () => {
    expect(withdraw(200, 75)).toBe(125);
  });

  test("transfer updates source and destination balances", () => {
    const result = transfer(300, 50, 25);
    expect(result).toEqual({ fromBalance: 275, toBalance: 75 });
  });

  test("calculateInterest computes compound value", () => {
    expect(calculateInterest(1000, 0.1, 2)).toBe(1210);
  });

  test("withdraw throws for insufficient funds", () => {
    expect(() => withdraw(10, 20)).toThrow("Insufficient funds");
  });
});
