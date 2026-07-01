#!/usr/bin/env node
/**
 * mimo-wiki 安装脚本
 * 用法:
 *   npx mimo-wiki              安装到当前目录
 *   npx mimo-wiki --global     安装到全局 ~/.mimocode
 *   npx mimo-wiki --dir <path> 安装到指定目录
 *   npx mimo-wiki --help       显示帮助
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const REPO = 'fenzel999/mimo-wiki';
const BRANCH = 'master';
const BASE_URL = `https://raw.githubusercontent.com/${REPO}/${BRANCH}`;

const FILES = [
  { src: 'AGENTS.md', dest: 'AGENTS.md' },
  { src: 'skills/llm-wiki/SKILL.md', dest: 'skills/llm-wiki/SKILL.md' },
  { src: 'skills/llm-wiki/templates/schema-template.md', dest: 'skills/llm-wiki/templates/schema-template.md' },
  { src: 'skills/llm-wiki/templates/index-template.md', dest: 'skills/llm-wiki/templates/index-template.md' },
  { src: 'skills/llm-wiki/templates/log-template.md', dest: 'skills/llm-wiki/templates/log-template.md' },
  { src: 'skills/llm-wiki/references/bm25-search.js', dest: 'skills/llm-wiki/references/bm25-search.js' },
  { src: 'skills/llm-wiki/references/bm25.md', dest: 'skills/llm-wiki/references/bm25.md' },
  { src: 'skills/llm-wiki/references/page-types.md', dest: 'skills/llm-wiki/references/page-types.md' },
  { src: 'skills/llm-wiki/references/citations.md', dest: 'skills/llm-wiki/references/citations.md' },
];

function download(url, retries = 3) {
  return new Promise((resolve, reject) => {
    const attempt = (n) => {
      https.get(url, { headers: { 'User-Agent': 'mimo-wiki-installer' } }, (res) => {
        if (res.statusCode === 302 || res.statusCode === 301) {
          return download(res.headers.location, n).then(resolve).catch(reject);
        }
        if (res.statusCode !== 200) {
          if (n > 1) return setTimeout(() => attempt(n - 1), 1000);
          return reject(new Error(`HTTP ${res.statusCode}`));
        }
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => resolve(data));
        res.on('error', (err) => {
          if (n > 1) return setTimeout(() => attempt(n - 1), 1000);
          reject(err);
        });
      }).on('error', (err) => {
        if (n > 1) return setTimeout(() => attempt(n - 1), 1000);
        reject(err);
      });
    };
    attempt(retries);
  });
}

async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
mimo-wiki 安装器

用法:
  npx mimo-wiki              安装到当前目录
  npx mimo-wiki --global     安装到全局 ~/.mimocode
  npx mimo-wiki --dir <path> 安装到指定目录
  npx mimo-wiki --help       显示帮助

示例:
  cd my-project && npx mimo-wiki
  npx mimo-wiki --global
  npx mimo-wiki --dir ~/my-project
`);
    process.exit(0);
  }

  let targetDir;
  if (args.includes('--global')) {
    targetDir = path.join(process.env.HOME || process.env.USERPROFILE, '.mimocode');
  } else if (args.includes('--dir')) {
    const dirIdx = args.indexOf('--dir') + 1;
    targetDir = args[dirIdx] ? path.resolve(args[dirIdx]) : null;
    if (!targetDir) {
      console.error('错误: --dir 需要指定路径');
      process.exit(1);
    }
  } else {
    targetDir = process.cwd();
  }

  console.log(`mimo-wiki 安装到: ${targetDir}`);
  console.log('');

  let installed = 0, skipped = 0, errors = 0;

  for (const file of FILES) {
    const destPath = path.join(targetDir, file.dest);

    if (fs.existsSync(destPath)) {
      console.log(`  跳过（已存在）: ${file.dest}`);
      skipped++;
      continue;
    }

    try {
      fs.mkdirSync(path.dirname(destPath), { recursive: true });
      const content = await download(`${BASE_URL}/${file.src}`);
      fs.writeFileSync(destPath, content, 'utf-8');
      console.log(`  安装: ${file.dest}`);
      installed++;
    } catch (err) {
      console.error(`  失败: ${file.dest} — ${err.message}`);
      errors++;
    }
  }

  console.log('');
  console.log(`完成: ${installed} 已安装, ${skipped} 跳过, ${errors} 失败`);

  if (installed > 0) {
    console.log('');
    console.log('下一步: 在 MiMo Code 中说 "帮我创建一个新的 LLM Wiki"');
  }
}

main().catch(err => {
  console.error('安装失败:', err.message);
  process.exit(1);
});
