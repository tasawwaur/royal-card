import Fastify from 'fastify';
import cors from '@fastify/cors';
import dotenv from 'dotenv';
import { createLogger } from '@teenpatti/logger';
import { playAndarBaharRound, calculate2xAndarBaharPayout, AndarBaharStep } from '@teenpatti/game-rules';

dotenv.config({ path: '../../.env' });

const logger = createLogger('API-Server');

const fastify = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
    transport:
      process.env.NODE_ENV !== 'production'
        ? {
            target: 'pino-pretty',
            options: { colorize: true, translateTime: 'SYS:standard', ignore: 'pid,hostname' },
          }
        : undefined,
  },
});

async function main() {
  await fastify.register(cors, { origin: '*' });

  // Visual Interactive Casino Dashboard at http://localhost:4000/
  fastify.get('/', async (request, reply) => {
    reply.type('text/html').send(`
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Teen Patti Gold - Live Visual Game Playground</title>
        <style>
          body {
            background-color: #052415;
            color: #FFFFFF;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
          }
          .container {
            max-width: 950px;
            width: 100%;
            background: rgba(10, 10, 18, 0.95);
            border: 3px solid #FFD700;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 0 40px rgba(255, 215, 0, 0.3);
          }
          h1 { color: #FFD700; text-align: center; margin: 0 0 5px 0; text-shadow: 0 0 10px #FFD700; }
          p.subtitle { text-align: center; color: #A0A0B2; margin-top: 0; }
          .table-board {
            background: radial-gradient(circle, #0B3B24 0%, #052415 100%);
            border: 3px solid #D4AF37;
            border-radius: 16px;
            padding: 20px;
            margin-top: 20px;
            box-shadow: inset 0 0 30px rgba(0,0,0,0.8);
          }
          .joker-area {
            text-align: center;
            margin-bottom: 20px;
          }
          .card-unit {
            display: inline-flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 60px;
            height: 85px;
            background: #FFFFFF;
            color: #000000;
            border-radius: 8px;
            border: 2px solid #FFD700;
            font-weight: bold;
            font-size: 20px;
            margin: 4px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.5);
          }
          .card-unit.red { color: #E60039; }
          .card-unit.joker-card {
            width: 75px;
            height: 105px;
            font-size: 24px;
            border: 3px solid #FFD700;
            box-shadow: 0 0 20px #FFD700;
          }
          .spots-container {
            display: flex;
            gap: 20px;
          }
          .spot-box {
            flex: 1;
            background: rgba(0,0,0,0.5);
            border-radius: 12px;
            padding: 15px;
            min-height: 150px;
          }
          .spot-box.bahar { border: 2px solid #FFB300; }
          .spot-box.andar { border: 2px solid #29B6F6; }
          .spot-title {
            font-size: 18px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 10px;
          }
          .bahar .spot-title { color: #FFB300; }
          .andar .spot-title { color: #29B6F6; }
          .btn-play {
            background: linear-gradient(135deg, #FFE57F, #FFD700, #B8860B);
            color: #000;
            font-weight: bold;
            font-size: 18px;
            padding: 14px 28px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            width: 100%;
            margin-top: 15px;
            box-shadow: 0 0 15px rgba(255, 215, 0, 0.4);
          }
          .btn-play:hover { transform: scale(1.02); }
          .banner-win {
            background: #00C853;
            color: #000;
            font-weight: bold;
            text-align: center;
            padding: 12px;
            border-radius: 8px;
            font-size: 18px;
            margin-top: 15px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🎰 TEEN PATTI GOLD 🎰</h1>
          <p class="subtitle">Live Visual 2X Andar Bahar Game Engine</p>

          <button class="btn-play" onclick="playVisualRound()">▶️ DEAL NEW ANDAR BAHAR ROUND (2X PAYOUT)</button>

          <div class="table-board">
            <!-- CENTER JOKER SLOT -->
            <div class="joker-area">
              <div style="color: #FFD700; font-size: 14px; font-weight: bold; margin-bottom: 6px;">CENTER JOKER CARD</div>
              <div id="joker-slot">
                <div class="card-unit joker-card">🃏<br><span style="font-size: 12px;">WAITING</span></div>
              </div>
            </div>

            <!-- BAHAR (LEFT) vs ANDAR (RIGHT) BOARDS -->
            <div class="spots-container">
              <div class="spot-box bahar">
                <div class="spot-title">👈 LEFT SIDE: BAHAR</div>
                <div id="bahar-cards"></div>
              </div>

              <div class="spot-box andar">
                <div class="spot-title">👉 RIGHT SIDE: ANDAR</div>
                <div id="andar-cards"></div>
              </div>
            </div>

            <div id="win-banner" style="display:none;" class="banner-win"></div>
          </div>
        </div>

        <script>
          const SUIT_SYMBOLS = { 'SPADES': '♠', 'HEARTS': '♥', 'DIAMONDS': '♦', 'CLUBS': '♣' };

          function renderCard(card, isJoker = false) {
            const isRed = card.suit === 'HEARTS' || card.suit === 'DIAMONDS';
            const suitSym = SUIT_SYMBOLS[card.suit] || card.suit;
            const cls = isJoker ? 'card-unit joker-card' : 'card-unit';
            return \`<div class="\${cls} \${isRed ? 'red' : ''}"><div>\${card.rank}</div><div style="font-size: 16px;">\${suitSym}</div></div>\`;
          }

          async function playVisualRound() {
            document.getElementById('win-banner').style.display = 'none';
            document.getElementById('andar-cards').innerHTML = '';
            document.getElementById('bahar-cards').innerHTML = '';

            const res = await fetch('/api/andar-bahar/play');
            const data = await res.json();

            // Render Center Joker
            document.getElementById('joker-slot').innerHTML = renderCard(data.jokerCard, true);

            // Animate card dealing step by step
            let andarHtml = '';
            let baharHtml = '';

            data.dealStepsSummary.forEach((stepStr, idx) => {
              setTimeout(() => {
                const isAndar = stepStr.startsWith('ANDAR');
                const cardMatch = stepStr.match(/(\w+) of (\w+)/);
                if (cardMatch) {
                  const cardObj = { rank: cardMatch[1], suit: cardMatch[2] };
                  if (isAndar) {
                    andarHtml += renderCard(cardObj);
                    document.getElementById('andar-cards').innerHTML = andarHtml;
                  } else {
                    baharHtml += renderCard(cardObj);
                    document.getElementById('bahar-cards').innerHTML = baharHtml;
                  }
                }

                if (idx === data.dealStepsSummary.length - 1) {
                  const banner = document.getElementById('win-banner');
                  banner.style.display = 'block';
                  banner.innerHTML = \`🏆 WINNER: MATCHING CARD DROPPED ON [\${data.winningSpot}]! 🎉 2X PAYOUT = 🪙 1,000!\`;
                }
              }, idx * 250);
            });
          }
        </script>
      </body>
      </html>
    `);
  });

  // Health endpoint
  fastify.get('/health', async (request, reply) => {
    return {
      status: 'healthy',
      service: 'Teen Patti Fastify REST API',
      timestamp: new Date().toISOString(),
    };
  });

  // Live Andar Bahar Play Endpoint for Browser Testing
  fastify.get('/api/andar-bahar/play', async (request, reply) => {
    const round = playAndarBaharRound();
    const payoutAndar = calculate2xAndarBaharPayout(500, 'ANDAR', round.winningSpot);
    const payoutBahar = calculate2xAndarBaharPayout(500, 'BAHAR', round.winningSpot);

    return {
      jokerCard: round.jokerCard,
      winningSpot: round.winningSpot,
      totalCardsDealt: round.totalCardsDealt,
      dealStepsSummary: round.dealSteps.map((s: AndarBaharStep) => `${s.spot}: ${s.card.rank} of ${s.card.suit}${s.isMatch ? ' (MATCH!)' : ''}`),
      payouts: {
        andarBet500: payoutAndar,
        baharBet500: payoutBahar,
      }
    };
  });

  const PORT = Number(process.env.API_PORT) || 4000;

  if (process.env.NODE_ENV !== 'test') {
    try {
      await fastify.listen({ port: PORT, host: '0.0.0.0' });
      logger.info(`Fastify REST API listening on port ${PORT}`);
    } catch (err) {
      logger.error('Failed to start Fastify API server', err);
      process.exit(1);
    }
  }
}

main();

export default fastify;
