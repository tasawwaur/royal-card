import assert from 'node:assert';
import { test } from 'node:test';
import { evaluatePoker7Cards } from '../../packages/game-rules/src/poker-evaluator';
import { Card } from '@teenpatti/shared-types';

test('evaluatePoker7Cards correctly identifies Royal Flush from 7 cards', () => {
  const cards: Card[] = [
    { suit: 'HEARTS', rank: 'A', value: 14 },
    { suit: 'HEARTS', rank: 'K', value: 13 },
    { suit: 'HEARTS', rank: 'Q', value: 12 },
    { suit: 'HEARTS', rank: 'J', value: 11 },
    { suit: 'HEARTS', rank: '10', value: 10 },
    { suit: 'CLUBS', rank: '2', value: 2 },
    { suit: 'SPADES', rank: '5', value: 5 },
  ];

  const evalResult = evaluatePoker7Cards(cards);
  assert.strictEqual(evalResult.rank, 'ROYAL_FLUSH');
});

test('evaluatePoker7Cards correctly identifies Four of a Kind', () => {
  const cards: Card[] = [
    { suit: 'HEARTS', rank: '9', value: 9 },
    { suit: 'SPADES', rank: '9', value: 9 },
    { suit: 'DIAMONDS', rank: '9', value: 9 },
    { suit: 'CLUBS', rank: '9', value: 9 },
    { suit: 'HEARTS', rank: 'K', value: 13 },
    { suit: 'CLUBS', rank: '3', value: 3 },
    { suit: 'SPADES', rank: '7', value: 7 },
  ];

  const evalResult = evaluatePoker7Cards(cards);
  assert.strictEqual(evalResult.rank, 'FOUR_OF_A_KIND');
});
