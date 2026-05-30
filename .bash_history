    }
    .controls-text {
        margin-bottom: 10px;
        font-size: 13px;
        color: #a4b0be;
    }
    .btn {
        background-color: #ff4757;
        color: white;
        border: none;
        padding: 10px 20px;
        font-size: 15px;
        font-weight: bold;
        border-radius: 5px;
        cursor: pointer;
        margin-top: 5px;
    }
</style>
</head>
<body>

    <h1>Saim's Gaming Zone 🎮</h1>
    <p style="margin-top:0; color:#a4b0be; font-size:14px;">Play and Enjoy!</p>
    
    <div class="tab-container">
        <button class="tab-btn active" onclick="switchGame('tic-tac-toe')">Tic-Tac-Toe ❌⭕</button>
        <button class="tab-btn" onclick="switchGame('table-tennis')">Table Tennis 🏓</button>
        <button class="tab-btn" onclick="switchGame('snake-game')">Snake Game 🐍</button>
    </div>

    <div id="tic-tac-toe" class="game-section active">
        <div class="status" id="status">Player X's turn</div>
        <div class="board" id="board">
            <div class="cell" data-index="0"></div>
            <div class="cell" data-index="1"></div>
            <div class="cell" data-index="2"></div>
            <div class="cell" data-index="3"></div>
            <div class="cell" data-index="4"></div>
            <div class="cell" data-index="5"></div>
            <div class="cell" data-index="6"></div>
            <div class="cell" data-index="7"></div>
            <div class="cell" data-index="8"></div>
        </div>
        <button class="btn" onclick="resetGame()">Restart Game</button>
    </div>

    <div id="table-tennis" class="game-section">
        <div class="controls-text">Left side screen par finger up/down drag karke paddle control karo! ⚡</div>
        <div class="canvas-container">
            <canvas id="pongCanvas" width="450" height="320"></canvas>
        </div>
        <button class="btn" onclick="resetPong()">Reset Match</button>
    </div>

    <div id="snake-game" class="game-section">
        <div class="controls-text">Game screen par kisi bhi taraf finger Swipe (drag) karke saanp ko moro! 🍎</div>
        <div id="snakeScore" style="font-size: 18px; margin-bottom: 8px; font-weight: bold; color: #2ed573;">Score: 0</div>
        <div class="canvas-container">
            <canvas id="snakeCanvas" width="400" height="400"></canvas>
        </div>
        <button class="btn" onclick="resetSnake()">Restart Snake</button>
    </div>

