#!/usr/bin/env tsx

// ========================================================= //
// import                                                    //
// ========================================================= //
import { spawn } from 'child_process';

// ========================================================= //
// function                                                  //
// ========================================================= //

/**
 * Prisma Clientを生成する
 */
function generateClient(): void {
  console.log('Generating Prisma Client...');
  const prisma = spawn('prisma', ['generate', '--schema=./prisma'], {
    stdio: 'inherit',
    env: process.env,
  });

  prisma.on('close', (code) => {
    if (code === 0) {
      console.log('✓ Prisma Client generated successfully');
      process.exit(0);
    } else {
      process.exit(code ?? 1);
    }
  });
}

/**
 * メイン処理
 */
function main(): void {
  generateClient();
}

// ========================================================= //
// execute                                                   //
// ========================================================= //
main();
