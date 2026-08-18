// ═══════════════════════════════════════════════════════════
// REAL GAME ENGINE — Ported from packages/game-rules/src/
// hand-ranking.ts + andar-bahar-rules.ts + betting-rules.ts
// + poker-evaluator.ts + rummy-rules.ts
// ═══════════════════════════════════════════════════════════

const RANK_VALUES = { '2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9,'10':10,'J':11,'Q':12,'K':13,'A':14 };
const SUITS = ['SPADES','HEARTS','DIAMONDS','CLUBS'];
const SUIT_SYM = { SPADES:'♠', HEARTS:'♥', DIAMONDS:'♦', CLUBS:'♣' };
const RANKS = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];

// Fisher-Yates — ported from hand-ranking.ts shuffleDeck()
function shuffleDeck(deck) {
  const d = [...deck];
  for (let i = d.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [d[i], d[j]] = [d[j], d[i]];
  }
  return d;
}

// createDeck — ported from hand-ranking.ts createDeck()
function createDeck() {
  const deck = [];
  for (const suit of SUITS)
    for (const rank of RANKS)
      deck.push({ rank, suit, value: RANK_VALUES[rank], sym: SUIT_SYM[suit] });
  return deck;
}

// evaluateHand — ported from hand-ranking.ts evaluateHand() (Teen Patti)
function evaluateHand(cards) {
  const sorted = [...cards].sort((a, b) => b.value - a.value);
  const [c1, c2, c3] = sorted;
  const sameSuit = c1.suit === c2.suit && c2.suit === c3.suit;
  const trio = c1.value === c2.value && c2.value === c3.value;
  const normalSeq = c1.value - c2.value === 1 && c2.value - c3.value === 1;
  const a23 = c1.value === 14 && c2.value === 3 && c3.value === 2;
  const seq = normalSeq || a23;
  const pair = c1.value === c2.value || c2.value === c3.value || c1.value === c3.value;

  if (trio) return { type:'TRAIL', label:'Trail (Set) 👑', rank: 6000000 + c1.value, cards: sorted };
  if (sameSuit && seq) return { type:'PURE_SEQ', label:'Pure Sequence 🔥', rank: 5000000 + (a23?3:c1.value), cards: sorted };
  if (seq) return { type:'SEQ', label:'Sequence ✨', rank: 4000000 + (a23?3:c1.value), cards: sorted };
  if (sameSuit) return { type:'COLOR', label:'Color 💜', rank: 3000000 + c1.value*100 + c2.value*10 + c3.value, cards: sorted };
  if (pair) {
    let pv, kv;
    if (c1.value===c2.value) { pv=c1.value; kv=c3.value; }
    else if (c2.value===c3.value) { pv=c2.value; kv=c1.value; }
    else { pv=c1.value; kv=c2.value; }
    return { type:'PAIR', label:'Pair 🃏', rank: 2000000 + pv*100 + kv, cards: sorted };
  }
  return { type:'HIGH', label:'High Card', rank: 1000000 + c1.value*100 + c2.value*10 + c3.value, cards: sorted };
}

// compareHands — ported from card-comparison.ts
function compareHands(a, b) {
  const ea = evaluateHand(a), eb = evaluateHand(b);
  return ea.rank > eb.rank ? 1 : ea.rank < eb.rank ? -1 : 0;
}

// dealHands — deal n hands of 3 cards
function dealHands(n) {
  const deck = shuffleDeck(createDeck());
  return Array.from({length:n}, (_,i) => [deck[i*3], deck[i*3+1], deck[i*3+2]]);
}

// playAndarBaharRound — ported from andar-bahar-rules.ts
function playAndarBaharRound() {
  const deck = shuffleDeck(createDeck());
  const joker = deck.pop();
  const steps = [];
  let spot = 'ANDAR', winner = null;
  while (deck.length > 0) {
    const card = deck.pop();
    const match = card.rank === joker.rank;
    steps.push({ spot, card, match });
    if (match) { winner = spot; break; }
    spot = spot === 'ANDAR' ? 'BAHAR' : 'ANDAR';
  }
  return { joker, steps, winner: winner||'ANDAR', total: steps.length };
}

