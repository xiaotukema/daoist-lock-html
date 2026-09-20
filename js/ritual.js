(() => {
  'use strict';
  const $ = id => document.getElementById(id);
  const dialog = $('ritual-dialog');
  const fortunes = [
    ['守静', '风过竹有声，风止竹还静。', '给自己留一段不被打扰的时间。先安顿心绪，再回应眼前的事。'],
    ['知止', '行至水穷处，停步看云生。', '今天不必把每件事都推向结果。辨清可做与不可做，留一点余地。'],
    ['日新', '庭前一叶落，阶下又生青。', '整理一处小角落，放下一件旧烦恼。新意常从细小的改变开始。'],
    ['和光', '月照千江水，清辉不问名。', '少一分争辩，多一分倾听。温和地表达，也清楚地守住自己的边界。'],
    ['徐行', '山路随云转，清泉伴步长。', '选定一件值得做的事，慢慢把它做好。今天的步子，可以从容一些。'],
    ['返照', '拂去心头尘，方知明镜在。', '暂放外界的声音，问问自己真正看重什么。把精力留给那个答案。'],
    ['清简', '一室容清风，半窗留月色。', '为生活做一次减法。少一个多余的安排，多一点自在的空白。'],
    ['随时', '花开自有时，静候雨初晴。', '照料好今天能照料的事。尚未有答案的，允许它再生长一会儿。']
  ];
  const key = 'xuanxu.daily-ritual.v1';
  const localDate = () => {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  };
  let record = {};
  let mode = 'fortune';
  let busy = false;
  let replayingIncense = false;
  let timer;
  let operation = 0;
  let storageAvailable = true;
  function load() {
    try {
      const data = JSON.parse(localStorage.getItem(key) || '{}');
      if (data && data.date === localDate()) {
        record = { date: data.date, incense: data.incense === true, fortune: Number.isInteger(data.fortune) && data.fortune >= 0 && data.fortune < fortunes.length ? data.fortune : null };
        return;
      }
    } catch { storageAvailable = false; }
    if (record.date !== localDate()) record = { date: localDate(), fortune: null, incense: false };
  }
  function save() {
    try { localStorage.setItem(key, JSON.stringify(record)); }
    catch { storageAvailable = false; }
  }
  function update() {
    $('fortune-state').textContent = record.fortune === null ? '静心 · 求一签' : '已抽签 · 重读';
    $('incense-state').textContent = record.incense ? '已上香 · 静坐' : '一炷 · 寄心愿';
    $('storage-note').textContent = storageAvailable ? '' : '当前浏览器无法保存记录，本次结果仅在当前页面保留。';
  }
  function present() {
    update();
    dialog.dataset.mode = mode;
    $('ritual-date').textContent = record.date.replaceAll('-', ' . ');
    $('ritual-art').className = `ritual-art ${mode}`;
    $('fortune-result').hidden = true;
    $('ritual-action').disabled = false;
    $('place-incense').hidden = mode !== 'incense' || (record.incense && !replayingIncense);
    $('place-incense').disabled = false;
    $('replay-incense').hidden = mode !== 'incense' || !record.incense || replayingIncense;
    if (mode === 'fortune') {
      const drawn = record.fortune !== null;
      $('ritual-title').textContent = drawn ? '今日一签，与你相逢。' : '静心，求一签。';
      $('ritual-subtitle').textContent = drawn ? '不急着寻找答案，先听听自己的心。' : '收拢思绪，默念心中所问。';
      $('ritual-message').textContent = drawn ? '今日签文已留存，随时可回来重读。' : '一日一签，让此刻成为今天的起点。';
      $('ritual-action').textContent = drawn ? '收下今日签' : '静心抽签';
      if (drawn) {
        const [title, poem, reading] = fortunes[record.fortune];
        $('ritual-art').classList.add('revealed');
        $('fortune-result').hidden = false;
        $('fortune-number').textContent = `第 ${String(record.fortune + 1).padStart(2, '0')} 签 · 今日心签`;
        $('fortune-title').textContent = title;
        $('fortune-poem').textContent = poem;
        $('fortune-reading').textContent = reading;
      }
    } else {
      const offered = record.incense && !replayingIncense;
      $('ritual-title').textContent = '';
      $('ritual-subtitle').textContent = '';
      $('ritual-message').textContent = '';
      $('ritual-action').textContent = offered ? '带着清静，回到日常' : '将香插入香炉';
      $('ritual-art').classList.add(offered ? 'lit' : 'awaiting-incense');
    }
  }
  function cancelPending() {
    clearTimeout(timer);
    operation++;
    busy = false;
  }
  function refreshDay() {
    const previous = record.date;
    load();
    if (previous !== record.date) {
      cancelPending();
      if (dialog.open) present();
    }
    update();
  }
  function open(type) {
    refreshDay();
    replayingIncense = false;
    mode = type;
    present();
    dialog.showModal();
    $('ritual-action').focus();
  }
  $('open-fortune').addEventListener('click', () => open('fortune'));
  $('open-incense').addEventListener('click', () => open('incense'));
  $('close-ritual').addEventListener('click', () => dialog.close());
  dialog.addEventListener('close', cancelPending);
  $('place-incense').addEventListener('click', () => $('ritual-action').click());
  $('replay-incense').addEventListener('click', () => {
    refreshDay();
    replayingIncense = true;
    present();
    $('ritual-action').focus();
  });
  $('ritual-action').addEventListener('click', () => {
    refreshDay();
    if (busy) return;
    if ((mode === 'fortune' && record.fortune !== null) || (mode === 'incense' && record.incense && !replayingIncense)) { dialog.close(); return; }
    busy = true;
    const current = ++operation;
    const date = record.date;
    const selectedMode = mode;
    $('ritual-action').disabled = true;
    $('place-incense').disabled = true;
    $('ritual-action').textContent = mode === 'fortune' ? '签正在与你相逢…' : '正将心香安放入炉…';
    $('ritual-message').textContent = mode === 'fortune' ? '静候片刻，让纷扰沉淀。' : '香入炉，心归静。';
    $('ritual-art').classList.remove('awaiting-incense');
    $('ritual-art').classList.add(mode === 'fortune' ? 'drawing' : 'placing-incense');
    timer = setTimeout(() => {
      if (current !== operation || !dialog.open) return;
      if (date !== localDate()) { refreshDay(); return; }
      load();
      if (selectedMode === 'fortune' && record.fortune === null) {
        const random = new Uint32Array(1);
        crypto.getRandomValues(random);
        record.fortune = random[0] % fortunes.length;
      }
      if (selectedMode === 'incense') record.incense = true;
      save();
      busy = false;
      replayingIncense = false;
      present();
    }, matchMedia('(prefers-reduced-motion: reduce)').matches ? 100 : 2200);
  });
  window.addEventListener('focus', refreshDay);
  window.addEventListener('storage', event => { if (event.key === key) { cancelPending(); load(); update(); if (dialog.open) present(); } });
  document.addEventListener('visibilitychange', () => { if (!document.hidden) refreshDay(); });
  setInterval(refreshDay, 30000);
  load();
  update();
})();
