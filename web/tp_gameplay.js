// ═══════════════════════════════════════════
//  TEEN PATTI GOLD — Game Logic
// ═══════════════════════════════════════════

const TP_SUITS   = ['♠','♥','♦','♣'];
const TP_VALUES  = ['2','3','4','5','6','7','8','9','10','J','Q','K','A'];

const tpBots = [
  { name:'Aarav',  avatar:'assets/custom_icons/avatar_male_2.jpg',  vip:3, chips:110000 },
  { name:'Rahul',  avatar:'assets/custom_icons/avatar_male_3.jpg',  vip:2, chips:95000  },
  { name:'Priya',  avatar:'assets/custom_icons/avatar_female_1.jpg',vip:3, chips:140000 },
  { name:'Vikram', avatar:'assets/custom_icons/avatar_male_4.jpg',  vip:4, chips:120000 },
  { name:'Meera',  avatar:'assets/custom_icons/avatar_female_2.jpg',vip:2, chips:88000  },
  { name:'Arjun',  avatar:'assets/custom_icons/avatar_male_5.jpg',  vip:5, chips:200000 },
];

let tpState = {
  active:      { 1:true, 2:false, 3:false, 4:false, 5:false },
  profiles:    { 1:{ name:'Tasavvur', avatar:'assets/custom_icons/avatar_tasavvur_face.jpg', vip:5, chips:135000 } },
  chips:       { 1:135000 },
  packed:      {},
  seen:        { 1:false },
  hands:       {},
  pot:         0,
  boot:        1000,
  chaalMin:    2000,
  betAmount:   10000,
  phase:       'idle',  // idle | dealing | playing | showdown
  turn:        1,
  order:       [1],
  muted:       false,
};

// ─── Helpers ───────────────────────────────
function tpFmt(n){ return n >= 100000 ? (n/100000).toFixed(1).replace('.0','')+'L' : n.toLocaleString('en-IN'); }
function tpDeck(){
  let d=[];
  TP_SUITS.forEach(s=>TP_VALUES.forEach(v=>d.push({s,v})));
  for(let i=d.length-1;i>0;i--){ let j=Math.floor(Math.random()*(i+1));[d[i],d[j]]=[d[j],d[i]]; }
  return d;
}
function tpCardHTML(size='sm'){
  const cls = size==='lg' ? 'tp-card' : 'tp-card tp-card-sm';
  return `<div class="${cls} tp-card-deal"><span class="tp-card-r">♛</span></div>`;
}
function tpUpdatePot(){ const el=document.getElementById('tp-pot-value'); if(el) el.textContent=tpFmt(tpState.pot); }
function tpUpdateChips(seat){
  const el=document.getElementById('tp-chips-'+seat);
  if(el) el.textContent=tpFmt(tpState.chips[seat]||0);
  if(seat===1){ const h=document.getElementById('tp-chips'); if(h) h.textContent=tpFmt(tpState.chips[1]||0); }
}

// ─── Join Seat ─────────────────────────────
function tpJoinSeat(seatNum){
  if(tpState.active[seatNum]) return;
  const used = Object.values(tpState.profiles).map(p=>p.name);
  const avail = tpBots.filter(b=>!used.includes(b.name));
  if(!avail.length) return;
  const bot = avail[Math.floor(Math.random()*avail.length)];

  tpState.active[seatNum]   = true;
  tpState.profiles[seatNum] = bot;
  tpState.chips[seatNum]    = bot.chips;

  const join   = document.getElementById('tp-join-'+seatNum);
  const player = document.getElementById('tp-player-'+seatNum);
  const av     = document.getElementById('tp-av-'+seatNum);
  const nameEl = document.getElementById('tp-name-'+seatNum);
  const vipEl  = document.getElementById('tp-vip-'+seatNum);
  const chEl   = document.getElementById('tp-chips-'+seatNum);
  const seat   = document.getElementById('tp-seat-'+seatNum);

  if(join)   join.style.display   = 'none';
  if(player) player.style.display = 'flex';
  if(av)     av.src = bot.avatar;
  if(nameEl) nameEl.textContent   = bot.name;
  if(vipEl)  vipEl.textContent    = '👑 VIP '+bot.vip;
  if(chEl)   chEl.textContent     = tpFmt(bot.chips);
  if(seat)   seat.classList.remove('empty');

  // Auto-start when 3+ players
  const count = Object.values(tpState.active).filter(Boolean).length;
  if(count >= 3 && tpState.phase==='idle') setTimeout(tpStartRound, 1000);
}

// ─── Bot auto-fill ──────────────────────────
function tpAutoFillBots(){
  [2,3,4,5].forEach((s,i)=>{ if(!tpState.active[s]) setTimeout(()=>tpJoinSeat(s), 400+(i*350)); });
}

