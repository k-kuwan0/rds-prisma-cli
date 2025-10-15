// ========================================================= //
// import                                                    //
// ========================================================= //
import { PrismaClient } from '@prisma/client';
import { getRDSSecret } from '../../shared/aws/secrets-manager/getRdsSecret';
import { buildMariaDbUrl } from '../../shared/database';
import { loadEnvironment } from '../utils/loadEnvironment';
import { executeSeed } from '../../prisma/seed/executeSeed';

// ========================================================= //
// function                                                  //
// ========================================================= //

/**
 * Prisma DB Seedを実行する
 */
async function runSeed(): Promise<void> {
  const secretName = process.env.DB_SECRET_NAME;
  const region = process.env.AWS_REGION || 'ap-northeast-1';

  if (!secretName) {
    console.error('Error: DB_SECRET_NAME environment variable is not set');
    process.exit(1);
  }

  let prisma: PrismaClient | null = null;

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

    // Set DATABASE_URL for Prisma Client
    process.env.DATABASE_URL = databaseUrl;

    // Initialize Prisma Client
    prisma = new PrismaClient();

    // Execute seed
    await executeSeed(prisma);

    console.log('\n✓ Database seeded successfully');
  } catch (error) {
    console.error('Failed to seed database:', error);
    process.exit(1);
  } finally {
    if (prisma) {
      await prisma.$disconnect();
    }
  }
}

/**
 * メイン処理
 */
async function main(): Promise<void> {
  loadEnvironment();
  await runSeed();
}

// ========================================================= //
// execute                                                   //
// ========================================================= //
main();
