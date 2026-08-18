import assert from 'node:assert';
import { test } from 'node:test';
import { evaluateHand, createDeck } from '../hand-ranking';
import { compareHands } from '../card-comparison';
import { Card } from '@teenpatti/shared-types';

test('createDeck creates 52 unique cards', () => {
  const deck = createDeck();
  assert.strictEqual(deck.length, 52);
});

test('evaluateHand identifies Trio/Trail', () => {
  const trailCards: Card[] = [
    { suit: 'SPADES', rank: 'A', value: 14 },
    { suit: 'HEARTS', rank: 'A', value: 14 },
    { suit: 'CLUBS', rank: 'A', value: 14 },
  ];
  const evalResult = evaluateHand(trailCards);
  assert.strictEqual(evalResult.handType, 'TRAIL');
});

test('evaluateHand identifies Pure Sequence', () => {
  const pureSeq: Card[] = [
    { suit: 'HEARTS', rank: 'K', value: 13 },
    { suit: 'HEARTS', rank: 'Q', value: 12 },
    { suit: 'HEARTS', rank: 'J', value: 11 },
  ];
  const evalResult = evaluateHand(pureSeq);
  assert.strictEqual(evalResult.handType, 'PURE_SEQUENCE');
});

test('compareHands ranks Trail higher than Pure Sequence', () => {
  const trail: Card[] = [
    { suit: 'SPADES', rank: '2', value: 2 },
    { suit: 'HEARTS', rank: '2', value: 2 },
    { suit: 'CLUBS', rank: '2', value: 2 },
  ];
  const pureSeq: Card[] = [
    { suit: 'HEARTS', rank: 'A', value: 14 },
    { suit: 'HEARTS', rank: 'K', value: 13 },
    { suit: 'HEARTS', rank: 'Q', value: 12 },
  ];

  const result = compareHands(trail, pureSeq);
  assert.strictEqual(result, 1);
});
