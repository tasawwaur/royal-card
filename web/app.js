// ═══════════════════════════════════════════════════════════
// WEB APPLICATION STATE & CONTROLLER
// ═══════════════════════════════════════════════════════════

let player = {
  name: "LuckyPlayer",
  chips: 100058,
  gems: 60,
  level: 1,
  xp: 0,
  xpMax: 500,
  vipLevel: 5,
  avatar: "🤵",
  frame: "frame-emperor",
  stats: {
    gamesPlayed: 0,
    gamesWon: 0,
    biggestWin: 0
  }
};

// Current active game mode config
let currentActiveMode = ''; // 'teenPatti' or 'andarBahar'

// ─── 1. Screen Manager ───
function showScreen(screenId) {
  // Hide all screens
  document.querySelectorAll('.screen').forEach(scr => scr.classList.remove('active'));
  // Show target
  const target = document.getElementById(screenId);
  if (target) {
    target.classList.add('active');
  }
  // Sync header info
  syncUI();
}

function syncUI() {
  // Update name displays
  const headerName = document.getElementById('header-player-name');
  if (headerName) headerName.innerText = player.name;
  
  const homeName = document.getElementById('home-player-name');
  if (homeName) homeName.innerText = player.name;
  
  const profileName = document.getElementById('profile-name');
  if (profileName) profileName.innerText = player.name;
  
  // Update avatar and frame
  const avatarEl = document.getElementById('header-profile-avatar');
  if (avatarEl) {
    avatarEl.innerText = player.avatar;
    avatarEl.className = 'avatar-frame ' + player.frame;
  }
  const vipBadge = document.getElementById('header-vip-badge');
  if (vipBadge) {
    vipBadge.innerText = 'VIP ' + player.vipLevel;
  }

  // Update chip displays
  const chipsFmt = fmtChips(player.chips);
  const headerChips = document.getElementById('header-chips');
  if (headerChips) headerChips.innerText = chipsFmt;
  
  const homeChips = document.getElementById('home-chips-val');
  if (homeChips) homeChips.innerText = chipsFmt;
  
  const abChips = document.getElementById('ab-user-chips');
  if (abChips) abChips.innerText = '🪙 ' + chipsFmt;
  
  const tpChips = document.getElementById('tp-user-chips');
  if (tpChips) tpChips.innerText = '🪙 ' + chipsFmt;
  
  const walletBal = document.getElementById('wallet-balance-text');
  if (walletBal) walletBal.innerText = chipsFmt;

  // Update profile level & stats
  const walletLevel = document.getElementById('wallet-level-info');
  if (walletLevel) walletLevel.innerText = 'Level ' + player.level;
  
  const pGames = document.getElementById('profile-games-played');
  if (pGames) pGames.innerText = player.stats.gamesPlayed;
  
  const pWon = document.getElementById('profile-games-won');
  if (pWon) pWon.innerText = player.stats.gamesWon;
  
  const wr = player.stats.gamesPlayed > 0 ? ((player.stats.gamesWon / player.stats.gamesPlayed) * 100).toFixed(1) : 0;
  const pWinRate = document.getElementById('profile-win-rate');
  if (pWinRate) pWinRate.innerText = wr + '%';
  
  const pMaxWin = document.getElementById('profile-max-win');
  if (pMaxWin) pMaxWin.innerText = fmtChips(player.stats.biggestWin);
}

// ─── 2. Alert Dialog ───
function showAlert(title, msg, icon = '⚠️') {
  document.getElementById('alert-icon').innerText = icon;
  document.getElementById('alert-title').innerText = title;
  document.getElementById('alert-msg').innerText = msg;
  document.getElementById('alert-dialog').style.display = 'flex';
}

function closeAlert() {
  document.getElementById('alert-dialog').style.display = 'none';
}

// ─── 3. Splash Loading Simulation ───
window.addEventListener('load', () => {
  let progress = 0;
  const bar = document.getElementById('splash-progress');
  const status = document.getElementById('splash-status');
  const interval = setInterval(() => {
    progress += Math.floor(Math.random() * 15) + 5;
    if (progress >= 100) {
      progress = 100;
      clearInterval(interval);
      status.innerText = "Connecting to table servers...";
      setTimeout(() => {
        showScreen('screen-login');
      }, 500);
    }
    bar.style.width = progress + '%';
  }, 120);
});

