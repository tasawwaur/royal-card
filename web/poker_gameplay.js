// Texas Hold'em Poker Simulation Engine for web client
const suitSymbols = { 'HEARTS': '♥', 'DIAMONDS': '♦', 'CLUBS': '♣', 'SPADES': '♠' };
const suitColors = { 'HEARTS': '#ff4444', 'DIAMONDS': '#ff4444', 'CLUBS': '#ffffff', 'SPADES': '#ffffff' };

let pokerSimState = {
  activeSeats: { 1: true, 2: false, 3: false, 4: false, 5: false },
  playerProfiles: {},
  playerCards: {}, // seatId -> [{rank, suit, val, sym}]
  communityCards: [], // [{rank, suit, val, sym}]
  pot: 0,
  currentTurn: null,
  dealerSeat: 1,
  currentBet: 0,
  playerBets: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
  playerChips: { 1: 135000, 2: 125000, 3: 110000, 4: 140000, 5: 120000 },
  gamePhase: 'idle', // idle, deal, flop, turn, river, showdown
  deck: [],
  smallBlind: 1000,
  bigBlind: 2000,
  raiseAmount: 10000,
  playerFolded: { 1: false, 2: false, 3: false, 4: false, 5: false },
  mute: false
};

// Start simulation once DOM loaded
function initPokerSimulation() {
  // Set Seat 1 (you)
  pokerSimState.playerProfiles[1] = {
    name: state.name || "Tasavvur",
    avatar: state.avatar || "assets/custom_icons/avatar_tasavvur_face.jpg",
    frame: state.frame || "frame-emperor",
    level: state.level || 108
  };
  pokerSimState.playerChips[1] = 135000;

  // Auto join bots to fill the table
  setTimeout(() => {
    pokerAutoFillBots();
  }, 1000);
}

function pokerAutoFillBots() {
  const seats = [2, 3, 4, 5];
  seats.forEach((s, idx) => {
    setTimeout(() => {
      pokerSimulateBotJoin(s);
    }, idx * 400);
  });
}

function pokerSimulateBotJoin(seatNum) {
  if (pokerSimState.activeSeats[seatNum]) return;

  // Find unique bot from database
  let sittingNames = [];
  for (let s = 1; s <= 5; s++) {
    if (pokerSimState.activeSeats[s] && pokerSimState.playerProfiles[s]) {
      sittingNames.push(pokerSimState.playerProfiles[s].name);
    }
  }

  let availableBots = GLOBAL_PLAYER_DATABASE.filter(b => !sittingNames.includes(b.name));
  if (availableBots.length === 0) availableBots = GLOBAL_PLAYER_DATABASE;
  let botProfile = availableBots[Math.floor(Math.random() * availableBots.length)];

  pokerSimState.activeSeats[seatNum] = true;
  pokerSimState.playerProfiles[seatNum] = {
    name: botProfile.name,
    avatar: botProfile.avatar,
    frame: botProfile.frame,
    level: botProfile.level
  };

  // Render seated bot
  const seatEl = document.getElementById('poker-seat-' + seatNum);
  if (seatEl) {
    seatEl.classList.remove('empty');
    seatEl.innerHTML = `
      <div class="poker-seat-avatar-wrapper" style="width: 52px; height: 52px; position: relative;">
        <div class="avatar-frame ${botProfile.frame}" style="width: 100%; height: 100%;">
          <div class="avatar-frame-border"></div>
          <div class="avatar-frame-image">
            <img src="${botProfile.avatar}" style="width:100%; height:100%; object-fit:cover;">
          </div>
        </div>
        <span style="position: absolute; left: 50%; bottom: -3px; transform: translateX(-50%); font-size: 7px; font-weight: 900; color: #fff; text-shadow: 0 1px 2px #000; font-family: 'Outfit', sans-serif; pointer-events: none; z-index: 10;">${botProfile.level}</span>
      </div>
      <div style="background: rgba(0, 0, 0, 0.7); border: 1px solid rgba(255, 255, 255, 0.15); padding: 1px 6px; border-radius: 4px; font-size: 8px; color: #fff; margin-top: 3px; font-weight: bold; max-width: 70px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
        <span>${botProfile.name}</span>
      </div>
    `;
  }

  // Check if table full to start game
  let activeCount = 0;
  for (let s = 1; s <= 5; s++) {
    if (pokerSimState.activeSeats[s]) activeCount++;
  }
  if (activeCount === 5 && pokerSimState.gamePhase === 'idle') {
    setTimeout(pokerStartRound, 1200);
  }
}