// calculate2xPayout — ported from andar-bahar-rules.ts
function calculate2xPayout(bet, betSpot, winner) {
  return betSpot === winner ? bet * 2 : 0;
}

// calculateRequiredBet — ported from betting-rules.ts
function calcRequiredBet(current, isBlind) {
  return isBlind ? Math.floor(current/2) : current;
}

// isValidBet — ported from betting-rules.ts
function isValidBet(requested, current, isBlind, limit=100000) {
  if (requested > limit) return false;
  const min = isBlind ? Math.ceil(current/2) : current;
  const max = min * 2;
  return requested >= min && requested <= max;
}

// Chip formatter
function fmtChips(v) {
  if (v >= 1000000000000) return parseFloat((v/1000000000000).toFixed(2)) + 'T';
  if (v >= 1000000000) return parseFloat((v/1000000000).toFixed(2)) + 'B';
  if (v >= 1000000) return parseFloat((v/1000000).toFixed(2)) + 'M';
  if (v >= 1000) return parseFloat((v/1000).toFixed(2)) + 'K';
  return String(v);
}


// ═══════════════════════════════════════════════════════════
// POKER GAME LOGIC — Ported from packages/game-rules/src/poker-evaluator.ts
// ═══════════════════════════════════════════════════════════

function getCombinations(array, size) {
  const result = [];
  function p(t, i) {
    if (t.length === size) { result.push(t); return; }
    if (i + (size - t.length) > array.length) return;
    p([...t, array[i]], i + 1);
    p(t, i + 1);
  }
  p([], 0);
  return result;
}

function evaluatePoker5Cards(cards) {
  const sorted = [...cards].sort((a, b) => b.value - a.value);
  const [c1, c2, c3, c4, c5] = sorted;

  const isFlush = cards.every(c => c.suit === cards[0].suit);
  const values = sorted.map(c => c.value);

  const isNormalSeq =
    values[0] - values[1] === 1 &&
    values[1] - values[2] === 1 &&
    values[2] - values[3] === 1 &&
    values[3] - values[4] === 1;

  const isAceLowSeq = values[0] === 14 && values[1] === 5 && values[2] === 4 && values[3] === 3 && values[4] === 2;
  const isStraight = isNormalSeq || isAceLowSeq;

  // Value frequency counts
  const counts = {};
  values.forEach(v => counts[v] = (counts[v] || 0) + 1);
  const freqValues = Object.entries(counts).map(([v, count]) => ({ val: Number(v), count }));
  freqValues.sort((a, b) => b.count - a.count || b.val - a.val);

  let rank, label;
  let score = 0;

  if (isFlush && isStraight) {
    if (values[0] === 14 && values[1] === 13) {
      rank = 'ROYAL_FLUSH'; label = 'Royal Flush 👑';
      score = 9000000;
    } else {
      rank = 'STRAIGHT_FLUSH'; label = 'Straight Flush 🏆';
      score = 8000000 + (isAceLowSeq ? 5 : values[0]);
    }
  } else if (freqValues[0].count === 4) {
    rank = 'FOUR_OF_A_KIND'; label = 'Four of a Kind 🃏';
    score = 7000000 + freqValues[0].val * 10 + freqValues[1].val;
  } else if (freqValues[0].count === 3 && freqValues[1].count === 2) {
    rank = 'FULL_HOUSE'; label = 'Full House 🎪';
    score = 6000000 + freqValues[0].val * 10 + freqValues[1].val;
  } else if (isFlush) {
    rank = 'FLUSH'; label = 'Flush ♠️';
    score = 5000000 + values[0] * 1000 + values[1] * 100 + values[2] * 10 + values[3];
  } else if (isStraight) {
    rank = 'STRAIGHT'; label = 'Straight 🛣️';
    score = 4000000 + (isAceLowSeq ? 5 : values[0]);
  } else if (freqValues[0].count === 3) {
    rank = 'THREE_OF_A_KIND'; label = 'Three of a Kind 🎰';
    score = 3000000 + freqValues[0].val * 100 + freqValues[1].val * 10 + freqValues[2].val;
  } else if (freqValues[0].count === 2 && freqValues[1].count === 2) {
    rank = 'TWO_PAIR'; label = 'Two Pair 👫';
    score = 2000000 + freqValues[0].val * 100 + freqValues[1].val * 10 + freqValues[2].val;
  } else if (freqValues[0].count === 2) {
    rank = 'ONE_PAIR'; label = 'One Pair 👥';
    score = 1000000 + freqValues[0].val * 100 + freqValues[1].val * 10 + freqValues[2].val;
  } else {
    rank = 'HIGH_CARD'; label = 'High Card 🎫';
    score = values[0] * 1000 + values[1] * 100 + values[2] * 10 + values[3];
  }

  return { rank, label, score, bestFiveCards: sorted };
}

