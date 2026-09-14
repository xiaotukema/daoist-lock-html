/* 设计用民俗宜忌样本，不代表对应日期的真实黄历。经文为《太上老君说常清静经》节录。 */
window.LOCK_DAYS = [
  { date: '2026-09-14', topic: '日用 · 清静', suitable: '焚香 · 洒扫', avoid: '喧哗 · 争讼', verse: '常能遣其欲，而心自静。' },
  { date: '2026-09-15', topic: '日用 · 诵经', suitable: '诵经 · 净室', avoid: '口舌 · 躁进', verse: '澄其心，而神自清。' },
  { date: '2026-09-16', topic: '日用 · 守静', suitable: '静坐 · 整衣', avoid: '争竞 · 妄言', verse: '自然六欲不生，三毒消灭。' },
  { date: '2026-09-17', topic: '日用 · 洒扫', suitable: '洒扫 · 敬香', avoid: '怠慢 · 喧闹', verse: '人能常清静，天地悉皆归。' },
  { date: '2026-09-18', topic: '日用 · 清供', suitable: '清供 · 读经', avoid: '奢费 · 争执', verse: '清者浊之源，动者静之基。' },
  { date: '2026-09-19', topic: '日用 · 省心', suitable: '省心 · 沐浴', avoid: '妄语 · 嗔怒', verse: '真常应物，真常得性。' },
  { date: '2026-09-20', topic: '日用 · 习诵', suitable: '习诵 · 整理', avoid: '纷争 · 扰静', verse: '常应常静，常清静矣。' }
].map(day => ({ ...day, source: '《太上老君说常清静经》' }));