// Exit back to lobby
function pokerExitToLobby() {
  pokerResetTableUI();
  pokerSimState.gamePhase = 'idle';
  document.getElementById('screen-poker').classList.remove('active');
  document.getElementById('screen-home').classList.add('active');
}

// Toggle sound
function pokerToggleMute() {
  pokerSimState.mute = !pokerSimState.mute;
  document.getElementById('poker-mute-icon').innerText = pokerSimState.mute ? '🔇' : '🔊';
}

// Adjust raise slider
function pokerAdjustRaise(amt) {
  pokerSimState.raiseAmount = Math.max(2000, pokerSimState.raiseAmount + amt);
  document.getElementById('poker-raise-amount-text').innerText = pokerSimState.raiseAmount.toLocaleString();
}

// Shuffles and starts poker hand round
function pokerStartRound() {
  pokerSimState.gamePhase = 'deal';
  pokerSimState.pot = 0;
  pokerSimState.currentBet = pokerSimState.bigBlind;
  pokerSimState.playerCards = {};
  pokerSimState.communityCards = [];
  
  // Reset players states
  for (let s = 1; s <= 5; s++) {
    pokerSimState.playerFolded[s] = false;
    pokerSimState.playerBets[s] = 0;
    pokerHideActionBubble(s);
    pokerClearSeatCards(s);
  }

  pokerClearCommunityCards();
  pokerUpdatePotDisplay();

  // Create a 52 card deck
  const ranks = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];
  const suits = ['HEARTS','DIAMONDS','CLUBS','SPADES'];
  const vals = { '2':2,'3':3,'4':4,'5':5,'6':6,'7':7,'8':8,'9':9,'10':10,'J':11,'Q':12,'K':13,'A':14 };
  
  pokerSimState.deck = [];
  for (let r of ranks) {
    for (let s of suits) {
      pokerSimState.deck.push({ rank: r, suit: s, val: vals[r], sym: suitSymbols[s] });
    }
  }

  // Shuffle deck
  for (let i = pokerSimState.deck.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [pokerSimState.deck[i], pokerSimState.deck[j]] = [pokerSimState.deck[j], pokerSimState.deck[i]];
  }

  // Deal 2 cards to each player
  for (let s = 1; s <= 5; s++) {
    pokerSimState.playerCards[s] = [pokerSimState.deck.pop(), pokerSimState.deck.pop()];
  }

  // Rotate Dealer Button
  pokerSimState.dealerSeat = (pokerSimState.dealerSeat % 5) + 1;
  pokerPositionDealerBadge();

  // Small blind and Big Blind deduction
  let sbSeat = (pokerSimState.dealerSeat % 5) + 1;
  let bbSeat = ((pokerSimState.dealerSeat + 1) % 5) + 1;

  pokerDeductChips(sbSeat, pokerSimState.smallBlind);
  pokerSimState.playerBets[sbSeat] = pokerSimState.smallBlind;
  pokerShowActionBubble(sbSeat, `Small Blind ${pokerSimState.smallBlind.toLocaleString()}`);

  pokerDeductChips(bbSeat, pokerSimState.bigBlind);
  pokerSimState.playerBets[bbSeat] = pokerSimState.bigBlind;
  pokerShowActionBubble(bbSeat, `Big Blind ${pokerSimState.bigBlind.toLocaleString()}`);

  pokerSimState.pot = pokerSimState.smallBlind + pokerSimState.bigBlind;
  pokerUpdatePotDisplay();

  // Render cards
  pokerRenderPlayerCards();

  // First turn is after big blind
  pokerSimState.currentTurn = ((bbSeat) % 5) + 1;
  setTimeout(pokerNextTurn, 1000);
}

