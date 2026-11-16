// Player status: [HEALTH pill + hunger line] [ARMOUR pill + thirst line] [contextual orbs]
(() => {
    const icon = window.D11Icons;
    const root = document.getElementById('status');

    const LABEL = { health: 'Vida', armor: 'Colete' };
    // stress is the other way round: alert at 75 and up; the rest at 20 and below.
    const isLow = (key, v) => key === 'stress' ? v >= 75 : v <= 20;
    // Contextual orbs only show when they matter.
    const CONTEXTUAL = [
        ['stress', v => v >= 5],
        ['energy', v => v < 100],
        ['oxygen', v => v < 100],
    ];

    root.innerHTML = `
        <div class="st">
            <div class="pg" data-k="health"></div>
            <div class="pg" data-k="armor"></div>
            <div class="orbs"></div>
        </div>`;
    const orbsEl = root.querySelector('.orbs');

    // The pill is the bar: the light fill shrinks from right to left.
    function group(key, subKey, s) {
        const v = s[key], crit = key === 'health' && v <= 25;
        const sv = s[subKey], subLow = isLow(subKey, sv);
        return `
            <div class="pill${crit ? ' crit low' : ''}${v <= 0 ? ' empty' : ''}">
                <span class="fill" style="transform:scaleX(${v / 100})"></span>
                <span class="lab"><span class="bdg">${icon(key)}</span>${D11Hud.T(LABEL[key])}</span>
                <span class="num">${v}</span>
            </div>
            <span class="sub${subLow ? ' low' : ''}">
                <span class="meter"><b style="transform:scaleX(${sv / 100})"></b></span>${icon(subKey)}
            </span>`;
    }

    let shown = new Set();
    function orbs(s) {
        const list = CONTEXTUAL.filter(([k, when]) => when(s[k])).map(([k]) => k);
        orbsEl.innerHTML = list.map(k => `
            <span class="orb${isLow(k, s[k]) ? ' low' : ''}${shown.has(k) ? '' : ' enter'}">
                <span class="lvl" style="height:${s[k]}%"></span>${icon(k)}
            </span>`).join('');
        shown = new Set(list);
    }

    D11Hud.on('status', s => {
        if (!s) return;
        root.querySelector('[data-k="health"]').innerHTML = group('health', 'hunger', s);
        root.querySelector('[data-k="armor"]').innerHTML = group('armor', 'thirst', s);
        orbs(s);
    });
})();
