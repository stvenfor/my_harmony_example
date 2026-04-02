import { util } from '@kit.ArkTS';

export class RawfileUtil {
  /**
   * 读取并解析 rawfile 目录下的 JSON 文件
   * @param fileName 文件名（相对于 rawfile 目录）
   * @returns 解析后的 JSON 对象，失败时返回 null
   */
  static async getRawJson<T>(fileName: string): Promise<T | null> {
    if (!fileName || fileName.trim().length === 0) {
      console.error('getRawJson failed: fileName is empty');
      return null;
    }
    let decoder = util.TextDecoder.create('utf-8');
    try {
      const data: Uint8Array = await getContext().resourceManager.getRawFileContent(fileName);
      const jsonStr = decoder.decodeToString(data);

      if (!jsonStr || jsonStr.trim().length === 0) {
        console.error(`getRawJson failed: file ${fileName} is empty`);
        return null;
      }

      return JSON.parse(jsonStr) as T;
    } catch (error) {
      const businessError = error as BusinessError;
      console.error(`getRawJson failed: fileName=${fileName}, code=${businessError.code}, message=${businessError.message}`);
      return null;
    }
  }
}