function pokerPositionDealerBadge() {
  const badge = document.getElementById('poker-dealer-button-badge');
  if (!badge) return;
  
  // Position offsets relative to seat positions
  const offsets = {
    1: { left: '55%', bottom: '15%' },
    2: { left: '17%', bottom: '33%' },
    3: { left: '20%', top: '33%' },
    4: { right: '20%', top: '33%' },
    5: { right: '17%', bottom: '33%' }
  };
  
  const off = offsets[pokerSimState.dealerSeat];
  badge.style.display = 'flex';
  badge.style.left = off.left || '';
  badge.style.right = off.right || '';
  badge.style.top = off.top || '';
  badge.style.bottom = off.bottom || '';
}

function pokerDeductChips(seatNum, amt) {
  pokerSimState.playerChips[seatNum] = Math.max(0, pokerSimState.playerChips[seatNum] - amt);
  pokerUpdateSeatChips(seatNum);
}

function pokerUpdateSeatChips(seatNum) {
  // Find chips text field inside the label block
  const seatEl = document.getElementById('poker-seat-' + seatNum);
  if (seatEl) {
    if (seatNum === 1) {
      // Seat 1 custom player banner chips
      const chipsValueEl = document.getElementById('poker-chips-stack-1-val');
      if (chipsValueEl) {
        chipsValueEl.innerText = pokerSimState.playerChips[1].toLocaleString();
      }
    } else {
      // Bots name and chips labels
      const labelSpan = seatEl.querySelector('div:last-child span');
      if (labelSpan) {
        labelSpan.innerHTML = `${pokerSimState.playerProfiles[seatNum].name}<br><span style="color:#FFD700; display:inline-flex; align-items:center; justify-content:center; gap:2.5px; margin-top:1px;"><img src="assets/images/icons/luxury_token_red.png" style="width:10px; height:10px; object-fit:contain;">${pokerSimState.playerChips[seatNum].toLocaleString()}</span>`;
      }
    }
  }
}

function pokerRenderPlayerCards() {
  // Render Seat 1 (Tasavvur) cards face up
  const p1Cards = pokerSimState.playerCards[1];
  const p1Container = document.getElementById('poker-player-cards');
  if (p1Container) {
    p1Container.innerHTML = p1Cards.map(c => `
      <div style="background:#fff; color:${suitColors[c.suit]}; width:32px; height:46px; border-radius:4px; display:flex; flex-direction:column; justify-content:center; align-items:center; font-size:12px; font-weight:bold; box-shadow:0 3px 6px rgba(0,0,0,0.5); border:1px solid rgba(0,0,0,0.15); transition: transform 0.2s;">
        <span>${c.rank}</span>
        <span style="font-size: 15px; margin-top: -3px;">${c.sym}</span>
      </div>
    `).join('');
  }

  // Render Bot Card Backs next to bot seats
  for (let s = 2; s <= 5; s++) {
    const botContainer = document.getElementById('poker-cards-' + s);
    if (botContainer) {
      botContainer.innerHTML = `
        <div class="poker-card-back" style="width: 20px; height: 28px; background: linear-gradient(135deg, #150d2e, #090518); border: 1px solid #d4af37; border-radius: 3px; box-shadow: 0 2px 4px rgba(0,0,0,0.4); display: flex; justify-content: center; align-items: center; transform: rotate(-8deg); z-index: 5;">
          <div style="width: calc(100% - 2px); height: calc(100% - 2px); border: 0.5px solid rgba(212, 175, 55, 0.4); border-radius: 2px; display: flex; justify-content: center; align-items: center; color: #d4af37; font-family: sans-serif; font-size: 8px; font-weight: bold;">R</div>
        </div>
        <div class="poker-card-back" style="width: 20px; height: 28px; background: linear-gradient(135deg, #150d2e, #090518); border: 1px solid #d4af37; border-radius: 3px; box-shadow: 0 2px 4px rgba(0,0,0,0.4); display: flex; justify-content: center; align-items: center; transform: rotate(8deg); margin-left: -8px; z-index: 10;">
          <div style="width: calc(100% - 2px); height: calc(100% - 2px); border: 0.5px solid rgba(212, 175, 55, 0.4); border-radius: 2px; display: flex; justify-content: center; align-items: center; color: #d4af37; font-family: sans-serif; font-size: 8px; font-weight: bold;">R</div>
        </div>
      `;
    }
  }
}