// ─── 4. Login Actions ───
document.getElementById('btn-guest-login').addEventListener('click', () => {
  const customName = document.getElementById('login-name').value.trim();
  if (customName) {
    player.name = customName;
  }
  showScreen('screen-home');
  showAlert("Welcome!", `Logged in as guest: ${player.name}`, "👤");
});

// Logout
function logout() {
  player.chips = 10058;
  player.stats.gamesPlayed = 0;
  player.stats.gamesWon = 0;
  player.stats.biggestWin = 0;
  showScreen('screen-login');
}

// ─── 5. Lobby & Room Selection ───
function goToLobby(mode) {
  currentActiveMode = mode;
  const lobbyTitle = document.getElementById('lobby-title');
  const container = document.getElementById('lobby-rooms-container');
  container.innerHTML = ''; // Clear

  if (mode === 'teenPatti') {
    lobbyTitle.innerText = "Teen Patti Classic Rooms";
    // Define classic rooms
    const rooms = [
      { id: 'T101', minBet: 100, maxBet: 1000, players: 4, variation: 'Classic' },
      { id: 'T102', minBet: 500, maxBet: 5000, players: 3, variation: 'Classic' },
      { id: 'T103', minBet: 1000, maxBet: 10000, players: 5, variation: 'Classic' }
    ];
    rooms.forEach(r => {
      container.innerHTML += `
        <div class="room-tile" onclick="enterRoom('teenPatti', '${r.id}', ${r.minBet})">
          <div class="room-info">
            <span class="room-title">Table #${r.id}</span>
            <span class="room-details">${r.variation} • Min Bet: ${fmtChips(r.minBet)}</span>
          </div>
          <button class="gold-btn" style="font-size: 11px; padding: 6px 12px;">JOIN</button>
        </div>
      `;
    });
  } else if (mode === 'andarBahar') {
    lobbyTitle.innerText = "Andar Bahar Rooms";
    const rooms = [
      { id: 'A101', minBet: 200, maxBet: 5000, players: 3, variation: 'Classic' },
      { id: 'A102', minBet: 1000, maxBet: 20000, players: 4, variation: 'Classic' }
    ];
    rooms.forEach(r => {
      container.innerHTML += `
        <div class="room-tile" onclick="enterRoom('andarBahar', '${r.id}', ${r.minBet})">
          <div class="room-info">
            <span class="room-title">Table #${r.id}</span>
            <span class="room-details">${r.variation} • Min Bet: ${fmtChips(r.minBet)}</span>
          </div>
          <button class="gold-btn" style="font-size: 11px; padding: 6px 12px;">JOIN</button>
        </div>
      `;
    });
  }
  showScreen('screen-game-lobby');
}

function enterRoom(mode, roomId, minBet) {
  if (mode === 'teenPatti') {
    initTeenPattiRoom(roomId, minBet);
    showScreen('screen-teen-patti');
  } else if (mode === 'andarBahar') {
    initAndarBaharRoom(roomId, minBet);
    showScreen('screen-andar-bahar');
  }
}

// ─── 6. Andar Bahar Game Logic ───
let abState = {
  roomId: '',
  minBet: 200,
  selectedSide: null,
  betAmount: 200,
  joker: null,
  andarCards: [],
  baharCards: [],
  dealing: false
};

function initAndarBaharRoom(roomId, minBet) {
  abState.roomId = roomId;
  abState.minBet = minBet;
  abState.selectedSide = null;
  abState.joker = null;
  abState.andarCards = [];
  abState.baharCards = [];
  abState.dealing = false;

  // Clear spots
  document.getElementById('ab-joker-card').innerHTML = '<span style="color: var(--gold-primary); font-size: 11px;">Joker</span>';
  document.getElementById('andar-cards').innerHTML = '';
  document.getElementById('bahar-cards').innerHTML = '';
  document.getElementById('andar-pool-text').innerText = 'Pool: 0';
  document.getElementById('bahar-pool-text').innerText = 'Pool: 0';
  document.getElementById('btn-ab-deal').innerText = 'DEAL / START';
}

function selectAbSide(side) {
  if (abState.dealing) return;
  abState.selectedSide = side;
  showAlert("Bet Side Chosen", `You bet on ${side}! Now press DEAL to draw cards.`, "🟢");
}

function selectChip(amount, element) {
  abState.betAmount = amount;
  // highlight
  document.querySelectorAll('.chip-btn').forEach(btn => btn.classList.remove('selected'));
  element.classList.add('selected');
}

function clearAbBets() {
  if (abState.dealing) return;
  abState.selectedSide = null;
  showAlert("Cleared", "All bets cleared from table.", "🧹");
}

