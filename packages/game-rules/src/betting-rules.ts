// Calculates required bet amount for a turn based on player status (blind vs seen) & current bet
export function calculateRequiredBet(
  currentBet: number,
  isPlayerBlind: boolean,
  isChaalMultiplier: boolean = false
): number {
  let baseBet = currentBet;

  if (isPlayerBlind) {
    baseBet = currentBet / 2;
  } else {
    baseBet = currentBet;
  }

  if (isChaalMultiplier) {
    baseBet = baseBet * 2;
  }

  return baseBet;
}

// Validates whether a requested bet amount is legal according to Teen Patti rules
export function isValidBetAmount(
  requestedBet: number,
  currentBet: number,
  isPlayerBlind: boolean,
  chaalLimit: number
): boolean {
  if (requestedBet > chaalLimit) return false;

  const minRequired = isPlayerBlind ? Math.ceil(currentBet / 2) : currentBet;
  const maxAllowed = minRequired * 2;

  return requestedBet >= minRequired && requestedBet <= maxAllowed;
}