function pokerClearSeatCards(seatNum) {
  if (seatNum === 1) {
    const container = document.getElementById('poker-player-cards');
    if (container) container.innerHTML = '';
  } else {
    const container = document.getElementById('poker-cards-' + seatNum);
    if (container) container.innerHTML = '';
  }
}

function pokerClearCommunityCards() {
  const container = document.getElementById('poker-community-cards');
  if (container) {
    container.innerHTML = `
      <div class="poker-community-card-slot" style="width: 32px; height: 46px; border: 1px dashed rgba(255,255,255,0.15); border-radius: 4px; background: rgba(0,0,0,0.25);"></div>
      <div class="poker-community-card-slot" style="width: 32px; height: 46px; border: 1px dashed rgba(255,255,255,0.15); border-radius: 4px; background: rgba(0,0,0,0.25);"></div>
      <div class="poker-community-card-slot" style="width: 32px; height: 46px; border: 1px dashed rgba(255,255,255,0.15); border-radius: 4px; background: rgba(0,0,0,0.25);"></div>
      <div class="poker-community-card-slot" style="width: 32px; height: 46px; border: 1px dashed rgba(255,255,255,0.15); border-radius: 4px; background: rgba(0,0,0,0.25);"></div>
      <div class="poker-community-card-slot" style="width: 32px; height: 46px; border: 1px dashed rgba(255,255,255,0.15); border-radius: 4px; background: rgba(0,0,0,0.25);"></div>
    `;
  }
}

function pokerUpdatePotDisplay() {
  const potVal = document.getElementById('poker-pot-value');
  if (potVal) potVal.innerText = pokerSimState.pot.toLocaleString();
}

function pokerShowActionBubble(seatNum, txt) {
  const bubble = document.getElementById('poker-action-' + seatNum);
  if (bubble) {
    bubble.innerText = txt;
    bubble.style.display = 'block';
  }
}

function pokerHideActionBubble(seatNum) {
  const bubble = document.getElementById('poker-action-' + seatNum);
  if (bubble) bubble.style.display = 'none';
}

function pokerNextTurn() {
  // Check if only one player remaining (everyone folded)
  let activePlayers = [];
  for (let s = 1; s <= 5; s++) {
    if (pokerSimState.activeSeats[s] && !pokerSimState.playerFolded[s]) {
      activePlayers.push(s);
    }
  }

  if (activePlayers.length === 1) {
    pokerTriggerSingleWinner(activePlayers[0]);
    return;
  }

  // Clear turn rings
  for (let s = 1; s <= 5; s++) {
    const seatEl = document.getElementById('poker-seat-' + s);
    if (seatEl) seatEl.classList.remove('active-turn');
  }

  // Move turn to next active, non-folded seat
  let turnsChecked = 0;
  while (turnsChecked < 5) {
    if (pokerSimState.playerFolded[pokerSimState.currentTurn] || !pokerSimState.activeSeats[pokerSimState.currentTurn]) {
      pokerSimState.currentTurn = (pokerSimState.currentTurn % 5) + 1;
      turnsChecked++;
    } else {
      break;
    }
  }

  // Active seat highlights
  const activeSeatEl = document.getElementById('poker-seat-' + pokerSimState.currentTurn);
  if (activeSeatEl) activeSeatEl.classList.add('active-turn');

  // If Seat 1 (you) - Enable Buttons
  if (pokerSimState.currentTurn === 1) {
    pokerEnableControlButtons(true);
  } else {
    pokerEnableControlButtons(false);
    // Simulate bot play delay
    setTimeout(pokerSimulateBotAction, 1500);
  }
}

