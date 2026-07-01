#!/usr/bin/env node
/**
 * mimo-wiki 安装脚本
 * 用法:
 *   npx mimo-wiki              安装到当前目录
 *   npx mimo-wiki --global     安装到全局 ~/.mimocode
 *   npx mimo-wiki --help       显示帮助
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

const REPO = 'fenzel999/mimo-wiki';
const BRANCH = 'master';
const BASE_URL = `https://raw.githubusercontent.com/${REPO}/${BRANCH}`;

// 需要下载的文件列表（相对于仓库根目录）
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

// 下载单个文件
function download(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'mimo-wiki-installer' } }, (res) => {
      if (res.statusCode === 302 || res.statusCode === 301) {
        return download(res.headers.location).then(resolve).catch(reject);
      }
      if (res.statusCode !== 200) {
        return reject(new Error(`HTTP ${res.statusCode}: ${url}`));
      }
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
      res.on('error', reject);
    }).on('error', reject);
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

  // 确定安装目标
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

  let installed = 0;
  let skipped = 0;
  let errors = 0;

  for (const file of FILES) {
    const destPath = path.join(targetDir, file.dest);
    const destDir = path.dirname(destPath);

    // 跳过已存在的文件
    if (fs.existsSync(destPath)) {
      console.log(`  跳过（已存在）: ${file.dest}`);
      skipped++;
      continue;
    }

    try {
      // 创建目录
      fs.mkdirSync(destDir, { recursive: true });

      // 下载文件
      const url = `${BASE_URL}/${file.src}`;
      const content = await download(url);
      fs.writeFileSync(destPath, content, 'utf-8');

      console.log(`  安装: ${file.dest}`);
      installed++;
    } catch (err) {
      console.error(`  失败: ${file.dest} — ${err.message}`);
      errors++;
    }
  }

  console.log('');
  console.log(`完成: ${installed} 个文件已安装, ${skipped} 个跳过, ${errors} 个失败`);

  if (installed > 0) {
    console.log('');
    console.log('下一步:');
    console.log('  在 MiMo Code 中说: "帮我创建一个新的 LLM Wiki"');
  }
}

main().catch(err => {
  console.error('安装失败:', err.message);
  process.exit(1);
});