// ─── Start Round ───────────────────────────
function tpStartRound(){
  if(tpState.phase!=='idle') return;
  tpState.phase   = 'dealing';
  tpState.pot     = 0;
  tpState.packed  = {};
  tpState.hands   = {};
  tpState.seen    = { 1:false };

  const deck = tpDeck();
  let di = 0;

  // Collect boot from all active seats
  const activeSeatNums = Object.keys(tpState.active).filter(s=>tpState.active[s]).map(Number);
  tpState.order = activeSeatNums.sort((a,b)=>a-b);

  activeSeatNums.forEach(s=>{
    tpState.hands[s]  = [deck[di++], deck[di++], deck[di++]];
    tpState.chips[s]  = (tpState.chips[s]||100000) - tpState.boot;
    tpState.pot      += tpState.boot;
    tpUpdateChips(s);
    tpRenderCards(s);
  });
  tpUpdatePot();

  // Reset blind badge
  const bb = document.getElementById('tp-blind-badge'); if(bb) bb.textContent='BLIND';
  const knob = document.getElementById('tp-blind-knob'); if(knob) knob.style.left='2px';
  const blindLbl = document.getElementById('tp-blind-lbl'); if(blindLbl) blindLbl.style.color='#C9A227';
  const seenLbl  = document.getElementById('tp-seen-lbl');  if(seenLbl)  seenLbl.style.color='rgba(255,255,255,0.3)';

  tpState.phase = 'playing';
  tpState.chaalMin = tpState.boot * 2;

  setTimeout(()=>tpNextTurn(0), 600);
}

// ─── Render Cards ──────────────────────────
function tpRenderCards(seat){
  const el = document.getElementById('tp-cards-'+seat);
  if(!el) return;
  if(seat===1){
    el.innerHTML = `
      <div class="tp-card tp-card-deal" style="animation-delay:0s;"><span class="tp-card-r">♛</span></div>
      <div class="tp-card tp-card-deal" style="animation-delay:0.15s;"><span class="tp-card-r">♛</span></div>
      <div class="tp-card tp-card-deal" style="animation-delay:0.3s;"><span class="tp-card-r">♛</span></div>
    `;
  } else {
    el.innerHTML = `
      ${tpCardHTML('sm')}${tpCardHTML('sm')}${tpCardHTML('sm')}
    `;
  }
}

// ─── Turn Logic ─────────────────────────────
function tpNextTurn(orderIdx){
  const alive = tpState.order.filter(s=>!tpState.packed[s]);
  if(alive.length<=1){ tpShowdown(alive[0]||tpState.order[0]); return; }

  const seat = tpState.order[orderIdx % tpState.order.length];
  if(!seat){ tpNextTurn(orderIdx+1); return; }
  if(tpState.packed[seat]){ tpNextTurn(orderIdx+1); return; }

  tpState.turn = seat;
  // Highlight active seat
  [1,2,3,4,5].forEach(s=>{
    const el = document.getElementById('tp-seat-'+s);
    if(el) el.classList.toggle('active-turn', s===seat);
  });

  if(seat===1){ return; } // Wait for player input

  // Bot AI
  const botDelay = 1000 + Math.random()*1500;
  setTimeout(()=>{
    if(tpState.phase!=='playing') return;
    const r = Math.random();
    if(r < 0.15 && alive.length>2){
      tpBotAction(seat, orderIdx, 'PACK');
    } else {
      tpBotAction(seat, orderIdx, 'CHAAL');
    }
  }, botDelay);
}

function tpBotAction(seat, orderIdx, action){
  if(action==='PACK'){
    tpState.packed[seat] = true;
    tpShowAction(seat,'PACK 🚫');
    tpClearCards(seat);
  } else {
    const amt = tpState.seen[seat] ? tpState.chaalMin*2 : tpState.chaalMin;
    tpState.chips[seat] = (tpState.chips[seat]||100000) - amt;
    tpState.pot += amt;
    tpUpdatePot();
    tpUpdateChips(seat);
    tpShowAction(seat, `CHAAL ${tpFmt(amt)}`);
  }
  setTimeout(()=>{
    tpHideAction(seat);
    tpNextTurn(orderIdx+1);
  }, 1200);
}