function pokerEnableControlButtons(enable) {
  const buttons = ['poker-btn-fold', 'poker-btn-check', 'poker-btn-call', 'poker-btn-raise'];
  buttons.forEach(id => {
    const btn = document.getElementById(id);
    if (btn) {
      if (enable) {
        btn.disabled = false;
        btn.style.opacity = '1';
        btn.style.pointerEvents = 'auto';
      } else {
        btn.disabled = true;
        btn.style.opacity = '0.5';
        btn.style.pointerEvents = 'none';
      }
    }
  });

  // Call Amount Label Update
  const callAmt = document.getElementById('poker-call-amount');
  if (callAmt) {
    let diff = pokerSimState.currentBet - pokerSimState.playerBets[1];
    callAmt.innerText = diff > 0 ? diff.toLocaleString() : 'CHECK';
  }
}

function pokerPlayerAction(type) {
  if (pokerSimState.currentTurn !== 1) return;

  if (type === 'FOLD') {
    pokerSimState.playerFolded[1] = true;
    pokerShowActionBubble(1, "FOLD");
    const p1Container = document.getElementById('poker-player-cards');
    if (p1Container) p1Container.style.opacity = '0.4';
  } else if (type === 'CHECK') {
    pokerShowActionBubble(1, "CHECK");
  } else if (type === 'CALL') {
    let diff = pokerSimState.currentBet - pokerSimState.playerBets[1];
    if (diff > 0) {
      pokerDeductChips(1, diff);
      pokerSimState.playerBets[1] = pokerSimState.currentBet;
      pokerSimState.pot += diff;
      pokerUpdatePotDisplay();
      pokerShowActionBubble(1, `CALL ${diff.toLocaleString()}`);
    } else {
      pokerShowActionBubble(1, "CHECK");
    }
  } else if (type === 'RAISE') {
    let raiseAmt = pokerSimState.raiseAmount;
    pokerDeductChips(1, raiseAmt);
    pokerSimState.currentBet += raiseAmt;
    pokerSimState.playerBets[1] = pokerSimState.currentBet;
    pokerSimState.pot += raiseAmt;
    pokerUpdatePotDisplay();
    pokerShowActionBubble(1, `RAISE ${raiseAmt.toLocaleString()}`);
  }

  // Proceed turn
  pokerSimState.currentTurn = (pokerSimState.currentTurn % 5) + 1;
  pokerCheckPhaseTransition();
}

function pokerSimulateBotAction() {
  const seatNum = pokerSimState.currentTurn;
  let diff = pokerSimState.currentBet - pokerSimState.playerBets[seatNum];
  
  // Decisions based on level/luck
  let roll = Math.random();
  let actionText = "";

  if (diff > 0) {
    // There is a bet to call
    if (roll < 0.15) {
      // Fold
      pokerSimState.playerFolded[seatNum] = true;
      actionText = "FOLD";
      const cardsEl = document.getElementById('poker-cards-' + seatNum);
      if (cardsEl) cardsEl.style.opacity = '0.3';
    } else if (roll < 0.8) {
      // Call
      pokerDeductChips(seatNum, diff);
      pokerSimState.playerBets[seatNum] = pokerSimState.currentBet;
      pokerSimState.pot += diff;
      pokerUpdatePotDisplay();
      actionText = `CALL ${diff.toLocaleString()}`;
    } else {
      // Raise
      let raiseAmt = 5000 + (Math.floor(Math.random() * 3) * 5000);
      pokerDeductChips(seatNum, diff + raiseAmt);
      pokerSimState.currentBet += raiseAmt;
      pokerSimState.playerBets[seatNum] = pokerSimState.currentBet;
      pokerSimState.pot += (diff + raiseAmt);
      pokerUpdatePotDisplay();
      actionText = `RAISE ${raiseAmt.toLocaleString()}`;
    }
  } else {
    // Cheap/no bet
    if (roll < 0.85) {
      // Check
      actionText = "CHECK";
    } else {
      // Bet/Raise
      let raiseAmt = 4000;
      pokerDeductChips(seatNum, raiseAmt);
      pokerSimState.currentBet += raiseAmt;
      pokerSimState.playerBets[seatNum] = pokerSimState.currentBet;
      pokerSimState.pot += raiseAmt;
      pokerUpdatePotDisplay();
      actionText = `BET ${raiseAmt.toLocaleString()}`;
    }
  }

  pokerShowActionBubble(seatNum, actionText);
  
  // Proceed turn
  pokerSimState.currentTurn = (pokerSimState.currentTurn % 5) + 1;
  pokerCheckPhaseTransition();
}