function evaluatePoker7Cards(cards) {
  if (cards.length < 5 || cards.length > 7) {
    throw new Error('Poker evaluation requires 5 to 7 cards.');
  }
  const combinations = getCombinations(cards, 5);
  let bestEval = null;
  for (const combo of combinations) {
    const evalResult = evaluatePoker5Cards(combo);
    if (!bestEval || evalResult.score > bestEval.score) {
      bestEval = evalResult;
    }
  }
  return bestEval;
}


// ═══════════════════════════════════════════════════════════
// RUMMY GAME LOGIC — Ported from packages/game-rules/src/rummy-rules.ts
// ═══════════════════════════════════════════════════════════

function validateRummyGroup(cards, wildJokerRank) {
  if (cards.length < 3) return 'INVALID';

  const isPureSeq = checkPureSequence(cards);
  if (isPureSeq) return 'PURE_SEQUENCE';

  const isImpureSeq = checkImpureSequence(cards, wildJokerRank);
  if (isImpureSeq) return 'IMPURE_SEQUENCE';

  const isSet = checkSet(cards, wildJokerRank);
  if (isSet) return 'SET';

  return 'INVALID';
}

function checkPureSequence(cards) {
  if (cards.length < 3) return false;
  const sameSuit = cards.every(c => c.suit === cards[0].suit);
  if (!sameSuit) return false;

  const sorted = [...cards].sort((a, b) => a.value - b.value);
  for (let i = 0; i < sorted.length - 1; i++) {
    if (sorted[i + 1].value - sorted[i].value !== 1) return false;
  }
  return true;
}

function checkImpureSequence(cards, wildJokerRank) {
  if (cards.length < 3) return false;
  const nonJokers = cards.filter(c => c.rank !== wildJokerRank && c.rank !== 'JOKER');
  if (nonJokers.length === 0) return true;

  const targetSuit = nonJokers[0].suit;
  if (!nonJokers.every(c => c.suit === targetSuit)) return false;
  return true;
}

function checkSet(cards, wildJokerRank) {
  if (cards.length < 3 || cards.length > 4) return false;
  const nonJokers = cards.filter(c => c.rank !== wildJokerRank && c.rank !== 'JOKER');
  if (nonJokers.length === 0) return true;

  const targetRank = nonJokers[0].rank;
  const sameRank = nonJokers.every(c => c.rank === targetRank);
  if (!sameRank) return false;

  const suits = new Set(nonJokers.map(c => c.suit));
  return suits.size === nonJokers.length;
}

function validate13CardDeclaration(groups, wildJokerRank) {
  const evaluatedGroups = [];
  let pureSequenceCount = 0;
  let sequenceCount = 0;
  let totalScore = 0;

  for (const groupCards of groups) {
    const type = validateRummyGroup(groupCards, wildJokerRank);
    const points = type === 'INVALID' ? groupCards.reduce((acc, c) => acc + c.value, 0) : 0;

    if (type === 'PURE_SEQUENCE') {
      pureSequenceCount++;
      sequenceCount++;
    } else if (type === 'IMPURE_SEQUENCE') {
      sequenceCount++;
    }

    evaluatedGroups.push({
      cards: groupCards,
      type,
      points
    });
    totalScore += points;
  }

  const isValid = pureSequenceCount >= 1 && sequenceCount >= 2 && evaluatedGroups.every(g => g.type !== 'INVALID');

  return {
    isValid,
    totalScore: isValid ? 0 : Math.min(totalScore, 80),
    groups: evaluatedGroups
  };
}
