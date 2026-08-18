import assert from 'node:assert';
import { test } from 'node:test';
import { createDeck, shuffleDeck } from '../../packages/game-rules/src/hand-ranking';

test('createDeck generates 52 distinct standard cards', () => {
  const deck = createDeck();
  assert.strictEqual(deck.length, 52);

  const cardKeys = new Set(deck.map((c) => `${c.rank}_${c.suit}`));
  assert.strictEqual(cardKeys.size, 52);
});

test('shuffleDeck preserves all cards while altering order', () => {
  const deck = createDeck();
  const shuffled = shuffleDeck(deck);

  assert.strictEqual(shuffled.length, 52);
  const originalKeys = new Set(deck.map((c) => `${c.rank}_${c.suit}`));
  const shuffledKeys = new Set(shuffled.map((c) => `${c.rank}_${c.suit}`));

  assert.deepStrictEqual(originalKeys, shuffledKeys);
});
