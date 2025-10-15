// ========================================================= //
// import                                                    //
// ========================================================= //
import { config } from 'dotenv';
import { resolve } from 'path';
import { existsSync } from 'fs';

// ========================================================= //
// function                                                  //
// ========================================================= //

/**
 * 環境ファイルを読み込む
 * NODE_ENV環境変数または明示的な環境指定に基づいて適切な.envファイルを読み込む
 * 優先順位: APP_ENV > NODE_ENV > デフォルト(local)
 */
function loadEnvironment(): void {
  const env = process.env.APP_ENV || process.env.NODE_ENV || 'local';
  const envPath = resolve(__dirname, `../../environments/.env.${env}`);

  // 指定された環境ファイルが存在するか確認
  if (existsSync(envPath)) {
    console.log(`Loading environment from: .env.${env}`);
    config({ path: envPath });
  } else {
    console.warn(`Warning: ${envPath} not found. Using existing environment variables.`);
  }
}

// ========================================================= //
// export                                                    //
// ========================================================= //
export { loadEnvironment };
