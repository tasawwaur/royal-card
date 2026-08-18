import assert from 'node:assert';
import { test } from 'node:test';
import { validate13CardDeclaration } from '../../packages/game-rules/src/rummy-rules';
import { Card } from '@teenpatti/shared-types';

test('validate13CardDeclaration accepts valid 13-card declare with Pure & Impure Sequences', () => {
  const groups: Card[][] = [
    // Pure Sequence (Hearts 3-4-5)
    [
      { suit: 'HEARTS', rank: '3', value: 3 },
      { suit: 'HEARTS', rank: '4', value: 4 },
      { suit: 'HEARTS', rank: '5', value: 5 },
    ],
    // Impure Sequence (Spades 7-8-Joker)
    [
      { suit: 'SPADES', rank: '7', value: 7 },
      { suit: 'SPADES', rank: '8', value: 8 },
      { suit: 'DIAMONDS', rank: 'K', value: 13 }, // Wild Joker (K)
    ],
    // Set (Kings of 3 suits)
    [
      { suit: 'SPADES', rank: 'Q', value: 12 },
      { suit: 'HEARTS', rank: 'Q', value: 12 },
      { suit: 'CLUBS', rank: 'Q', value: 12 },
    ],
    // 4-card sequence (Clubs 9-10-J-Q)
    [
      { suit: 'CLUBS', rank: '9', value: 9 },
      { suit: 'CLUBS', rank: '10', value: 10 },
      { suit: 'CLUBS', rank: 'J', value: 11 },
      { suit: 'CLUBS', rank: 'Q', value: 12 },
    ],
  ];

  const validation = validate13CardDeclaration(groups, 'K');
  assert.strictEqual(validation.isValid, true);
  assert.strictEqual(validation.totalScore, 0);
});
