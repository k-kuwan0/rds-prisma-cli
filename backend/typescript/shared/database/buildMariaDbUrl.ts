// ========================================================= //
// import                                                    //
// ========================================================= //

// ========================================================= //
// type                                                      //
// ========================================================= //
type DatabaseCredentials = {
  username: string;
  password: string;
  host: string;
  port?: number;
  database: string;
};

type DatabaseUrlOptions = {
  /** SSL接続を有効にするか（デフォルト: false） */
  ssl?: boolean;
  /** 接続タイムアウト（秒単位） */
  connectionTimeout?: number;
  /** 追加のクエリパラメータ */
  additionalParams?: Record<string, string>;
};

// ========================================================= //
// function                                                  //
// ========================================================= //

/**
 * MariaDB用のDATABASE_URLを構築
 * @param credentials - データベース認証情報
 * @param options - データベースURLオプション
 * @returns Prisma用のDATABASE_URL
 * @example
 * const url = buildMariaDbUrl({
 *   username: 'admin',
 *   password: 'p@ssw0rd!',
 *   host: 'localhost',
 *   port: 3306,
 *   database: 'mydb'
 * });
 * // => mysql://admin:p%40ssw0rd%21@localhost:3306/mydb
 */
function buildMariaDbUrl(credentials: DatabaseCredentials, options: DatabaseUrlOptions = {}): string {
  const { username, password, host, port = 3306, database } = credentials;

  // 必須フィールドの検証
  if (!username || !password || !host || !database) {
    throw new Error(
      'Missing required credentials: username, password, host, and database are required'
    );
  }

  // ユーザー名とパスワードをエンコード
  const encodedUsername = encodeURIComponent(username);
  const encodedPassword = encodeURIComponent(password);

  // ベースURLの構築
  let url = `mysql://${encodedUsername}:${encodedPassword}@${host}:${port}/${database}`;

  // クエリパラメータの構築
  const queryParams: string[] = [];

  if (options.ssl) {
    queryParams.push('sslmode=require');
  }

  if (options.connectionTimeout) {
    queryParams.push(`connect_timeout=${options.connectionTimeout}`);
  }

  if (options.additionalParams) {
    for (const [key, value] of Object.entries(options.additionalParams)) {
      queryParams.push(`${key}=${encodeURIComponent(value)}`);
    }
  }

  // クエリパラメータをURLに追加
  if (queryParams.length > 0) {
    url += `?${queryParams.join('&')}`;
  }

  return url;
}

// ========================================================= //
// export                                                    //
// ========================================================= //
export { buildMariaDbUrl };
