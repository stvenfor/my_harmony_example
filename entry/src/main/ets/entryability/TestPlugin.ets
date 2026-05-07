import {
  AbilityPluginBinding,
  Any,
  BasicMessageChannel,
  EventChannel,
  FlutterPlugin,
  Log,
  MethodCall,
  MethodChannel,
  StandardMessageCodec
} from '@ohos/flutter_ohos';
import { FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';

import { MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import { EventSink } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';
import { Reply } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BasicMessageChannel';
import { buildCommonQueryMapWithTimestamp } from '@ohos/common'
import { HttpHeaderUtil } from '@ohos/home'
const TAG = "TestPluginTag";






export default class TestPlugin implements FlutterPlugin {
  private channel?: MethodChannel;
  private basicChannel?: BasicMessageChannel<Any>;
  private eventChannel?: EventChannel;
  private eventSink?: EventSink;
  private loginInfoApi = new LoginInfoApi();


  static readonly commonNetConfig: string = "commonNetConfig"; // 通用网络配置
  static readonly finishActivity: string = "finishActivity"; // 关闭指定界面，兼容android-pop失效问题
  static readonly NewbieGuideFlutterActivity: string = "NewbieGuideFlutterActivity"; // 新手引导页名称
  static readonly handlerScheme: string = "handlerScheme"; // 处理scheme
  static readonly getMasterUserInfo: string = "getMasterUserInfo"; // 获取宿主的用户信息
  static readonly isReleaseBuild: string = "isReleaseBuild"; // 是否构建正式版本
  static readonly share: string = "share"; // 分享事件
  static readonly shareResult: string = "shareResult"; // 原生分享结果回调
  static readonly response403: string = "response403"; // 403，被挤出登录
  static readonly dubPracticeCompleted: string = "dubPracticeCompleted"; // 配音练习完成
  static readonly isListeningPlaying: string = "isListeningPlaying"; // 停止听力
  static readonly stopListening: string = "stopListening"; // 停止听力
  static readonly alterUserinfo: string = "alterUserinfo"; // 修改用户信息
  static readonly loginUserInfo: string = "loginUserInfo"; // 当前登录的用户的信息
  static readonly toMiniProgram: string = "toMiniProgram"; // 跳转小程序
  static readonly toAppStore: string = "toAppStore"; // 跳转appstore
  static readonly showToast: string = "showToast"; // 调用源生toast

  static readonly baseBack: string = "baseBack";

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(TAG, "onAttachedToAbility")
  }

  onDetachedFromAbility(): void {
    Log.i(TAG, "onDetachedFromAbility")
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, "onAttachedToEngine");
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_base_channel");
    let that = this;
    this.channel.setMethodCallHandler({
      onMethodCall(call: MethodCall, result: MethodResult) {
        switch (call.method) {
          case "loginUserInfo":
            that.loginInfoApi.getLoginUserInfo(result);
            break;
          case "isReleaseBuild":
            that.loginInfoApi.getBuildVariant(result);
            break;
            case TestPlugin.commonNetConfig:
            that.loginInfoApi.getCommonNetConfig(result);
          default:
            result.notImplemented();
            break;
        }
      }
    })

    this.basicChannel = new BasicMessageChannel(binding.getBinaryMessenger(), "samples.flutter.dev/basic_channel",
      new StandardMessageCodec());
    this.basicChannel.setMessageHandler({
      onMessage(message: Any, reply: Reply<Any>) {
        Log.i(TAG, "message=" + message);
        if (message % 2 == 0) {
          reply.reply("run with if case.");
        } else {
          reply.reply("run with else case");
        }
      }
    })

    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), "samples.flutter.dev/event_channel");
    this.eventChannel.setStreamHandler({
      onListen(args: Any, events: EventSink): void {
        that.eventSink = events;
        Log.i(TAG, "onListen: " + args);
      },
      onCancel(args: Any): void {
        that.eventSink = undefined;
        Log.i(TAG, "onCancel: " + args);
      }
    });
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Log.i(TAG, "onDetachedFromEngine");
    this.channel?.setMethodCallHandler(null);
    this.eventChannel?.setStreamHandler(null);

  }

  getUniqueClassName(): string {
    return "TestPlugin";
  }
}


class LoginInfoApi {
  async getCommonNetConfig(result: MethodResult) {

    let wrapped: Map<String, Any> = new Map<String, Any>();
    wrapped.set("status", "1");
    wrapped.set("msg", "success");
    wrapped.set("headerMap", await HttpHeaderUtil.getHttpHeaderDic());
    wrapped.set("commonQueryMap", await buildCommonQueryMapWithTimestamp());
    result.success(wrapped);

  }
  getLoginUserInfo(result: MethodResult) {
    let wrapped: Map<String, Any> = new Map<String, Any>();
    wrapped.set("uid", "68770720");
    wrapped.set("nickname", "小趣友_ohpuz2");
    wrapped.set("auth_token", "MTc3OTg0NjIxNLGdyGWBsaaXr814cg");
    wrapped.set("avatar", "https://avatars.githubusercontent.com/u/1020407?v=4");
    wrapped.set("study_stage_grade", "12");
    wrapped.set("dif_level", "1");
    wrapped.set("station", "1");
    wrapped.set("sex", "1");
    wrapped.set("user_number", "69054013")
    wrapped.set("refresh_token", "MTc3OTAxNzA4MrGdyGWBsaaXr7d8cg")
    wrapped.set("auth_mobile", "14474631574")
    result.success(wrapped);
  }

  getBuildVariant(result: MethodResult) {
    let wrapped: Map<String, Any> = new Map<String, Any>();
    wrapped.set("status", "1");
    wrapped.set("isRelease", true);
    result.success(wrapped);
  }
}