function pokerCheckPhaseTransition() {
  // Check if all active non-folded players have matching bets
  let activeNonFolded = [];
  for (let s = 1; s <= 5; s++) {
    if (pokerSimState.activeSeats[s] && !pokerSimState.playerFolded[s]) {
      activeNonFolded.push(s);
    }
  }

  let allMatched = activeNonFolded.every(s => pokerSimState.playerBets[s] === pokerSimState.currentBet);

  if (allMatched) {
    // Clear action bubbles
    for (let s = 1; s <= 5; s++) {
      pokerHideActionBubble(s);
    }
    
    // Move to next phase
    if (pokerSimState.gamePhase === 'deal') {
      pokerTriggerFlop();
    } else if (pokerSimState.gamePhase === 'flop') {
      pokerTriggerTurn();
    } else if (pokerSimState.gamePhase === 'turn') {
      pokerTriggerRiver();
    } else if (pokerSimState.gamePhase === 'river') {
      pokerTriggerShowdown();
    }
  } else {
    pokerNextTurn();
  }
}

function pokerTriggerFlop() {
  pokerSimState.gamePhase = 'flop';
  // Deal 3 community cards
  pokerSimState.communityCards.push(pokerSimState.deck.pop(), pokerSimState.deck.pop(), pokerSimState.deck.pop());
  pokerRenderCommunityCards();
  
  // First turn is after dealer
  pokerSimState.currentTurn = (pokerSimState.dealerSeat % 5) + 1;
  pokerNextTurn();
}

function pokerTriggerTurn() {
  pokerSimState.gamePhase = 'turn';
  // Deal 4th card
  pokerSimState.communityCards.push(pokerSimState.deck.pop());
  pokerRenderCommunityCards();
  
  pokerSimState.currentTurn = (pokerSimState.dealerSeat % 5) + 1;
  pokerNextTurn();
}

function pokerTriggerRiver() {
  pokerSimState.gamePhase = 'river';
  // Deal 5th card
  pokerSimState.communityCards.push(pokerSimState.deck.pop());
  pokerRenderCommunityCards();
  
  pokerSimState.currentTurn = (pokerSimState.dealerSeat % 5) + 1;
  pokerNextTurn();
}

function pokerRenderCommunityCards() {
  const container = document.getElementById('poker-community-cards');
  if (!container) return;

  let slotsHtml = '';
  for (let i = 0; i < 5; i++) {
    const c = pokerSimState.communityCards[i];
    if (c) {
      slotsHtml += `
        <div style="background:#fff; color:${suitColors[c.suit]}; width:32px; height:46px; border-radius:4px; display:flex; flex-direction:column; justify-content:center; align-items:center; font-size:12px; font-weight:bold; box-shadow:0 2px 4px rgba(0,0,0,0.5); border:1px solid rgba(0,0,0,0.15);">
          <span>${c.rank}</span>
          <span style="font-size: 15px; margin-top: -3px;">${c.sym}</span>
        </div>
      `;
    } else {
      slotsHtml += `<div class="poker-community-card-slot" style="width: 32px; height: 46px; border: 1px dashed rgba(255,255,255,0.15); border-radius: 4px; background: rgba(0,0,0,0.25);"></div>`;
    }
  }
  container.innerHTML = slotsHtml;
}

