import { deviceInfo } from '@kit.BasicServicesKit';
import { bundleManager } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { buildCommonQueryMapWithTimestamp, ConfigParams } from '@ohos/common'



export class HttpHeaderUtil {
  private static readonly PREFERENCES_NAME = 'app_settings'; // 对应 NSUserDefaults 的存储文件名

  /**
   * 获取 HTTP 请求头字典
   */
  static async getHttpHeaderDic(): Promise<ConfigParams> {
    const headerDic: ConfigParams = {};

    try {
      // 1. 基础设备信息
      const deviceModel = deviceInfo.productModel; // 对应 hardwareDescription
      const deviceSystemName = 'HarmonyOS'; // iOS 的 systemName 在鸿蒙下固定为 HarmonyOS
      const deviceSystemVersion = deviceInfo.osFullName; // 对应 systemVersion

      headerDic['Device-Model'] = deviceModel;
      headerDic['User-Agent'] = 'HarmonyOS'; // 原代码固定为 iOS，这里建议改为 HarmonyOS 或保持业务约定
      headerDic['Client-OS'] = `${deviceSystemName} ${deviceSystemVersion}`;

      // 2. 应用版本信息
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      headerDic['versionCode'] = String(bundleInfo.versionCode);
      headerDic['App-Version'] = bundleInfo.versionName;

      // 3. 渠道名称 (需要在 module.json5 或 app.json5 的 metadata 中配置)
      // 假设在 module.json5 中配置了 "com.example.channel": "Huawei"
      const channel = ""
      if (channel) {
        headerDic['UMENG-CHANNEL'] = channel;
      }

      // 4. 设备标识符 (IDFA/MAC 在鸿蒙中受限，通常使用 OAID 或 UUID)
      // 注意：OAID 需要集成 HMS Core 或使用相关 API，这里暂用 UUID 模拟 devicetoken 逻辑

      headerDic['devicetoken'] = "";

      // 原代码中的 idfa/mac 在鸿蒙标准 SDK 中无法直接获取，建议替换为 oaid 或 uuid
      headerDic['idfa'] = "";
      headerDic['MAC'] = "";

      // 5. APP-NAME 和 Device-Type 判断
      const bundleName = bundleInfo.name;

      headerDic['APP-NAME'] = "QUPEIYIN";
      headerDic['Device-Type'] = "harmony";

      // 6. 用户偏好设置 (模拟 NSUserDefaults)
      const prefs = await preferences.getPreferences(getContext(), HttpHeaderUtil.PREFERENCES_NAME);

      // AREA
      const area = await prefs.get('kFZUserLocationCityAreaID', '') as string;
      if (area && area.length > 0) {
        headerDic['AREA'] = area;
      }

      // DISTINCT-ID
      const sensorDistinctId = await prefs.get('kSensorDistinctId', '') as string;
      if (sensorDistinctId) {
        headerDic['DISTINCT-ID'] = sensorDistinctId;
      }

      // e-device-id
      if (bundleName.includes('aiwj')) {
        if (sensorDistinctId) {
          headerDic['e-device-id'] = sensorDistinctId;
        }
      } else {
        const sensorDeviceId = await prefs.get('kSensorDeviceId', '') as string;
        if (sensorDeviceId) {
          headerDic['e-device-id'] = sensorDeviceId;
        }
      }

      // oaid
      const oaid = await prefs.get('idfa_upload_string', '') as string;
      if (oaid) {
        headerDic['oaid'] = oaid;
      }

      // 7. 国际化语言与区域 (针对 dubbingInternational)
      if (bundleName.includes('dubbingInternational')) {
        const savedLang = await prefs.get('AppLanguage', '') as string;
        let lang = 'en';
        if (savedLang === 'zh-Hans') lang = 'zh-CN';
        else if (savedLang === 'zh-Hant') lang = 'zh-HK';
        else if (savedLang === 'vi') lang = 'vi';
        else if (savedLang === 'ko') lang = 'ko';
        else if (savedLang === 'ja') lang = 'ja';

        headerDic['lang'] = lang;

        const region = await prefs.get('englishtalk_region', '') as string;
        if (region) {
          headerDic['Region'] = region;
        }
      }

    } catch (err) {
      console.error('GetHttpHeaderDic failed', JSON.stringify(err));
    }

    return headerDic;
  }


  /**
   * 为参数字典添加校准后的服务器时间戳（实现见 common buildCommonQueryMapWithTimestamp）
   */
  static async dictionaryWithTimestamp(): Promise<ConfigParams> {
    return buildCommonQueryMapWithTimestamp()
  }


  /**
   * 获取设备 Token (模拟 iOS 的 identifierForVendor 或 SensorDistinctId)
   */
  private static async getDeviceToken(): Promise<string> {
    try {
      const prefs = await preferences.getPreferences(getContext(), HttpHeaderUtil.PREFERENCES_NAME);
      let token = await prefs.get('kSensorDistinctId', '') as string;

      if (!token || token.length === 0) {
        // 如果不存在，生成一个 UUID 并保存，模拟 identifierForVendor 的持久性
        token = "";
        await prefs.put('kSensorDistinctId', token);
        await prefs.flush();
      }
      return token;
    } catch (err) {
      return "";
    }
  }


}
