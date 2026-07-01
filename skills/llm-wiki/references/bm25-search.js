#!/usr/bin/env node
/**
 * BM25 搜索 — 纯 Node.js，零外部依赖
 * 用法: node bm25-search.js "查询内容"
 *       node bm25-search.js --reindex
 */

const fs = require('fs');
const path = require('path');

const WIKI_PATH = process.env.WIKI_PATH || path.join(process.env.HOME || process.env.USERPROFILE, 'wiki');
const DB_PATH = path.join(WIKI_PATH, '.wiki-index.json');

const EXCLUDE = new Set(['raw', '.obsidian', '_archive', '.git', 'node_modules', 'queries']);

// --- BM25 参数 ---
const K1 = 1.5;
const B = 0.75;

// --- 分词 ---
function tokenize(text) {
  // 去掉 frontmatter
  text = text.replace(/^---[\s\S]*?---\n?/, '');
  // 去掉 wikilink 语法，保留文本
  text = text.replace(/\[\[([^\]|]*?)(?:\|[^\]]*?)?\]\]/g, '$1');
  // 去掉引用标记
  text = text.replace(/\^\[[^\]]*\]/g, '');
  // 中英文混合分词：英文按空格，中文按字/词
  const tokens = [];
  // 英文单词
  const enMatches = text.match(/[a-zA-Z][a-zA-Z0-9_-]*/g) || [];
  tokens.push(...enMatches.map(w => w.toLowerCase()));
  // 中文：bigram + unigram
  const zhMatches = text.match(/[\u4e00-\u9fff]+/g) || [];
  for (const seg of zhMatches) {
    for (let i = 0; i < seg.length; i++) {
      tokens.push(seg[i]); // unigram
      if (i + 1 < seg.length) tokens.push(seg[i] + seg[i + 1]); // bigram
    }
  }
  return tokens.filter(t => t.length > 1);
}

// --- 收集 wiki 文件 ---
function collectFiles(dir, base) {
  const files = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (EXCLUDE.has(entry.name)) continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...collectFiles(full, base));
    } else if (entry.name.endsWith('.md')) {
      const rel = path.relative(base, full);
      try {
        const content = fs.readFileSync(full, 'utf-8');
        // 提取 frontmatter
        let title = '', kind = '', tags = '';
        const fmMatch = content.match(/^---\n([\s\S]*?)\n---/);
        if (fmMatch) {
          const fm = fmMatch[1];
          const t = fm.match(/^title:\s*(.+)$/m);
          if (t) title = t[1].trim();
          const k = fm.match(/^kind:\s*(.+)$/m);
          if (k) kind = k[1].trim();
          const tg = fm.match(/^tags:\s*(.+)$/m);
          if (tg) tags = tg[1].trim();
        }
        if (!title) title = entry.name.replace('.md', '');
        files.push({ path: rel, title, kind, tags, content, tokens: tokenize(content) });
      } catch (e) { /* skip unreadable */ }
    }
  }
  return files;
}

// --- 构建 BM25 索引 ---
function buildIndex(files) {
  const N = files.length;
  const avgdl = files.reduce((s, f) => s + f.tokens.length, 0) / N;

  // 计算每个词的 DF
  const df = {};
  for (const f of files) {
    const seen = new Set(f.tokens);
    for (const t of seen) df[t] = (df[t] || 0) + 1;
  }

  // 为每个文件计算 TF
  const docs = files.map(f => {
    const tf = {};
    for (const t of f.tokens) tf[t] = (tf[t] || 0) + 1;
    return { path: f.path, title: f.title, kind: f.kind, tags: f.tags, tf, dl: f.tokens.length };
  });

  return { N, avgdl, df, docs };
}

// --- BM25 打分 ---
function search(index, queryTokens) {
  const { N, avgdl, df, docs } = index;
  const scores = docs.map(doc => {
    let score = 0;
    const tf = doc.tf;
    for (const q of queryTokens) {
      const f = tf[q] || 0;
      if (f === 0) continue;
      const n = df[q] || 0;
      const idf = Math.log((N - n + 0.5) / (n + 0.5) + 1);
      const tfNorm = (f * (K1 + 1)) / (f + K1 * (1 - B + B * doc.dl / avgdl));
      score += idf * tfNorm;
    }
    return { ...doc, score };
  });

  return scores
    .filter(s => s.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 10);
}

// --- 主逻辑 ---
const arg = process.argv[2];

if (!arg || arg === '--help' || arg === '-h') {
  console.log('用法:');
  console.log('  node bm25-search.js "查询内容"     搜索 wiki');
  console.log('  node bm25-search.js --reindex      重建索引');
  console.log('  node bm25-search.js --help         显示帮助');
  console.log('');
  console.log('环境变量:');
  console.log('  WIKI_PATH    wiki 目录路径（默认 ~/wiki）');
  process.exit(arg ? 0 : 1);
}

if (arg === '--reindex') {
  console.log(`重建索引: ${WIKI_PATH}`);
  const files = collectFiles(WIKI_PATH, WIKI_PATH);
  const index = buildIndex(files);
  // 保存索引（不含 content 和 tokens，节省空间）
  const saveData = { ...index, docs: index.docs.map(({ tf, dl, ...rest }) => ({ ...rest })) };
  // 但搜索时需要 df 和 avgdl，所以我们保存完整索引
  fs.writeFileSync(DB_PATH, JSON.stringify(index));
  console.log(`索引完成: ${files.length} 个页面`);
  process.exit(0);
}

// 搜索
if (!fs.existsSync(DB_PATH)) {
  console.log('索引不存在，先重建...');
  const files = collectFiles(WIKI_PATH, WIKI_PATH);
  const index = buildIndex(files);
  fs.writeFileSync(DB_PATH, JSON.stringify(index));
  console.log(`索引完成: ${files.length} 个页面\n`);
}

const index = JSON.parse(fs.readFileSync(DB_PATH, 'utf-8'));
const queryTokens = tokenize(arg);
const results = search(index, queryTokens);

console.log(`查询: ${arg}`);
console.log(`结果: ${results.length} 个页面\n`);
results.forEach((r, i) => {
  console.log(`  ${i + 1}. [${r.score.toFixed(2)}] ${r.path}`);
  if (r.title) console.log(`     ${r.title}${r.kind ? ' (' + r.kind + ')' : ''}`);
});
