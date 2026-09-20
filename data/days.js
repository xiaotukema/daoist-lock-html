/* 设计用民俗宜忌样本，不代表对应日期的真实黄历。经文节录自《道德经》与《太上老君说常清静经》，标点为展示所加。 */
window.LOCK_DAYS = [
  { date: '2026-09-14', topic: '日用 · 清静', suitable: '焚香 · 洒扫', avoid: '喧哗 · 争讼', verse: '常能遣其欲，而心自静。' },
  { date: '2026-09-15', topic: '日用 · 诵经', suitable: '诵经 · 净室', avoid: '口舌 · 躁进', verse: '上善若水，水善利万物而不争。', source: '《道德经》第八章' },
  { date: '2026-09-16', topic: '日用 · 守静', suitable: '静坐 · 整衣', avoid: '争竞 · 妄言', verse: '致虚极，守静笃。', source: '《道德经》第十六章' },
  { date: '2026-09-17', topic: '日用 · 洒扫', suitable: '洒扫 · 敬香', avoid: '怠慢 · 喧闹', verse: '人能常清静，天地悉皆归。' },
  { date: '2026-09-18', topic: '日用 · 清供', suitable: '清供 · 读经', avoid: '奢费 · 争执', verse: '澄其心，而神自清。' },
  { date: '2026-09-19', topic: '日用 · 省心', suitable: '省心 · 沐浴', avoid: '妄语 · 嗔怒', verse: '知人者智，自知者明。', source: '《道德经》第三十三章' },
  { date: '2026-09-20', topic: '日用 · 习诵', suitable: '习诵 · 整理', avoid: '纷争 · 扰静', verse: '常应常静，常清静矣。' }
].map(day => ({ source: '《太上老君说常清静经》', ...day }));
