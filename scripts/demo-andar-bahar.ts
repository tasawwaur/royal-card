import { playAndarBaharRound, calculate2xAndarBaharPayout } from '../packages/game-rules/src/andar-bahar-rules';

console.log('========================================================================');
console.log('🎰  TEEN PATTI GOLD - EXACT 2X ANDAR BAHAR GAMEPLAY SIMULATION 🎰');
console.log('========================================================================\n');

// STEP 1: Center Joker Card Drop
console.log('📍 PHASE 1: CENTER JOKER CARD DROPPED IN THE MIDDLE');
const round = playAndarBaharRound();
console.log(` 🃏 [ CENTER JOKER CARD ] : ⭐ ${round.jokerCard.rank} of ${round.jokerCard.suit} ⭐\n`);

// STEP 2: User UI Controls & Betting Phase
console.log('------------------------------------------------------------------------');
console.log('📍 PHASE 2: USER BETTING CONTROLS UI ACTIVATED');
console.log(' 🎛️  Bet Adjustment Buttons: [ - ] 🪙 500 [ + ]');
console.log(' 👈 Left Side Button:  [ BAHAR ]  (User 2 Bet: 🪙 500)');
console.log(' 👉 Right Side Button: [ ANDAR ]  (User 1 Bet: 🪙 500)');
console.log('------------------------------------------------------------------------\n');

// STEP 3: Card Dealing Phase
console.log('📍 PHASE 3: ALTERNATING CARD DEALING STARTED');
round.dealSteps.forEach((step, idx) => {
  const spotTag = step.spot === 'ANDAR' ? '👉 [RIGHT: ANDAR]' : '👈 [LEFT: BAHAR]';
  const matchTag = step.isMatch ? '  🎉 MATCH FOUND! GAME OVER!' : '';
  console.log(` Step #${idx + 1} | ${spotTag} : ${step.card.rank} of ${step.card.suit}${matchTag}`);
});

// STEP 4: Winner Announcement & 2X Payouts
console.log('\n========================================================================');
console.log(`🏆 WINNER ANNOUNCEMENT: MATCHING CARD DROPPED ON [ ${round.winningSpot} ]`);
console.log(`📊 Total Cards Dealt: ${round.totalCardsDealt}`);
console.log('========================================================================\n');

const user1Bet = 500;
const user1Spot = 'ANDAR';
const user1Payout = calculate2xAndarBaharPayout(user1Bet, user1Spot, round.winningSpot);

const user2Bet = 500;
const user2Spot = 'BAHAR';
const user2Payout = calculate2xAndarBaharPayout(user2Bet, user2Spot, round.winningSpot);

console.log('💰 PHASE 4: 2X PAYOUT DISTRIBUTION:');
console.log(` 👤 User 1 (Bet 🪙 ${user1Bet} on RIGHT: ANDAR): Payout = 🪙 ${user1Payout} ${user1Payout > 0 ? '🔥 2X WINNER! (🪙 1,000 Returned)' : '❌ Lost'}`);
console.log(` 👤 User 2 (Bet 🪙 ${user2Bet} on LEFT: BAHAR): Payout = 🪙 ${user2Payout} ${user2Payout > 0 ? '🔥 2X WINNER! (🪙 1,000 Returned)' : '❌ Lost'}`);
console.log('========================================================================\n');
