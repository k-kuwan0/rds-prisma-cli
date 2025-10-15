// ========================================================= //
// import                                                    //
// ========================================================= //
import {
  SecretsManagerClient,
  GetSecretValueCommand,
  SecretsManagerClientConfig,
} from '@aws-sdk/client-secrets-manager';

// ========================================================= //
// type                                                      //
// ========================================================= //
type RDSSecret = {
  username: string;
  password: string;
  host?: string;
  port?: number;
  dbName?: string;
  engine?: string;
  dbClusterIdentifier?: string;
};

// ========================================================= //
// function                                                  //
// ========================================================= //
/**
 * Secrets ManagerからRDS認証情報を取得
 * @param secretName - RDSシークレット名またはARN
 * @param region - AWSリージョン（デフォルト: ap-northeast-1）
 * @returns RDS認証情報
 * @throws Secrets Managerへのアクセスまたは必須フィールドの検証に失敗した場合
 */
async function getRDSSecret(
  secretName: string,
  region: string = 'ap-northeast-1'
): Promise<RDSSecret> {
  const config: SecretsManagerClientConfig = { region };
  const client = new SecretsManagerClient(config);

  try {
    const response = await client.send(
      new GetSecretValueCommand({
        SecretId: secretName,
      })
    );

    if (!response.SecretString) {
      throw new Error(`SecretString not found in response for secret: ${secretName}`);
    }

    const secret = JSON.parse(response.SecretString) as RDSSecret;

    // 必須フィールドの検証（username と password のみ）
    if (!secret.username || !secret.password) {
      throw new Error(
        `Invalid RDS secret format for "${secretName}". Missing required fields: username or password`
      );
    }

    return secret;
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(`Failed to retrieve RDS secret "${secretName}": ${error.message}`);
    }
    throw error;
  }
}

// ========================================================= //
// export                                                    //
// ========================================================= //
export type { RDSSecret };
export { getRDSSecret };