// ─── Player Actions ─────────────────────────
function tpPlayerAction(action){
  if(tpState.phase!=='playing' || tpState.turn!==1) return;
  const orderIdx = tpState.order.indexOf(1);

  if(action==='PACK'){
    tpState.packed[1] = true;
    tpShowAction(1,'PACK 🚫');
    document.getElementById('tp-cards-1').innerHTML='';
    setTimeout(()=>{ tpHideAction(1); tpNextTurn(orderIdx+1); },800);

  } else if(action==='CHAAL'){
    const amt = tpState.seen[1] ? tpState.chaalMin*2 : tpState.chaalMin;
    if((tpState.chips[1]||0)<amt){ tpShowAction(1,'Not enough chips!'); setTimeout(()=>tpHideAction(1),1200); return; }
    tpState.chips[1] -= amt;
    tpState.pot      += amt;
    tpUpdatePot(); tpUpdateChips(1);
    tpShowAction(1,`CHAAL ${tpFmt(amt)}`);
    setTimeout(()=>{ tpHideAction(1); tpNextTurn(orderIdx+1); },800);

  } else if(action==='SEE'){
    if(!tpState.seen[1]){
      tpState.seen[1] = true;
      tpRevealMyCards();
      const bb=document.getElementById('tp-blind-badge'); if(bb) bb.textContent='SEEN';
      tpToggleSeen(true);
    }
    tpShowAction(1,'SEE 👁️');
    setTimeout(()=>tpHideAction(1),1000);

  } else if(action==='SIDE SHOW'){
    tpShowAction(1,'SIDE SHOW 🤝');
    setTimeout(()=>tpHideAction(1),1200);
  }
}

function tpRevealMyCards(){
  const el = document.getElementById('tp-cards-1');
  if(!el || !tpState.hands[1]) return;
  el.innerHTML = tpState.hands[1].map(c=>`
    <div class="tp-card tp-card-deal" style="background:linear-gradient(135deg,#fff,#f0e8d0);border-color:#C9A227;">
      <span class="tp-card-r" style="color:${(c.s==='♥'||c.s==='♦')?'#CC0000':'#000'};font-size:14px;">${c.v}${c.s}</span>
    </div>
  `).join('');
}

// ─── Showdown ───────────────────────────────
function tpShowdown(winner){
  tpState.phase = 'idle';
  const winName = winner ? (tpState.profiles[winner]?.name || 'Player '+winner) : '?';
  const pot = tpState.pot;
  tpState.chips[winner] = (tpState.chips[winner]||0) + pot;
  tpUpdateChips(winner);
  tpState.pot=0; tpUpdatePot();

  [1,2,3,4,5].forEach(s=>{ const e=document.getElementById('tp-seat-'+s); if(e) e.classList.remove('active-turn'); });
  tpShowAction(winner, `🏆 WIN! +${tpFmt(pot)}`);
  setTimeout(()=>{
    tpHideAction(winner);
    tpResetTable();
  }, 3000);
}

// ─── Helpers ────────────────────────────────
function tpShowAction(seat, text){
  const el = document.getElementById('tp-action-'+seat);
  if(el){ el.textContent=text; el.style.display='block'; }
}
function tpHideAction(seat){
  const el = document.getElementById('tp-action-'+seat);
  if(el) el.style.display='none';
}
function tpClearCards(seat){
  const el = document.getElementById('tp-cards-'+seat);
  if(el) el.innerHTML='';
}

function tpResetTable(){
  tpState.phase='idle'; tpState.pot=0; tpState.packed={}; tpState.hands={};
  tpUpdatePot();
  // Clear all cards & actions
  [1,2,3,4,5].forEach(s=>{ tpClearCards(s); tpHideAction(s); });
  setTimeout(tpStartRound, 2000);
}

function tpAdjustBet(delta){
  tpState.betAmount = Math.max(1000, (tpState.betAmount||10000)+delta);
  const el=document.getElementById('tp-bet-amount');
  if(el) el.textContent=tpFmt(tpState.betAmount);
}

function tpToggleSeen(forceOn){
  const isSeen = forceOn===true ? true : !tpState.seen[1];
  tpState.seen[1] = isSeen;
  const knob    = document.getElementById('tp-blind-knob');
  const blindLbl= document.getElementById('tp-blind-lbl');
  const seenLbl = document.getElementById('tp-seen-lbl');
  const bb      = document.getElementById('tp-blind-badge');
  if(knob)    knob.style.left    = isSeen ? '14px' : '2px';
  if(blindLbl)blindLbl.style.color= isSeen ? 'rgba(255,255,255,0.3)' : '#C9A227';
  if(seenLbl) seenLbl.style.color = isSeen ? '#C9A227' : 'rgba(255,255,255,0.3)';
  if(bb)      bb.textContent      = isSeen ? 'SEEN' : 'BLIND';
  if(isSeen)  tpRevealMyCards();
}

let _tpMuted = false;
function tpToggleMute(){
  _tpMuted = !_tpMuted;
  const ic=document.getElementById('tp-mute-icon');
  if(ic) ic.textContent = _tpMuted ? '🔇' : '🔊';
}

// ─── Init ────────────────────────────────────
function tpInit(){
  // Set player 1 state
  tpState.chips[1] = 135000;
  tpUpdateChips(1);
  // Auto-fill bots after 1 second
  setTimeout(tpAutoFillBots, 800);
}

// Called by screen navigation
function initTeenPattiScreen(){
  if(tpState.phase==='idle'){
    tpInit();
  }
}
