import assert from 'node:assert';
import { test } from 'node:test';
import { playAndarBaharRound, calculate2xAndarBaharPayout } from '../../packages/game-rules/src/andar-bahar-rules';

test('playAndarBaharRound deals cards until matching Joker rank appears', () => {
  const result = playAndarBaharRound();

  assert.ok(result.jokerCard);
  assert.ok(result.totalCardsDealt > 0);
  assert.ok(result.winningSpot === 'ANDAR' || result.winningSpot === 'BAHAR');

  const lastStep = result.dealSteps[result.dealSteps.length - 1];
  assert.strictEqual(lastStep.card.rank, result.jokerCard.rank);
  assert.strictEqual(lastStep.spot, result.winningSpot);
});

test('calculate2xAndarBaharPayout gives exact 2x multiplier for winning bet', () => {
  const winPayout = calculate2xAndarBaharPayout(500, 'ANDAR', 'ANDAR');
  const losePayout = calculate2xAndarBaharPayout(500, 'BAHAR', 'ANDAR');

  assert.strictEqual(winPayout, 1000); // 500 * 2 = 1000 (2x return)
  assert.strictEqual(losePayout, 0);
});
