(() => {
  'use strict';
  const days = window.LOCK_DAYS;
  const $ = id => document.getElementById(id);
  let index = 0;
  let transitionTimer;
  let feedbackTimer;
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const weekday = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
  const dots = days.map((day, i) => {
    const button = document.createElement('button');
    button.type = 'button';
    button.setAttribute('aria-label', `查看 ${day.date} 样本`);
    button.addEventListener('click', () => select(i));
    $('pagination').append(button);
    return button;
  });
  function render() {
    const day = days[index];
    const [year, month, date] = day.date.split('-').map(Number);
    $('lock-date').textContent = `${month}月${date}日 ${weekday[new Date(year, month - 1, date).getDay()]}`;
    $('suitable').textContent = day.suitable;
    $('avoid').textContent = day.avoid;
    $('verse').replaceChildren(...(day.verse.match(/[^，。；]+[，。；]?/g) || [day.verse]).map(line => {
      const span = document.createElement('span');
      span.textContent = line;
      return span;
    }));
    $('verse-source').textContent = day.source;
    $('verse-credit').textContent = day.source;
    $('sample-date').textContent = day.date.slice(5).replace('-', '.');
    $('sample-topic').textContent = day.topic;
    dots.forEach((dot, i) => dot.setAttribute('aria-current', String(i === index)));
    $('widget-wrap').classList.remove('changing');
  }
  function select(next) {
    index = (next + days.length) % days.length;
    clearTimeout(transitionTimer);
    if (reduceMotion) { render(); return; }
    $('widget-wrap').classList.add('changing');
    transitionTimer = setTimeout(render, 160);
  }
  $('previous').addEventListener('click', () => select(index - 1));
  $('next').addEventListener('click', () => select(index + 1));
  document.addEventListener('keydown', event => {
    if (document.querySelector('dialog[open]')) return;
    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      event.preventDefault();
      select(index + (event.key === 'ArrowRight' ? 1 : -1));
    }
  });
  let start = null;
  $('screen').addEventListener('pointerdown', event => {
    if (!event.isPrimary || event.button !== 0 || event.target.closest('button')) return;
    start = { x: event.clientX, y: event.clientY, id: event.pointerId };
    $('screen').setPointerCapture(event.pointerId);
  });
  $('screen').addEventListener('pointerup', event => {
    if (!start || event.pointerId !== start.id) return;
    const dx = event.clientX - start.x;
    const dy = event.clientY - start.y;
    start = null;
    if (Math.abs(dx) > 40 && Math.abs(dx) > Math.abs(dy) * 1.3) select(index + (dx < 0 ? 1 : -1));
  });
  $('screen').addEventListener('pointercancel', () => { start = null; });
  function feedback(message) {
    clearTimeout(feedbackTimer);
    $('phone-feedback').textContent = message;
    feedbackTimer = setTimeout(() => { $('phone-feedback').textContent = ''; }, 2200);
  }
  $('flashlight').addEventListener('click', () => {
    const enabled = $('screen').classList.toggle('flash-on');
    $('flashlight').setAttribute('aria-pressed', String(enabled));
    feedback(enabled ? '手电筒光效已开启' : '手电筒光效已关闭');
  });
  $('camera').addEventListener('click', () => feedback('相机仅作锁屏演示'));
  render();
})();