function pokerTriggerShowdown() {
  pokerSimState.gamePhase = 'showdown';
  
  // Reveal bot cards
  for (let s = 2; s <= 5; s++) {
    if (pokerSimState.activeSeats[s] && !pokerSimState.playerFolded[s]) {
      const botContainer = document.getElementById('poker-cards-' + s);
      const bCards = pokerSimState.playerCards[s];
      if (botContainer && bCards) {
        botContainer.innerHTML = bCards.map(c => `
          <div style="background:#fff; color:${suitColors[c.suit]}; width:20px; height:28px; border-radius:3px; display:flex; flex-direction:column; justify-content:center; align-items:center; font-size:7px; font-weight:bold; box-shadow:0 1px 3px rgba(0,0,0,0.5); border:1px solid rgba(0,0,0,0.15);">
            <span>${c.rank}</span>
            <span style="font-size: 10px; margin-top: -3px;">${c.sym}</span>
          </div>
        `).join('');
      }
    }
  }

  // Find winner
  let activeSeatsList = [];
  for (let s = 1; s <= 5; s++) {
    if (pokerSimState.activeSeats[s] && !pokerSimState.playerFolded[s]) {
      activeSeatsList.push(s);
    }
  }

  let winnerSeat = 1;
  let bestComboText = "High Card";

  // Logical evaluation: find the best combination
  let bestScore = -1;
  activeSeatsList.forEach(s => {
    let evalResult = pokerEvaluatePlayerHand(s);
    if (evalResult.score > bestScore) {
      bestScore = evalResult.score;
      winnerSeat = s;
      bestComboText = evalResult.comboName;
    }
  });

  pokerAwardWinner(winnerSeat, bestComboText);
}

// Simple deterministic poker hand ranking evaluator for 7 cards
function pokerEvaluatePlayerHand(seatNum) {
  const pool = [...pokerSimState.playerCards[seatNum], ...pokerSimState.communityCards];
  
  // Sort pool desc
  pool.sort((a,b) => b.val - a.val);

  // Group by val
  let groups = {};
  pool.forEach(c => {
    groups[c.val] = (groups[c.val] || 0) + 1;
  });

  // Group by suit (flush check)
  let suitGroups = {};
  pool.forEach(c => {
    suitGroups[c.suit] = suitGroups[c.suit] || [];
    suitGroups[c.suit].push(c);
  });

  // Flush Check
  let flushSuit = null;
  for (let s in suitGroups) {
    if (suitGroups[s].length >= 5) {
      flushSuit = s;
      break;
    }
  }

  // Straight Check
  let isStraight = false;
  let straightHighVal = 0;
  let uniqueVals = [...new Set(pool.map(c => c.val))].sort((a,b) => b-a);
  for (let i = 0; i <= uniqueVals.length - 5; i++) {
    if (uniqueVals[i] - uniqueVals[i+4] === 4) {
      isStraight = true;
      straightHighVal = uniqueVals[i];
      break;
    }
  }

  // Four of a kind
  let quadVal = 0;
  // Three of a kind
  let tripsVal = 0;
  // Pairs
  let pairs = [];
  
  for (let val in groups) {
    let count = groups[val];
    let v = parseInt(val);
    if (count === 4) quadVal = v;
    else if (count === 3) tripsVal = Math.max(tripsVal, v);
    else if (count === 2) pairs.push(v);
  }
  pairs.sort((a,b) => b-a);

  // Category Scoring
  let category = 1; // High Card
  let comboName = "High Card";

  if (flushSuit && isStraight) {
    category = 9;
    comboName = "Straight Flush";
  } else if (quadVal) {
    category = 8;
    comboName = `Four of a Kind (${quadVal})`;
  } else if (tripsVal && pairs.length > 0) {
    category = 7;
    comboName = `Full House (${tripsVal}s & ${pairs[0]}s)`;
  } else if (flushSuit) {
    category = 6;
    comboName = "Flush";
  } else if (isStraight) {
    category = 5;
    comboName = "Straight";
  } else if (tripsVal) {
    category = 4;
    comboName = `Three of a Kind (${tripsVal})`;
  } else if (pairs.length >= 2) {
    category = 3;
    comboName = `Two Pair (${pairs[0]}s & ${pairs[1]}s)`;
  } else if (pairs.length === 1) {
    category = 2;
    comboName = `One Pair (${pairs[0]}s)`;
  } else {
    comboName = `High Card (${pool[0].rank})`;
  }

  // Compute final score
  let score = category * 10000000 + pool[0].val * 1000 + pool[1].val;
  return { score, comboName };
}

