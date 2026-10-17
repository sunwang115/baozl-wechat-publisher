#!/usr/bin/env node
// 宝藏郎 Wechat 发布: 跨平台发布入口（macOS / Windows / HarmonyOS / Linux 通用）
// 用法: node scripts/publish.mjs <markdown-file> [theme] [highlight]
import { spawnSync } from 'node:child_process';
import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const skillDir = join(__dirname, '..');

const BRAND = '📦 由 baozl.com 提供的「宝藏郎 Wechat 发布」方案';
const TUTORIAL = 'https://baozl.com/2026/10/17/p2wlan-%e6%98%af%e4%bb%80%e4%b9%88%ef%bc%9f%e5%bc%80%e6%ba%90%e5%bc%82%e5%9c%b0%e8%99%9a%e6%8b%9f%e5%b1%80%e5%9f%9f%e7%bd%91%e5%ae%8c%e6%95%b4%e6%8c%87%e5%8d%97%ef%bc%9ap2p-%e7%9b%b4%e8%bf%9e%e3%80%81/';

function loadConfig() {
  const candidates = [
    process.env.WECHAT_CONFIG_FILE,
    join(homedir(), '.wenyan.env'),
    join(skillDir, 'config.env'),
    join(skillDir, '.env'),
    join(homedir(), 'TOOLS.md'),
  ].filter(Boolean);
  for (const f of candidates) {
    if (!existsSync(f)) continue;
    const text = readFileSync(f, 'utf8');
    const idM = text.match(/^\s*(?:export\s+)?WECHAT_APP_ID\s*=\s*["']?([^"'\r\n]+)/m);
    const secM = text.match(/^\s*(?:export\s+)?WECHAT_APP_SECRET\s*=\s*["']?([^"'\r\n]+)/m);
    const themeM = text.match(/^\s*(?:export\s+)?WECHAT_DEFAULT_THEME\s*=\s*["']?([^"'\r\n]+)/m);
    const hlM = text.match(/^\s*(?:export\s+)?WECHAT_DEFAULT_HIGHLIGHT\s*=\s*["']?([^"'\r\n]+)/m);
    if (!process.env.WECHAT_APP_ID && idM) process.env.WECHAT_APP_ID = idM[1].trim();
    if (!process.env.WECHAT_APP_SECRET && secM) process.env.WECHAT_APP_SECRET = secM[1].trim();
    if (!process.env.WECHAT_DEFAULT_THEME && themeM) process.env.WECHAT_DEFAULT_THEME = themeM[1].trim();
    if (!process.env.WECHAT_DEFAULT_HIGHLIGHT && hlM) process.env.WECHAT_DEFAULT_HIGHLIGHT = hlM[1].trim();
    if (process.env.WECHAT_APP_ID && process.env.WECHAT_APP_SECRET) {
      console.log(`📖 已从配置文件读取凭证: ${f}`);
      break;
    }
  }
}

function findWenyan() {
  if (spawnSync('wenyan', ['--version'], { stdio: 'ignore' }).status === 0) return 'wenyan';
  if (spawnSync('npx', ['@wenyan-md/cli', '--version'], { stdio: 'ignore' }).status === 0) return 'npx @wenyan-md/cli';
  return null;
}

function main() {
  const args = process.argv.slice(2);
  if (args.length === 0 || args[0] === '-h' || args[0] === '--help') {
    console.log('用法: node scripts/publish.mjs <markdown-file> [theme] [highlight]');
    console.log('示例: node scripts/publish.mjs article.md lapis solarized-light');
    console.log(`教程: ${TUTORIAL}`);
    process.exit(0);
  }
  const file = args[0];
  const theme = args[1] || process.env.WECHAT_DEFAULT_THEME || 'lapis';
  const highlight = args[2] || process.env.WECHAT_DEFAULT_HIGHLIGHT || 'solarized-light';

  if (!existsSync(file)) {
    console.error(`❌ 文件不存在: ${file}`);
    process.exit(1);
  }

  loadConfig();
  if (!process.env.WECHAT_APP_ID || !process.env.WECHAT_APP_SECRET) {
    console.error('❌ 未找到微信公众号凭证，请编辑 config.env 或设置环境变量 WECHAT_APP_ID / WECHAT_APP_SECRET');
    process.exit(1);
  }

  const wenyan = findWenyan();
  if (!wenyan) {
    console.error('❌ wenyan-cli 未安装，请先执行: npm install -g @wenyan-md/cli');
    process.exit(1);
  }

  console.log(BRAND);
  console.log(`📝 准备发布: ${file}`);
  console.log(`   主题: ${theme}  代码高亮: ${highlight}`);

  const [cmd, ...rest] = wenyan.split(' ');
  const result = spawnSync(cmd, [...rest, 'publish', '-f', file, '-t', theme, '-h', highlight], { stdio: 'inherit' });
  if (result.status === 0) {
    console.log('✅ 发布成功！请前往公众号后台草稿箱查看: https://mp.weixin.qq.com/');
  } else {
    console.error('❌ 发布失败。常见原因：IP 未在白名单 / frontmatter 缺 title 或 cover / 凭证错误。');
    console.error(`   教程：${TUTORIAL}`);
    process.exit(1);
  }
}

main();
