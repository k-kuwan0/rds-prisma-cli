// ========================================================= //
// import                                                    //
// ========================================================= //
import { PrismaClient, Todo } from '@prisma/client';
import { todoSeedData } from './todo.data';

// ========================================================= //
// function                                                  //
// ========================================================= //

/**
 * Todoデータをシードする
 * @param prisma - PrismaClientインスタンス
 * @returns 作成されたTodoの配列
 */
export async function seedTodos(prisma: PrismaClient): Promise<Todo[]> {
  console.log('Seeding todos...');

  const todos: Todo[] = [];

  for (const todoData of todoSeedData) {
    const todo = await prisma.todo.upsert({
      where: { id: todoData.id },
      update: todoData,
      create: todoData,
    });
    todos.push(todo);
    console.log(`  - ${todo.title} [${todo.priority}]${todo.completed ? ' ✓' : ''}`);
  }

  console.log(`[Todos] Seeded ${todos.length} records`);
  return todos;
}