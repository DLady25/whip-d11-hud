// The ring over WHIP's minimap: a band fading outwards, a compass that turns with the camera, the heading in degrees
// below it, and area and street under the ring. The map itself is WHIP's.
(() => {
    const root = document.getElementById('radar');
    const DIRECTIONS = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
    const OUTER = 127, BAND = 19, FADE = 7, MAP = OUTER - BAND + 2;
    const ticks = [], labels = [];
    for (let degree = 0; degree < 360; degree += 15) {
        const major = degree % 45 === 0;
        const angle = (degree - 90) * Math.PI / 180, cos = Math.cos(angle), sin = Math.sin(angle);
        const start = MAP + 2, end = start + (major ? 5 : 4.5);
        ticks.push(`<line class="${major ? 'major' : ''}${degree === 0 ? ' north' : ''}" x1="${128 + cos * start}" y1="${128 + sin * start}" x2="${128 + cos * end}" y2="${128 + sin * end}"/>`);
        if (major) {
            const r = MAP + BAND * .7, x = 128 + cos * r, y = 128 + sin * r;
            labels.push(`<text data-d="${DIRECTIONS[degree / 45]}" class="${degree % 90 ? 'inter' : 'card'}${degree === 0 ? ' north' : ''}" data-x="${x}" data-y="${y}" x="${x}" y="${y}">${DIRECTIONS[degree / 45]}</text>`);
        }
    }
    root.hidden = true;
    root.innerHTML = `<svg class="r-ring" viewBox="0 0 256 256" aria-hidden="true">
        <defs><radialGradient id="r-fade" gradientUnits="userSpaceOnUse" cx="128" cy="128" r="${OUTER}">
            <stop offset="${(OUTER - FADE) / OUTER}" stop-color="#101419" stop-opacity="1"/>
            <stop offset="1" stop-color="#101419" stop-opacity="0"/></radialGradient></defs>
        <circle class="r-band" cx="128" cy="128" r="${OUTER - BAND / 2}" stroke-width="${BAND}"/>
        <circle class="r-edge" cx="128" cy="128" r="${OUTER - BAND}"/>
        <g class="r-dial">${ticks.join('')}${labels.join('')}</g>
        <path class="r-pointer" d="M128 ${BAND + 9}l-6-9h12z"/>
    </svg>
    <div class="r-deg"><span></span><i></i></div>
    <div class="r-under"><span></span><span></span></div>`;
    const dial = root.querySelector('.r-dial');
    const letters = [...dial.querySelectorAll('text')];
    const degrees = root.querySelector('.r-deg span');
    const direction = root.querySelector('.r-deg i');
    const [area, street] = root.querySelectorAll('.r-under span');
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
    const normalize = value => ((value % 360) + 360) % 360;
    let current = 0, target = 0, frame = 0, previousTime = 0;

    function draw() {
        dial.setAttribute('transform', `rotate(${-current} 128 128)`);
        for (const letter of letters) letter.setAttribute('transform', `rotate(${current} ${letter.dataset.x} ${letter.dataset.y})`);
    }
    function animate(time) {
        frame = 0;
        const delta = normalize(target - current + 180) - 180;
        const elapsed = Math.max(0, time - previousTime);
        previousTime = time;
        current = Math.abs(delta) < .02 || reducedMotion.matches ? target : normalize(current + delta * (1 - Math.exp(-elapsed / 35)));
        draw();
        if (current !== target && !root.hidden) frame = requestAnimationFrame(animate);
    }
    function sync() {
        if (root.hidden) {
            cancelAnimationFrame(frame);
            frame = 0;
            current = target;
            draw();
        } else if (!frame && current !== target) {
            previousTime = performance.now();
            frame = requestAnimationFrame(animate);
        }
    }
    const relabel = () => letters.forEach(t => { t.textContent = D11Hud.T(t.dataset.d); });
    D11Hud.on('locale', relabel);
    relabel();
    D11Hud.on('heading', value => {
        if (!Number.isFinite(value)) return;
        target = normalize(value);
        degrees.textContent = `${String(Math.round(target) % 360).padStart(3, '0')}°`;
        direction.textContent = D11Hud.T(DIRECTIONS[Math.floor((target + 22.5) / 45) % 8]);
        sync();
    });
    D11Hud.on('radar', show => { root.hidden = show !== true; sync(); });
    D11Hud.on('location', loc => {
        if (!loc) return;
        street.textContent = loc.street || '';
        area.textContent = loc.area && loc.area !== 'NULL' ? loc.area : '';
    });
    draw();
})();