function startAbDeal() {
  if (abState.dealing) return;
  if (!abState.selectedSide) {
    showAlert("No Bet", "Please select ANDAR or BAHAR side before starting!", "⚠️");
    return;
  }
  if (player.chips < abState.betAmount) {
    showAlert("Insufficient Chips", "You don't have enough chips to play this bet!", "⚠️");
    return;
  }

  // Deduct real chips
  player.chips -= abState.betAmount;
  player.stats.gamesPlayed++;
  syncUI();

  abState.dealing = true;
  abState.andarCards = [];
  abState.baharCards = [];
  document.getElementById('andar-cards').innerHTML = '';
  document.getElementById('bahar-cards').innerHTML = '';

  // Get round calculation from real game engine (engine.js)
  const round = playAndarBaharRound();
  abState.joker = round.joker;

  // Render Joker
  const colorClass = (round.joker.suit === 'HEARTS' || round.joker.suit === 'DIAMONDS') ? 'red' : '';
  document.getElementById('ab-joker-card').innerHTML = `
    <div class="mini-card ${colorClass}" style="width: 52px; height: 72px; font-size: 16px;">
      <span>${round.joker.rank}</span>
      <span>${round.joker.sym}</span>
    </div>
  `;

  // Draw steps incrementally
  let i = 0;
  const dealInterval = setInterval(() => {
    if (i >= round.steps.length) {
      clearInterval(dealInterval);
      resolveAbRound(round.winner);
      return;
    }

    const step = round.steps[i];
    const isRed = (step.card.suit === 'HEARTS' || step.card.suit === 'DIAMONDS');
    const color = isRed ? 'red' : '';
    const cardHtml = `
      <div class="mini-card ${color}">
        <span>${step.card.rank}</span>
        <span>${step.card.sym}</span>
      </div>
    `;

    if (step.spot === 'ANDAR') {
      document.getElementById('andar-cards').innerHTML += cardHtml;
      abState.andarCards.push(step.card);
      document.getElementById('andar-pool-text').innerText = 'Pool: ' + fmtChips(abState.betAmount);
    } else {
      document.getElementById('bahar-cards').innerHTML += cardHtml;
      abState.baharCards.push(step.card);
      document.getElementById('bahar-pool-text').innerText = 'Pool: ' + fmtChips(abState.betAmount);
    }

    i++;
  }, 400); // Draw speed
}

function resolveAbRound(winner) {
  abState.dealing = false;
  const win = abState.selectedSide === winner;
  if (win) {
    const profit = calculate2xPayout(abState.betAmount, abState.selectedSide, winner);
    player.chips += profit;
    player.stats.gamesWon++;
    if (profit > player.stats.biggestWin) {
      player.stats.biggestWin = profit;
    }
    showAlert("Victory!", `The winning spot is ${winner}. You won ${fmtChips(profit)} chips! 🏆`, "🎉");
  } else {
    showAlert("Lost", `The winning spot is ${winner}. Better luck next time!`, "❌");
  }
  syncUI();
  document.getElementById('btn-ab-deal').innerText = 'PLAY AGAIN';
}

// ─── 7. Teen Patti Game Logic ───
let tpState = {
  pot: 0,
  currentBet: 100,
  isBlind: true,
  cards: [],
  hasSeen: false
};

function initTeenPattiRoom(roomId, minBet) {
  tpState.pot = minBet * 5; // Boot collected
  tpState.currentBet = minBet;
  tpState.isBlind = true;
  tpState.hasSeen = false;

  // Deduct boot
  player.chips -= minBet;
  player.stats.gamesPlayed++;
  syncUI();

  // Deal hands
  const hands = dealHands(5);
  tpState.cards = hands[2]; // seat 2 is user

  // Render cards face down
  document.getElementById('self-cards-container').innerHTML = `
    <div class="mini-card" style="width:38px; height:54px; font-size:12px;">🎴</div>
    <div class="mini-card" style="width:38px; height:54px; font-size:12px;">🎴</div>
    <div class="mini-card" style="width:38px; height:54px; font-size:12px;">🎴</div>
  `;

  document.getElementById('tp-pot-val').innerText = 'POT: ' + fmtChips(tpState.pot);
  document.getElementById('tp-status-self').innerText = 'BLIND';
  document.getElementById('btn-tp-blind').innerText = `BLIND (${minBet})`;
  document.getElementById('btn-tp-chaal').innerText = `CHAAL (${minBet * 2})`;
}