<script>
    function playSound(type) {
        try {
            const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            const oscillator = audioCtx.createOscillator();
            const gainNode = audioCtx.createGain();
            oscillator.connect(gainNode);
            gainNode.connect(audioCtx.destination);
            if (type === 'click') {
                oscillator.type = 'sine'; oscillator.frequency.setValueAtTime(400, audioCtx.currentTime);
                gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.08);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.08);
            } else if (type === 'win') {
                oscillator.type = 'triangle'; oscillator.frequency.setValueAtTime(350, audioCtx.currentTime);
                oscillator.frequency.exponentialRampToValueAtTime(650, audioCtx.currentTime + 0.25);
                gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.3);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.3);
            } else if (type === 'draw') {
                oscillator.type = 'sawtooth'; oscillator.frequency.setValueAtTime(220, audioCtx.currentTime);
                gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.2);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.2);
            } else if (type === 'bounce') {
                oscillator.type = 'sine'; oscillator.frequency.setValueAtTime(480, audioCtx.currentTime);
                gainNode.gain.setValueAtTime(0.04, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.06);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.06);
            } else if (type === 'eat') {
                oscillator.type = 'sine'; oscillator.frequency.setValueAtTime(520, audioCtx.currentTime);
                oscillator.frequency.exponentialRampToValueAtTime(800, audioCtx.currentTime + 0.1);
                gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.1);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.1);
            }
        } catch(e) {}
    }

    function switchGame(gameId) {
        playSound('click');
        document.querySelectorAll('.game-section').forEach(sec => sec.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        document.getElementById(gameId).classList.add('active');
        if(event && event.target) { event.target.classList.add('active'); }
        stopPong();
        stopSnake();
        if(gameId === 'table-tennis') { initPong(); }
        else if(gameId === 'snake-game') { initSnake(); }
    }

    // 1. TIC-TAC-TOE LOGIC
    const cells = document.querySelectorAll('.cell');
    const statusText = document.getElementById('status');
    let currentPlayer = "X"; let gameState = ["", "", "", "", "", "", "", "", ""]; let isGameActive = true;
    const winningConditions = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    cells.forEach(cell => cell.addEventListener('click', handleCellClick));
    function handleCellClick(e) {
        const clickedCell = e.target; const clickedCellIndex = parseInt(clickedCell.getAttribute('data-index'));
        if (gameState[clickedCellIndex] !== "" || !isGameActive) return;
        playSound('click'); gameState[clickedCellIndex] = currentPlayer; clickedCell.innerText = currentPlayer;
        clickedCell.style.color = currentPlayer === "X" ? "#ff4757" : "#1e90ff"; checkResult();
    }
    function checkResult() {
        let roundWon = false;
        for (let i = 0; i < winningConditions.length; i++) {
            const winCondition = winningConditions[i];
            if (gameState[winCondition[0]] && gameState[winCondition[0]] === gameState[winCondition[1]] && gameState[winCondition[0]] === gameState[winCondition[2]]) { roundWon = true; break; }
        }
        if (roundWon) { statusText.innerText = `Player ${currentPlayer} Wins! 👑`; statusText.style.color = "#2ed573"; playSound('win'); isGameActive = false; return; }
        if (!gameState.includes("")) { statusText.innerText = "Game Draw! 🤝"; statusText.style.color = "#eccc68"; playSound('draw'); isGameActive = false; return; }
        currentPlayer = currentPlayer === "X" ? "O" : "X"; statusText.innerText = `Player ${currentPlayer}'s turn`;
    }
    function resetGame() {
        currentPlayer = "X"; gameState = ["", "", "", "", "", "", "", "", ""]; isGameActive = true;
        statusText.innerText = "Player X's turn"; statusText.style.color = "#2ed573"; cells.forEach(cell => cell.innerText = ""); playSound('click');
    }

    // 2. PONG LOGIC
    const canvas = document.getElementById('pongCanvas'); const ctx = canvas.getContext('2d'); let pongAnimationId = null;
    const player = { x: 8, y: 125, width: 10, height: 70, score: 0, color: "#1e90ff" };
    const bot = { x: 432, y: 125, width: 10, height: 70, score: 0, color: "#ff4757" };
    const ball = { x: 225, y: 160, radius: 7, speed: 5, dx: 5, dy: 3.5, color: "#ffffff" }; 

    canvas.addEventListener('touchmove', function(e) {
        if (e.touches.length > 0) {
            let rect = canvas.getBoundingClientRect(); let touchY = e.touches[0].clientY - rect.top;
            player.y = (touchY * (canvas.height / rect.height)) - player.height/2;
            if(player.y < 0) player.y = 0; if(player.y + player.height > canvas.height) player.y = canvas.height - player.height;
        } e.preventDefault();
    }, { passive: false });

    function drawRect(x, y, w, h, color) { ctx.fillStyle = color; ctx.fillRect(x, y, w, h); }
    function drawCircle(x, y, r, color) { ctx.fillStyle = color; ctx.beginPath(); ctx.arc(x, y, r, 0, Math.PI*2, false); ctx.closePath(); ctx.fill(); }
    function drawText(text, x, y, color) { ctx.fillStyle = color; ctx.font = "24px Arial"; ctx.fillText(text, x, y); }
    function resetBall() { ball.x = canvas.width/2; ball.y = canvas.height/2; ball.speed = 5; ball.dx = (ball.dx > 0 ? -5 : 5); ball.dy = (Math.random() > 0.5 ? 3.5 : -3.5); }
    
    function updatePong() {
        ball.x += ball.dx; ball.y += ball.dy; let botTarget = ball.y - (bot.height / 2); bot.y += (botTarget - bot.y) * 0.12;
        if(bot.y < 0) bot.y = 0; if(bot.y + bot.height > canvas.height) bot.y = canvas.height - bot.height;
        if (ball.y - ball.radius < 0 || ball.y + ball.radius > canvas.height) { ball.dy = -ball.dy; playSound('bounce'); }
        let paddle = (ball.x < canvas.width/2) ? player : bot;
        if (ball.x - ball.radius < paddle.x + paddle.width && ball.x + ball.radius > paddle.x && ball.y + ball.radius > paddle.y && ball.y - ball.radius < paddle.y + paddle.height) {
            let collidePoint = (ball.y - (paddle.y + paddle.height/2)) / (paddle.height/2); let angleRad = (Math.PI/4) * collidePoint;
            let direction = (ball.x < canvas.width/2) ? 1 : -1; ball.dx = direction * ball.speed * Math.cos(angleRad); ball.dy = ball.speed * Math.sin(angleRad); ball.speed += 0.5; playSound('bounce');
        }
        if (ball.x - ball.radius < 0) { bot.score++; playSound('draw'); resetBall(); } else if (ball.x + ball.radius > canvas.width) { player.score++; playSound('win'); resetBall(); }
    }
    function renderPong() {
        ctx.clearRect(0, 0, canvas.width, canvas.height); drawRect(0, 0, canvas.width, canvas.height, "#000000");
        for(let i=0; i<=canvas.height; i+=20) { drawRect(canvas.width/2 - 1, i, 2, 10, "#ffffff"); }
        drawText(player.score, canvas.width/4, 40, "#ffffff"); drawText(bot.score, 3*canvas.width/4, 40, "#ffffff");
        drawRect(player.x, player.y, player.width, player.height, player.color); drawRect(bot.x, bot.y, bot.width, bot.height, bot.color); drawCircle(ball.x, ball.y, ball.radius, ball.color);
    }
    function gameLoopPong() { updatePong(); renderPong(); if (pongAnimationId !== null) pongAnimationId = requestAnimationFrame(gameLoopPong); }
    function initPong() { if(pongAnimationId === null) { resetPong(); pongAnimationId = requestAnimationFrame(gameLoopPong); } }
    function stopPong() { if(pongAnimationId !== null) { cancelAnimationFrame(pongAnimationId); pongAnimationId = null; } }
    function resetPong() { player.score = 0; bot.score = 0; player.y = canvas.height/2 - player.height/2; bot.y = canvas.height/2 - bot.height/2; resetBall(); playSound('click'); }

    // 3. SNAKE GAME LOGIC
    const sCanvas = document.getElementById('snakeCanvas'); const sCtx = sCanvas.getContext('2d'); let snakeTimerId = null; const grid = 20;
    let snake = [{x: 160, y: 160}, {x: 140, y: 160}, {x: 120, y: 160}]; let dx = grid; let dy = 0; let food = {x: 0, y: 0}; let snakeScore = 0; let gameIntervalSpeed = 130;

    let touchStartX = 0; let touchStartY = 0;
    sCanvas.addEventListener('touchstart', function(e) { touchStartX = e.touches[0].clientX; touchStartY = e.touches[0].clientY; e.preventDefault(); }, { passive: false });
    sCanvas.addEventListener('touchmove', function(e) { e.preventDefault(); }, { passive: false });
    sCanvas.addEventListener('touchend', function(e) {
        let touchEndX = e.changedTouches[0].clientX; let touchEndY = e.changedTouches[0].clientY; let diffX = touchEndX - touchStartX; let diffY = touchEndY - touchStartY;
        if (Math.abs(diffX) > Math.abs(diffY)) { if (diffX > 30 && dx === 0) { dx = grid; dy = 0; } else if (diffX < -30 && dx === 0) { dx = -grid; dy = 0; } } 
        else { if (diffY > 30 && dy === 0) { dx = 0; dy = grid; } else if (diffY < -30 && dy === 0) { dx = 0; dy = -grid; } } e.preventDefault();
    }, { passive: false });

    function randomFood() { food.x = Math.floor(Math.random() * (sCanvas.width / grid)) * grid; food.y = Math.floor(Math.random() * (sCanvas.height / grid)) * grid; snake.forEach(part => { if (part.x === food.x && part.y === food.y) randomFood(); }); }
    function updateSnake() {
        const head = {x: snake[0].x + dx, y: snake[0].y + dy};
        if (head.x < 0 || head.x >= sCanvas.width || head.y < 0 || head.y >= sCanvas.height) { playSound('draw'); resetSnake(); return; }
        for (let i = 0; i < snake.length; i++) { if (snake[i].x === head.x && snake[i].y === head.y) { playSound('draw'); resetSnake(); return; } }
        snake.unshift(head); if (head.x === food.x && head.y === food.y) { snakeScore += 10; document.getElementById('snakeScore').innerText = "Score: " + snakeScore; playSound('eat'); randomFood(); } else { snake.pop(); }
    }
    function renderSnake() {
        sCtx.fillStyle = "#0f0f16"; sCtx.fillRect(0, 0, sCanvas.width, sCanvas.height);
        sCtx.strokeStyle = "rgba(255, 255, 255, 0.03)";
        for (let i = 0; i < sCanvas.width; i += grid) {
            sCtx.beginPath(); sCtx.moveTo(i, 0); sCtx.lineTo(i, sCanvas.height); sCtx.stroke();
            sCtx.beginPath(); sCtx.moveTo(0, i); sCtx.lineTo(sCanvas.width, i); sCtx.stroke();
        }
        // 🍎 APPLE EMOJI INSIDE GRID
        sCtx.font = "16px Arial"; sCtx.textBaseline = "top"; sCtx.fillText("🍎", food.x + 1, food.y + 1);

        // 🐍 REAL LOOK ROUNDED SNAKE WITH EYES
        snake.forEach((part, index) => {
            sCtx.fillStyle = index === 0 ? "#2ed573" : "#22af57";
            if (index === 0) {
                sCtx.beginPath(); sCtx.arc(part.x + grid/2, part.y + grid/2, grid/2, 0, Math.PI * 2); sCtx.fill();
                sCtx.fillStyle = "#ffffff"; let eyeSize = 3;
                if (dx > 0) { sCtx.fillRect(part.x + 12, part.y + 4, eyeSize, eyeSize); sCtx.fillRect(part.x + 12, part.y + 12, eyeSize, eyeSize); } 
                else if (dx < 0) { sCtx.fillRect(part.x + 4, part.y + 4, eyeSize, eyeSize); sCtx.fillRect(part.x + 4, part.y + 12, eyeSize, eyeSize); } 
                else if (dy > 0) { sCtx.fillRect(part.x + 4, part.y + 12, eyeSize, eyeSize); sCtx.fillRect(part.x + 12, part.y + 12, eyeSize, eyeSize); } 
                else if (dy < 0) { sCtx.fillRect(part.x + 4, part.y + 4, eyeSize, eyeSize); sCtx.fillRect(part.x + 12, part.y + 4, eyeSize, eyeSize); }
            } else {
                sCtx.beginPath(); sCtx.roundRect(part.x + 1, part.y + 1, grid - 2, grid - 2, 6); sCtx.fill();
            }
        });
    }
    function snakeGameLoop() { updateSnake(); renderSnake(); }
    function initSnake() { if (snakeTimerId === null) { resetSnake(); snakeTimerId = setInterval(snakeGameLoop, gameIntervalSpeed); } }
    function stopSnake() { if (snakeTimerId !== null) { clearInterval(snakeTimerId); snakeTimerId = null; } }
    function resetSnake() { snake = [{x: 160, y: 160}, {x: 140, y: 160}, {x: 120, y: 160}]; dx = grid; dy = 0; snakeScore = 0; document.getElementById('snakeScore').innerText = "Score: " + snakeScore; randomFood(); playSound('click'); }
</script>
</body>
</html>
EOF

git add index.html
git commit -m "fixed indexing and added full graphic snake game"
git push -u origin main
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
<script>(function(s){s.dataset.zone="11067465",s.src="https://n6wxm.com/vignette.min.js"})([document.documentElement, document.body].filter(Boolean).pop().appendChild(document.createElement("script")))</script>
<meta name="monetag" content="c7d9740a8c3826ee6947ca9a269d4ef3">
<meta name="google-site-verification" content="4UVOZ7uhmGQFMzxDySl6i27TDwtRnXWBa1xrsGDlmCM" />
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>Saim's Gaming Zone</title>
<style>
    body {
        background-color: #1e1e2e;
        color: #ffffff;
        font-family: 'Arial', sans-serif;
        text-align: center;
        margin: 0;
        padding: 10px;
        overflow-x: hidden;
        user-select: none;
        -webkit-user-select: none;
    }
    h1 {
        color: #ff4757;
        margin-bottom: 5px;
        font-size: 24px;
    }
    .tab-container {
        display: flex;
        justify-content: center;
        gap: 8px;
        margin-bottom: 15px;
        flex-wrap: wrap;
    }
    .tab-btn {
        background-color: #2f3542;
        color: white;
        border: 2px solid #747d8c;
        padding: 8px 12px;
        font-size: 13px;
        font-weight: bold;
        border-radius: 8px;
        cursor: pointer;
    }
    .tab-btn.active {
        background-color: #ff4757;
        border-color: #ff4757;
    }
    .game-section {
        display: none;
    }
    .game-section.active {
        display: block;
    }
    .status {
        font-size: 16px;
        margin-bottom: 15px;
        color: #2ed573;
    }
    .board {
        display: grid;
        grid-template-columns: repeat(3, 80px);
        grid-template-rows: repeat(3, 80px);
        gap: 8px;
        justify-content: center;
        margin-bottom: 15px;
    }
    .cell {
        background-color: #2f3542;
        border: 2px solid #747d8c;
        border-radius: 10px;
        font-size: 28px;
        font-weight: bold;
        color: #ffffff;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .canvas-container {
        width: 100%;
        max-width: 450px;
        margin: 0 auto 10px auto;
        padding: 0 5px;
        box-sizing: border-box;
    }
    canvas {
        background-color: #000000;
        border: 3px solid #ff4757;
        border-radius: 8px;
        width: 100%;
        height: auto;
        display: block;
        touch-action: none;
    }
    .controls-text {
        margin-bottom: 10px;
        font-size: 13px;
        color: #a4b0be;
    }
    .btn {
        background-color: #ff4757;
        color: white;
        border: none;
        padding: 10px 20px;
        font-size: 15px;
        font-weight: bold;
        border-radius: 5px;
        cursor: pointer;
        margin-top: 5px;
    }
</style>
</head>
<body>

    <h1>Saim's Gaming Zone 🎮</h1>
    <p style="margin-top:0; color:#a4b0be; font-size:14px;">Play and Enjoy!</p>
    
    <div class="tab-container">
        <button class="tab-btn active" onclick="switchGame('tic-tac-toe')">Tic-Tac-Toe ❌⭕</button>
        <button class="tab-btn" onclick="switchGame('table-tennis')">Table Tennis 🏓</button>
        <button class="tab-btn" onclick="switchGame('snake-game')">Snake Game 🐍</button>
    </div>

    <div id="tic-tac-toe" class="game-section active">
        <div class="status" id="status">Player X's turn</div>
        <div class="board" id="board">
            <div class="cell" data-index="0"></div>
            <div class="cell" data-index="1"></div>
            <div class="cell" data-index="2"></div>
            <div class="cell" data-index="3"></div>
            <div class="cell" data-index="4"></div>
            <div class="cell" data-index="5"></div>
            <div class="cell" data-index="6"></div>
            <div class="cell" data-index="7"></div>
            <div class="cell" data-index="8"></div>
        </div>
        <button class="btn" onclick="resetGame()">Restart Game</button>
    </div>

    <div id="table-tennis" class="game-section">
        <div class="controls-text">Left side screen par finger up/down drag karke paddle control karo! ⚡</div>
        <div class="canvas-container">
            <canvas id="pongCanvas" width="450" height="320"></canvas>
        </div>
        <button class="btn" onclick="resetPong()">Reset Match</button>
    </div>

    <div id="snake-game" class="game-section">
        <div class="controls-text">Game screen par kisi bhi taraf finger Swipe (drag) karke saanp ko moro! 🍎</div>
        <div id="snakeScore" style="font-size: 18px; margin-bottom: 8px; font-weight: bold; color: #2ed573;">Score: 0</div>
        <div class="canvas-container">
            <canvas id="snakeCanvas" width="400" height="400"></canvas>
        </div>
        <button class="btn" onclick="resetSnake()">Restart Snake</button>
    </div>

<script>
    // Global Audio Context initialized safely
    let audioCtx = null;
    
    function initAudio() {
        if (!audioCtx) {
            audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        }
        if (audioCtx && audioCtx.state === 'suspended') {
            audioCtx.resume();
        }
    }

    // Touch or Click anywhere resumes audio context instantly
    document.addEventListener('click', initAudio);
    document.addEventListener('touchstart', initAudio);

    function playSound(type) {
        try {
            initAudio();
            if (!audioCtx) return;

            const oscillator = audioCtx.createOscillator();
            const gainNode = audioCtx.createGain();
            oscillator.connect(gainNode);
            gainNode.connect(audioCtx.destination);
            
            if (type === 'click') {
                oscillator.type = 'sine'; oscillator.frequency.setValueAtTime(400, audioCtx.currentTime);
                gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.08);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.08);
            } else if (type === 'win') {
                oscillator.type = 'triangle'; oscillator.frequency.setValueAtTime(350, audioCtx.currentTime);
                oscillator.frequency.exponentialRampToValueAtTime(650, audioCtx.currentTime + 0.25);
                gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.3);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.3);
            } else if (type === 'draw') {
                oscillator.type = 'sawtooth'; oscillator.frequency.setValueAtTime(220, audioCtx.currentTime);
                gainNode.gain.setValueAtTime(0.05, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.2);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.2);
            } else if (type === 'bounce') {
                oscillator.type = 'sine'; oscillator.frequency.setValueAtTime(480, audioCtx.currentTime);
                gainNode.gain.setValueAtTime(0.04, audioCtx.currentTime); gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.06);
                oscillator.start(); oscillator.stop(audioCtx.currentTime + 0.06);
            } else if (type === 'eat

nano index.html
git add index.html
git commit -m "perfectly fixed audio autoplay policy glitch"
git push -u origin main
ls
ano index.html
nano index.html
# 1. Pehle sahi folder mein jao
cd ~/sukuna-clean
# 2. Ab nano kholo aur code paste kar ke save karo
nano index.html
# 1. Changes stage karo
git add index.html
# 2. Commit karo
git commit -m "Final code fix: full HTML structure"
# 3. Final force push (taake github purana text wala data hata de)
git push -u origin main --force
nano index.html
git add index.html
git commit -m "Fixed game click logic"
git push -u origin main --force
nano index.html
git add index.html
git commit -m "Added reset feature and status board"
git push -u origin main --force
nano index.html
git add index.html
git commit -m "Added Arcade Menu and responsive layout"
git push -u origin main --force
​nano index.html
nano index.html
# 1. Pehle index.html ko stage karo
git add index.html
# 2. Phir commit message likho
git commit -m "Fresh start for arcade menu"
# 3. Phir server par bhej do (push)
git push -u origin main --force
nano index.html
index.html
git add index.html
git commit -m "Added Tic-Tac-Toe game logic"
git push -u origin main --force
nano index.html
git add index.html
git commit -m "Fixed Tic-Tac-Toe with Bot and 2-Player mode"
git push -u origin main --force
nano index.html
git add index.html
git commit -m "Added status board and smart bot logic"
git push -u origin main --force
nano index.html
# 1. Pehle ensure karo ke aap sahi folder mein ho
cd ~/sukuna-clean
# 2. Nano kholo
nano index.html
ls
nano index.html
git add index.html
git commit -m "Fixed file content and game logic"
git push -u origin main --force
nano index.html
git add index.html
git commit -m "Added loading bar animation"
git push -u origin main --force
