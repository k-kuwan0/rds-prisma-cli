// ========================================================= //
// import                                                    //
// ========================================================= //
import { spawn } from 'child_process';
import { getRDSSecret } from '../../shared/aws/secrets-manager/getRdsSecret';
import { buildMariaDbUrl } from '../../shared/database';
import { loadEnvironment } from '../utils/loadEnvironment';

// ========================================================= //
// function                                                  //
// ========================================================= //

/**
 * Prisma Studioを起動する
 */
async function runStudio(): Promise<void> {
  const secretName = process.env.DB_SECRET_NAME;
  const region = process.env.AWS_REGION || 'ap-northeast-1';

  if (!secretName) {
    console.error('Error: DB_SECRET_NAME environment variable is not set');
    process.exit(1);
  }

  try {
    console.log('Fetching database credentials from Secrets Manager...');
    const secret = await getRDSSecret(secretName, region);

    const host = secret.host || process.env.DB_HOST;
    const dbName = secret.dbName || process.env.DB_NAME;
    const port = secret.port || (process.env.DB_PORT ? parseInt(process.env.DB_PORT) : undefined);

    if (!host || !dbName) {
      console.error(
        'Error: DB_HOST and DB_NAME must be set either in Secrets Manager or environment variables'
      );
      process.exit(1);
    }

    const databaseUrl = buildMariaDbUrl({
      username: secret.username,
      password: secret.password,
      host,
      port,
      database: dbName,
    });

    console.log('Starting Prisma Studio...');
    const prisma = spawn('prisma', ['studio', '--schema=./prisma'], {
      stdio: 'inherit',
      env: {
        ...process.env,
        DATABASE_URL: databaseUrl,
      },
    });

    prisma.on('close', (code) => {
      process.exit(code ?? 0);
    });
  } catch (error) {
    console.error('Failed to start Prisma Studio:', error);
    process.exit(1);
  }
}

/**
 * メイン処理
 */
async function main(): Promise<void> {
  loadEnvironment();
  await runStudio();
}

// ========================================================= //
// execute                                                   //
// ========================================================= //
main();
