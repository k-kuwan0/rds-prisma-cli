// ========================================================= //
// import                                                    //
// ========================================================= //
import { Priority } from '@prisma/client';

// ========================================================= //
// type                                                      //
// ========================================================= //

/**
 * Todoのシードデータ型
 */
export type TodoSeedData = {
  id: string;
  title: string;
  description?: string;
  completed: boolean;
  priority: Priority;
  dueDate?: Date;
};

// ========================================================= //
// data                                                      //
// ========================================================= //

/**
 * Todoのシードデータ
 */
export const todoSeedData: TodoSeedData[] = [
  {
    id: 'seed_todo_001',
    title: 'プロジェクトの初期設定',
    description: 'TypeScript、Prisma、ESLintの設定を完了する',
    completed: true,
    priority: 'HIGH',
  },
  {
    id: 'seed_todo_002',
    title: 'データベースモデルの設計',
    description: 'TODOアプリに必要なテーブル構造を設計する',
    completed: true,
    priority: 'HIGH',
  },
  {
    id: 'seed_todo_003',
    title: 'API エンドポイントの実装',
    description: 'CRUD操作のためのREST APIを実装する',
    completed: false,
    priority: 'HIGH',
    dueDate: new Date('2025-10-20'),
  },
  {
    id: 'seed_todo_004',
    title: 'ユーザー認証機能の追加',
    description: 'JWT認証を実装して、ユーザーごとのTODO管理を可能にする',
    completed: false,
    priority: 'MEDIUM',
    dueDate: new Date('2025-10-25'),
  },
  {
    id: 'seed_todo_005',
    title: 'フロントエンドの開発',
    description: 'React/Vue.jsでTODOアプリのUIを作成する',
    completed: false,
    priority: 'MEDIUM',
    dueDate: new Date('2025-10-30'),
  },
  {
    id: 'seed_todo_006',
    title: 'テストコードの作成',
    description: 'ユニットテストとE2Eテストを追加する',
    completed: false,
    priority: 'MEDIUM',
  },
  {
    id: 'seed_todo_007',
    title: 'ドキュメントの作成',
    description: 'README、API仕様書、開発ガイドを作成する',
    completed: false,
    priority: 'LOW',
  },
  {
    id: 'seed_todo_008',
    title: '本番環境へのデプロイ',
    description: 'AWS Lambdaにデプロイして動作確認する',
    completed: false,
    priority: 'URGENT',
    dueDate: new Date('2025-11-01'),
  },
];