function pokerAwardWinner(winnerSeat, comboText) {
  let winnerName = winnerSeat === 1 ? "You" : pokerSimState.playerProfiles[winnerSeat].name;
  let winAmt = pokerSimState.pot;
  
  pokerSimState.playerChips[winnerSeat] += winAmt;
  pokerUpdateSeatChips(winnerSeat);
  
  // Show Winner overlay alert box
  openModal("🎉 Winner Showdown!", `
    <div style="text-align:center; padding:15px; font-family:'Outfit', sans-serif;">
      <h3 style="color:#00FF66; font-size:18px; margin-bottom:10px;">${winnerName} Won!</h3>
      <p style="font-size:12px; color:#fff; margin-bottom:8px;">Combination: <b>${comboText}</b></p>
      <div style="font-size:16px; font-weight:bold; color:#FFD700; background:rgba(255,215,0,0.15); border:1px solid #FFD700; border-radius:10px; padding:10px; display:inline-flex; align-items:center; justify-content:center; gap:4px; margin-top:8px;">
        <img src="assets/images/icons/luxury_token_red.png" style="width: 14px; height: 14px; object-fit: contain;">+${winAmt.toLocaleString()} Chips
      </div>
    </div>
  `);

  // Start next round automatically after 6 seconds
  setTimeout(() => {
    closeModal();
    pokerStartRound();
  }, 6000);
}

function pokerTriggerSingleWinner(winnerSeat) {
  pokerHideActionBubble(1);
  for (let s = 2; s <= 5; s++) pokerHideActionBubble(s);
  
  let winnerName = winnerSeat === 1 ? "You" : pokerSimState.playerProfiles[winnerSeat].name;
  let winAmt = pokerSimState.pot;

  pokerSimState.playerChips[winnerSeat] += winAmt;
  pokerUpdateSeatChips(winnerSeat);

  openModal("🏆 Table Fold Winner", `
    <div style="text-align:center; padding:15px; font-family:'Outfit', sans-serif;">
      <h3 style="color:#00FF66; font-size:16px; margin-bottom:10px;">${winnerName} Won the Pot!</h3>
      <p style="font-size:11px; color:#fff; margin-bottom:8px;">All other players folded.</p>
      <div style="font-size:14px; font-weight:bold; color:#FFD700; background:rgba(255,215,0,0.15); border:1px solid #FFD700; border-radius:10px; padding:8px; display:inline-flex; align-items:center; justify-content:center; gap:4px; margin-top:8px;">
        <img src="assets/images/icons/luxury_token_red.png" style="width: 12px; height: 12px; object-fit: contain;">+${winAmt.toLocaleString()} Chips
      </div>
    </div>
  `);

  setTimeout(() => {
    closeModal();
    pokerStartRound();
  }, 5000);
}

function pokerStartNextRound() {
  closeModal();
  pokerStartRound();
}

function pokerResetTableUI() {
  pokerClearCommunityCards();
  pokerUpdatePotDisplay();
  for (let s = 1; s <= 5; s++) {
    pokerHideActionBubble(s);
    pokerClearSeatCards(s);
    const seatEl = document.getElementById('poker-seat-' + s);
    if (seatEl) seatEl.classList.remove('active-turn');
  }
}
