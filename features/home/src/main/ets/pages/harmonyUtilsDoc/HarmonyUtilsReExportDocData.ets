/**
 * @ohos/common → @pura/harmony-utils 再导出项的「说明 + 示例代码」数据源。
 * 与 common/Index.ets 中 AppUtil … CryptoHelper 一一对应，供 HarmonyUtilsReExportDocPage 展示。
 */
export interface HarmonyUtilsReExportDocSection {
  /** 工具类 / 单例名称 */
  readonly title: string
  /** 用途、前置条件、注意点（中文） */
  readonly detail: string
  /** 可复制参考的 ArkTS 示例（字符串内为展示用，换行用 \n） */
  readonly code: string
}

/**
 * 顺序与 common/Index.ets 第 75–101 行导出顺序一致。
 */
export const HARMONY_UTILS_REEXPORT_DOC_SECTIONS: HarmonyUtilsReExportDocSection[] = [
  {
    title: 'AppUtil',
    detail:
      '应用与 UIAbility 上下文相关能力：版本判断、取 ApplicationContext / UIAbilityContext、主窗口等。\n' +
      '【重要】库作者要求：在 UIAbility.onCreate 中调用 AppUtil.init(this.context)，否则部分方法会退化为 getContext() 兜底并打错误日志。',
    code:
      '// UIAbility.onCreate 中：\n' +
      'import { common } from \'@kit.AbilityKit\'\n' +
      'import { AppUtil } from \'@ohos/common\'\n' +
      '\n' +
      'onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {\n' +
      '  AppUtil.init(this.context as common.UIAbilityContext)\n' +
      '}\n' +
      '\n' +
      '// 任意已初始化后：\n' +
      'const ctx = AppUtil.getContext()\n' +
      'const appCtx = AppUtil.getApplicationContext()\n' +
      'const supported = AppUtil.isApiSupported(12) // 判断当前系统 API 是否 ≥ 12'
  },
  {
    title: 'WindowUtil',
    detail:
      '封装主窗口常见操作：方向、全屏、状态栏、窗口尺寸、亮度等，内部多依赖 AppUtil.getMainWindow()。\n' +
      '使用前同样依赖 AppUtil.init；涉及方向/沉浸式等需关注系统权限与产品规范。',
    code:
      'import { window } from \'@kit.ArkUI\'\n' +
      'import { WindowUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 异步设置首选方向（默认操作主窗口）\n' +
      'await WindowUtil.setPreferredOrientation(window.Orientation.PORTRAIT)\n' +
      '\n' +
      '// 读取当前方向\n' +
      'const o = WindowUtil.getPreferredOrientation()'
  },
  {
    title: 'DeviceUtil',
    detail:
      '设备信息：品牌、型号、屏幕宽高、是否折叠屏、系统版本等，便于做机型适配或埋点维度。\n' +
      '多为同步只读接口，注意不要在 UI 高频帧回调里重复调用重逻辑（若有）。',
    code:
      'import { DeviceUtil } from \'@ohos/common\'\n' +
      '\n' +
      'const brand = DeviceUtil.getBrand()\n' +
      'const model = DeviceUtil.getProductModel()\n' +
      '// 具体方法名以 @pura/harmony-utils 当前版本 DeviceUtil 为准'
  },
  {
    title: 'ToastUtil',
    detail:
      '对系统 promptAction.showToast 的封装，支持默认样式、底部偏移、显示时长、是否置顶等。\n' +
      '可 ToastUtil.setDefaultConfig 统一改默认皮肤；在 UIExtension 等场景可传 uiContext.getPromptAction()。',
    code:
      'import { ToastUtil } from \'@ohos/common\'\n' +
      '\n' +
      'ToastUtil.showToast(\'保存成功\')\n' +
      '\n' +
      'ToastUtil.showToast(\'网络异常\', {\n' +
      '  duration: 3000,\n' +
      '  bottom: \'120vp\'\n' +
      '})'
  },
  {
    title: 'DialogUtil',
    detail:
      '通用对话框封装（确认/提示等），减少各业务重复写 AlertDialog 样板代码。\n' +
      '具体 API（showConfirm、showLoading 等）以库内 DialogUtil 与 DialogOptions 为准；注意在页面销毁时关闭弹窗避免泄漏。',
    code:
      'import { DialogUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 单按钮确认框\n' +
      'DialogUtil.showConfirmDialog({\n' +
      '  title: \'提示\',\n' +
      '  message: \'操作完成\',\n' +
      '  confirm: { value: \'知道了\', action: () => {} }\n' +
      '})\n' +
      '\n' +
      '// 双按钮：DialogUtil.showPrimaryDialog({ title, message, primaryButton, secondaryButton })'
  },
  {
    title: 'LogUtil',
    detail:
      '统一日志出口：可切换 HiLog / console，配置 domain、tag、是否打印。\n' +
      '建议在 Ability 启动时 LogUtil.init(domain, tag, true, true)，生产环境关闭 showLog。',
    code:
      'import { LogUtil } from \'@ohos/common\'\n' +
      '\n' +
      'LogUtil.init(0x0000, \'MyApp\', true, true)\n' +
      'LogUtil.info(\'User\', \'login ok\')\n' +
      'LogUtil.error(\'Pay\', \'code=\' + code)'
  },
  {
    title: 'PreferencesUtil',
    detail:
      '对 @ohos.data.preferences 的同步封装，按名称多实例；依赖 AppUtil.getContext()。\n' +
      '首次使用可 PreferencesUtil.init(\'my_store\')；键值建议业务前缀，避免模块间冲突。',
    code:
      'import { PreferencesUtil } from \'@ohos/common\'\n' +
      '\n' +
      'PreferencesUtil.init(\'user_prefs\')\n' +
      'PreferencesUtil.putSync(\'token\', \'xxx\')\n' +
      'const token = PreferencesUtil.getStringSync(\'token\', \'\')'
  },
  {
    title: 'CacheUtil',
    detail:
      '轻量内存/磁盘缓存抽象（具体策略见库实现），适合存配置快照、列表首屏等。\n' +
      '与 PreferencesUtil 区别：Preferences 偏持久化键值；Cache 偏短期、可丢数据。',
    code:
      'import { CacheUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 按库实际 API 调用，例如存取 JSON 字符串或对象：\n' +
      'CacheUtil.put(\'home_banner\', jsonString)\n' +
      'const cached = CacheUtil.get(\'home_banner\')'
  },
  {
    title: 'NetworkUtil',
    detail:
      '网络状态检测、是否联网、网络类型等，用于请求前兜底或 UI 提示。\n' +
      '与业务 HTTP 封装（如你们 Request 模块）配合：先 NetworkUtil 判断再发请求可减少无效失败。',
    code:
      'import { NetworkUtil, ToastUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 同步判断是否已有默认数据网（需声明网络相关权限）\n' +
      'if (!NetworkUtil.hasDefaultNetSync()) {\n' +
      '  ToastUtil.showToast(\'请检查网络\')\n' +
      '  return\n' +
      '}\n' +
      '// 或 await NetworkUtil.hasDefaultNet() 异步判断'
  },
  {
    title: 'EmitterUtil',
    detail:
      '对事件总线（Emitter）的封装，用于跨页面/模块广播状态，如登录成功、主题切换。\n' +
      '注意订阅要在适当时机 off，避免页面销毁后仍收到回调。',
    code:
      'import { EmitterUtil } from \'@ohos/common\'\n' +
      '\n' +
      'const EVENT_LOGIN = \'app_login_ok\'\n' +
      'EmitterUtil.onSubscribe<{ token: string }>(EVENT_LOGIN, (data) => {\n' +
      '  console.info(data.token)\n' +
      '})\n' +
      'EmitterUtil.post(EVENT_LOGIN, { token: \'abc\' })\n' +
      '// 页面销毁时：EmitterUtil.unSubscribe(EVENT_LOGIN)'
  },
  {
    title: 'LRUCacheUtil',
    detail:
      'LRU 淘汰策略的缓存工具，适合列表图片 URL→路径、接口结果短期复用。\n' +
      '设置合理 maxSize，避免大对象常驻导致内存压力。',
    code:
      'import { LRUCacheUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 单例，内部 util.LRUCache 默认容量见库实现\n' +
      'const cache = LRUCacheUtil.getInstance()\n' +
      'cache.put(\'bannerUrl\', imageUrl)\n' +
      'const url = cache.get<string>(\'bannerUrl\')'
  },
  {
    title: 'GlobalContext',
    detail:
      '进程内单例 Map，存放任意 Object（如全局 Service、临时路由参数）。\n' +
      '【注意】非持久化，Ability 被杀即清空；不要存超大对象；键名用常量避免拼写错误。',
    code:
      'import { GlobalContext } from \'@ohos/common\'\n' +
      '\n' +
      'const g = GlobalContext.getContext()\n' +
      'g.put(\'sessionId\', \'abc123\')\n' +
      'const sid = g.get<string>(\'sessionId\')\n' +
      'g.remove(\'sessionId\')'
  },
  {
    title: 'FileUtil',
    detail:
      '文件读写、路径拼接、沙箱目录辅助等（以库实现为准）。\n' +
      '涉及用户文件需权限与 Picker；大文件 IO 建议放 worker 或异步队列。',
    code:
      'import { FileUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 拼接沙箱内路径（不存在目录时会尝试 mkdir）\n' +
      'const path = FileUtil.getFilesDirPath(\'logs\', \'app.log\', true)\n' +
      '// 再配合 fs.open/read/write 等（库内另有 copy/move/stat 等封装）'
  },
  {
    title: 'ImageUtil',
    detail:
      '图片解码、压缩、尺寸处理等辅助（具体能力与系统 API 版本相关）。\n' +
      '大图注意采样率与 OOM；展示层优先 Image 组件 + 合适 cacheOption。',
    code:
      'import { ImageUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 按库文档调用，例如获取图片尺寸、压缩保存等\n' +
      'ImageUtil.getImageSize(uri).then((size) => {\n' +
      '  console.info(size.width + \'x\' + size.height)\n' +
      '})'
  },
  {
    title: 'SnapshotUtil',
    detail:
      '组件或窗口截图能力封装，用于分享海报、反馈上传界面快照等。\n' +
      '截图可能涉及隐私，需产品授权；注意主线程耗时与 PixelMap 释放。',
    code:
      'import { SnapshotUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 典型：传入组件快照选项（参数以库为准）\n' +
      'SnapshotUtil.get(\'id\').then((pixmap) => {\n' +
      '  // 上传或保存\n' +
      '})'
  },
  {
    title: 'PreviewUtil',
    detail:
      '与预览、缩略图相关的工具（若库版本提供），常用于文件管理、图集预览场景。\n' +
      '与 ImageUtil、SnapshotUtil 分工以官方 README / 源码注释为准。',
    code:
      'import { PreviewUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 查阅 @pura/harmony-utils PreviewUtil 当前版本方法列表后调用'
  },
  {
    title: 'DateUtil',
    detail:
      '日期格式化、解析、加减、区间比较等，避免业务手写 SimpleDateFormat 式碎片代码。\n' +
      '展示层仍建议统一时区与服务器时间偏移（若你们有 CommonQueryTimestamp 可配合）。',
    code:
      'import { DateUtil } from \'@ohos/common\'\n' +
      '\n' +
      'const s = DateUtil.getFormatDateStr(Date.now(), \'yyyy-MM-dd HH:mm:ss\')\n' +
      'const today = DateUtil.getTodayStr() // 默认格式见库内 DATE_FORMAT1\n' +
      'const d = DateUtil.getFormatDate(\'1700000000000\') // 归一化为 Date'
  },
  {
    title: 'StrUtil',
    detail:
      '字符串判空、裁剪、脱敏、拼接等高频操作，减少 NPE 与重复 if (x === null)。\n' +
      '与 RegexUtil 分工：复杂匹配优先 RegexUtil。',
    code:
      'import { StrUtil } from \'@ohos/common\'\n' +
      '\n' +
      'if (StrUtil.isNotEmpty(name)) {\n' +
      '  const trimmed = StrUtil.trim(name)\n' +
      '}'
  },
  {
    title: 'Base64Util',
    detail:
      'Base64 编解码封装，常用于二进制与文本互转、与后端协定的头部/体编码。\n' +
      '加解密场景更多与 CryptoHelper、CryptoUtil 搭配。',
    code:
      'import { Base64Util } from \'@ohos/common\'\n' +
      '\n' +
      'const bytes = new Uint8Array([104, 101, 108, 108, 111]) // "hello"\n' +
      'const b64 = Base64Util.encodeToStrSync(bytes)\n' +
      'const back = Base64Util.decodeSync(b64)'
  },
  {
    title: 'NumberUtil',
    detail:
      '安全转数字、保留小数、范围 clamp、千分位格式化等，避免 parseFloat 散落与 NaN。\n' +
      '金额类仍建议 bigint 或业务层 decimal 方案。',
    code:
      'import { NumberUtil } from \'@ohos/common\'\n' +
      '\n' +
      'const n = NumberUtil.toInt(\'12\', 0)\n' +
      'const x = NumberUtil.keepDecimals(3.1415, 2) // 保留小数'
  },
  {
    title: 'JSONUtil',
    detail:
      'JSON 序列化/反序列化封装，统一 try-catch 与默认值，避免 JSON.parse 抛异常打断流程。\n' +
      '与 ArkTS 严格类型结合时，反序列化后仍要做字段校验。',
    code:
      'import { JSONUtil } from \'@ohos/common\'\n' +
      '\n' +
      'interface User { id: number; name: string }\n' +
      'const u = JSONUtil.jsonToBean<User>(jsonStr) // 可传 Class 做 plainToClass\n' +
      'const str = JSONUtil.beanToJsonStr(u as Object)'
  },
  {
    title: 'AssetUtil',
    detail:
      'rawfile / 资源路径读取等辅助，适合读内置配置、离线 bundle。\n' +
      '路径与 module 资源规则需符合 Harmony 资源目录约定。',
    code:
      'import { AssetUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 按库方法读取 rawfile 文本或 buffer\n' +
      'const raw = AssetUtil.getRawFileContent(\'config.json\')'
  },
  {
    title: 'CryptoUtil',
    detail:
      '对称/摘要等底层封装入口之一，供 MD5、AES 等上层类调用；也可直接 digest、生成密钥等。\n' +
      '涉及国密、硬件密钥需按安全规范选型，勿在日志打印密钥明文。',
    code:
      'import { CryptoUtil } from \'@ohos/common\'\n' +
      '\n' +
      '// 字符串摘要，resultCoding 支持 hex / base64 等（见 crypto.BhCoding）\n' +
      'const hex = await CryptoUtil.digest(\'hello\', \'SHA256\', \'hex\')\n' +
      'const hexSync = CryptoUtil.digestSync(\'hello\', \'MD5\', \'hex\')'
  },
  {
    title: 'RSA',
    detail:
      'RSA 非对称加解密、签名验签封装（基于 cryptoFramework）。\n' +
      '密钥生成较慢，建议缓存 KeyPair；明文长度受密钥长度与填充限制。',
    code:
      'import { RSA } from \'@ohos/common\'\n' +
      'import { cryptoFramework } from \'@ohos.security.cryptoFramework\'\n' +
      '\n' +
      '// 需先准备 PubKey / PriKey（CryptoUtil 等生成），再加密：\n' +
      'const cipherBlob: cryptoFramework.DataBlob = await RSA.encrypt(plainBlob, pubKey, \'RSA2048|PKCS1\')'
  },
  {
    title: 'MD5',
    detail:
      'MD5 摘要工具，常用于校验码、非安全场景指纹；**不应用于密码存储**。\n' +
      '库中 digest 多为异步 Promise，注意 await 与错误处理。',
    code:
      'import { MD5 } from \'@ohos/common\'\n' +
      '\n' +
      'const hex = await MD5.digest(\'hello\', \'hex\')\n' +
      'const b64 = await MD5.digest(\'hello\', \'base64\')'
  },
  {
    title: 'AES',
    detail:
      'AES 对称加解密（GCM/CBC 等模式以库实现为准），配合 CryptoHelper 做字符串与 DataBlob 互转。\n' +
      '妥善保存 IV、Tag；密钥来自安全存储或协商，勿硬编码在仓库。',
    code:
      'import { AES } from \'@ohos/common\'\n' +
      'import { cryptoFramework } from \'@ohos.security.cryptoFramework\'\n' +
      '\n' +
      '// GCM 加密示意（参数需按业务填充）\n' +
      'const blob: cryptoFramework.DataBlob = { data: new Uint8Array([1,2,3]) }\n' +
      'const out = await AES.encryptGCM(blob, symKey, gcmParams)'
  },
  {
    title: 'CryptoHelper',
    detail:
      '加解密前后数据形态转换：字符串 ↔ Uint8Array ↔ DataBlob，指定 utf8/hex/base64 等编码。\n' +
      '写算法逻辑前先统一用 Helper 转类型，减少 ArkTS 类型与 cryptoFramework 不匹配问题。',
    code:
      'import { CryptoHelper } from \'@ohos/common\'\n' +
      '\n' +
      '// coding 为 crypto.BhuCoding：utf8 / hex / base64 等\n' +
      'const blob = CryptoHelper.strToDataBlob(\'hello\', \'utf8\')\n' +
      'const back = CryptoHelper.dataBlobToStr(blob, \'utf8\')'
  }
]
