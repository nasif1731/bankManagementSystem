function normalizeAmount(value) {
  const amount = Number(value);
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Amount must be a positive number");
  }
  return Number(amount.toFixed(2));
}

function deposit(balance, amount) {
  return Number((balance + normalizeAmount(amount)).toFixed(2));
}

function withdraw(balance, amount) {
  const requested = normalizeAmount(amount);
  if (requested > balance) {
    throw new Error("Insufficient funds");
  }
  return Number((balance - requested).toFixed(2));
}

function transfer(fromBalance, toBalance, amount) {
  const normalized = normalizeAmount(amount);
  return {
    fromBalance: withdraw(fromBalance, normalized),
    toBalance: deposit(toBalance, normalized)
  };
}

function calculateInterest(balance, annualRate, years) {
  const safeBalance = Number(balance);
  const safeRate = Number(annualRate);
  const safeYears = Number(years);

  if (safeBalance < 0 || safeRate < 0 || safeYears < 0) {
    throw new Error("Inputs cannot be negative");
  }

  const amount = safeBalance * Math.pow(1 + safeRate, safeYears);
  return Number(amount.toFixed(2));
}

module.exports = {
  normalizeAmount,
  deposit,
  withdraw,
  transfer,
  calculateInterest
};
