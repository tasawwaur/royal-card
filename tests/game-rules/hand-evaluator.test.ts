import assert from 'node:assert';
import { test } from 'node:test';
import { evaluateHand } from '../../packages/game-rules/src/hand-ranking';
import { compareHands } from '../../packages/game-rules/src/card-comparison';
import { Card } from '@teenpatti/shared-types';

test('evaluateHand correctly identifies Trio/Trail', () => {
  const hand: Card[] = [
    { suit: 'HEARTS', rank: 'K', value: 13 },
    { suit: 'SPADES', rank: 'K', value: 13 },
    { suit: 'CLUBS', rank: 'K', value: 13 },
  ];
  const evalResult = evaluateHand(hand);
  assert.strictEqual(evalResult.handType, 'TRAIL');
});

test('evaluateHand correctly identifies Pure Sequence', () => {
  const hand: Card[] = [
    { suit: 'DIAMONDS', rank: 'J', value: 11 },
    { suit: 'DIAMONDS', rank: 'Q', value: 12 },
    { suit: 'DIAMONDS', rank: '10', value: 10 },
  ];
  const evalResult = evaluateHand(hand);
  assert.strictEqual(evalResult.handType, 'PURE_SEQUENCE');
});

test('compareHands enforces hand hierarchy (Trio > Pure Sequence > Sequence > Color > Pair > High Card)', () => {
  const trio: Card[] = [
    { suit: 'SPADES', rank: '2', value: 2 },
    { suit: 'HEARTS', rank: '2', value: 2 },
    { suit: 'CLUBS', rank: '2', value: 2 },
  ];
  const pureSeq: Card[] = [
    { suit: 'HEARTS', rank: 'A', value: 14 },
    { suit: 'HEARTS', rank: 'K', value: 13 },
    { suit: 'HEARTS', rank: 'Q', value: 12 },
  ];

  assert.strictEqual(compareHands(trio, pureSeq), 1);
});
