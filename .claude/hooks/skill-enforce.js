#!/usr/bin/env node
// UserPromptSubmit hook: when the prompt contains a workflow trigger phrase,
// inject a reminder so the matching project skill actually fires (it gets
// skipped sometimes when relying on skill descriptions alone).
// ponytail: plain substring match, no NLP. Add phrases to the table below if a
// trigger gets missed; reach for fuzzy matching only if substrings prove flaky.

const SKILLS = [
  { skill: 'start-work', triggers: ['이슈 시작', '작업 시작', 'start issue', 'start-work'] },
  { skill: 'ship',       triggers: ['pr 올려', 'pr올려', '출고', 'ship', '머지 준비'] },
  { skill: 'verify-loop', triggers: ['검증', 'verify', 'ci 통과'] },
  { skill: 'work-loop',  triggers: ['작업 루프', 'work loop', 'work-loop'] },
  { skill: 'full-loop',  triggers: ['전체 루프', 'full loop', 'full-loop', '이슈 끝까지'] },
];

let raw = '';
process.stdin.on('data', (c) => (raw += c));
process.stdin.on('end', () => {
  let prompt = '';
  try { prompt = (JSON.parse(raw).prompt || ''); } catch { prompt = raw; }
  const p = prompt.toLowerCase();

  const hits = SKILLS.filter((s) => s.triggers.some((t) => p.includes(t.toLowerCase())));
  if (hits.length === 0) process.exit(0);

  const names = hits.map((h) => h.skill);
  console.log(
    `[MAGIC KEYWORD: ${names.join(', ')}] 워크플로 트리거 감지됨. ` +
    `응답하기 전에 반드시 해당 프로젝트 스킬을 먼저 호출하세요: ` +
    names.map((n) => `/${n}`).join(', ') + '.'
  );
  process.exit(0);
});
