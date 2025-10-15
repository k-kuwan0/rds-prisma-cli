// ========================================================= //
// import                                                    //
// ========================================================= //
import { PrismaClient } from '@prisma/client';
import { seedTodos } from './models/todo/todo.seed';

// ========================================================= //
// function                                                  //
// ========================================================= //

/**
 * データベースのシード処理を実行する
 * @param prisma - PrismaClientインスタンス
 */
export async function executeSeed(prisma: PrismaClient): Promise<void> {
  console.log('Starting database seeding...\n');

  try {
    // Seed todos
    await seedTodos(prisma);

    console.log('\nDatabase seeding completed successfully.');
  } catch (error) {
    console.error('Error during seeding:', error);
    throw error;
  }
}