function tpSeeCards() {
  if (tpState.hasSeen) return;
  tpState.hasSeen = true;
  tpState.isBlind = false;

  // Render player cards face up
  let container = document.getElementById('self-cards-container');
  container.innerHTML = '';
  tpState.cards.forEach(card => {
    const isRed = (card.suit === 'HEARTS' || card.suit === 'DIAMONDS');
    const color = isRed ? 'red' : '';
    container.innerHTML += `
      <div class="mini-card ${color}" style="width:38px; height:54px; font-size:12px;">
        <span>${card.rank}</span>
        <span>${card.sym}</span>
      </div>
    `;
  });

  const evaluation = evaluateHand(tpState.cards);
  document.getElementById('tp-status-self').innerText = 'SEEN: ' + evaluation.type;
}

function tpBet(blind) {
  const cost = blind ? tpState.currentBet : tpState.currentBet * 2;
  if (player.chips < cost) {
    showAlert("Insufficient Chips", "Not enough chips to bet!", "⚠️");
    return;
  }
  player.chips -= cost;
  tpState.pot += cost;
  document.getElementById('tp-pot-val').innerText = 'POT: ' + fmtChips(tpState.pot);
  syncUI();

  // Randomly have one bot pack (fold) or match
  const botSeat = Math.floor(Math.random() * 4);
  const statusEl = document.getElementById(`tp-status-${botSeat}`);
  if (statusEl) {
    statusEl.innerText = Math.random() > 0.3 ? 'SEEN' : 'PACKED';
  }
}

function tpFold() {
  showAlert("Packed", "You folded this round.", "🙅");
  showScreen('screen-home');
}

function tpShow() {
  // Compare hands to determine winner
  const botHands = dealHands(4);
  let bestHand = tpState.cards;
  let winner = "You";
  
  botHands.forEach((bh, i) => {
    const cmp = compareHands(bh, bestHand);
    if (cmp > 0) {
      bestHand = bh;
      winner = `Bot Player ${i + 1}`;
    }
  });

  if (winner === "You") {
    player.chips += tpState.pot;
    player.stats.gamesWon++;
    if (tpState.pot > player.stats.biggestWin) {
      player.stats.biggestWin = tpState.pot;
    }
    showAlert("Winner!", `You won the showdown! Hand: ${evaluateHand(tpState.cards).label} and pocketed ${fmtChips(tpState.pot)} chips!`, "🏆");
  } else {
    showAlert("Showdown Result", `${winner} wins with a better hand. Better luck next time!`, "❌");
  }
  syncUI();
}

// ─── 8. Wallet Purchase simulation ───
function purchaseChips(amount, price) {
  player.chips += amount;
  showAlert("Purchase Successful", `Added ${fmtChips(amount)} chips to your account!`, "💸");
  syncUI();
}

function claimDailyStreak() {
  player.chips += 10000;
  showAlert("Claimed!", "Added 10,000 streak chips!", "🎁");
  syncUI();
}

// ─── 9. Render Leaderboards ───
function initLeaderboards() {
  const container = document.getElementById('leaderboard-container');
  container.innerHTML = `
    <div style="background: linear-gradient(135deg, var(--gold-dark) 0%, var(--gold-primary) 100%); color:#000; border-radius:12px; padding:12px; font-weight:bold; display:flex; justify-content:space-between; margin-bottom:12px;">
      <span>Rank #1 (Weekly Champion)</span>
      <span>10 Cr Prize Pool</span>
    </div>
  `;
  const leaders = [
    { rank: 1, name: "MaharajaAce", chips: 98750000 },
    { rank: 2, name: "GoldenAce", chips: 75400000 },
    { rank: 3, name: "BaharPro", chips: 52300000 },
    { rank: 4, name: player.name, chips: player.chips }
  ];
  leaders.forEach(l => {
    container.innerHTML += `
      <div class="room-tile" style="margin-bottom: 8px; ${l.name === player.name ? 'border-color:var(--gold-primary);' : ''}">
        <div class="room-info">
          <span class="room-title">#${l.rank} ${l.name}</span>
          <span class="room-details">Winnings: ${fmtChips(l.chips)}</span>
        </div>
        <span style="font-size: 20px;">🥇</span>
      </div>
    `;
  });
}

// Register Leaderboards view trigger
document.querySelector('[onclick="showScreen(\'screen-leaderboard\')"]').addEventListener('click', () => {
  initLeaderboards();
});
