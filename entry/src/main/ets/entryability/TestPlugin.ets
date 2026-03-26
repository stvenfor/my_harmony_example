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

const TAG = "TestPluginTag";

export default class TestPlugin implements FlutterPlugin {
  private channel?: MethodChannel;
  private basicChannel?: BasicMessageChannel<Any>;
  private eventChannel?: EventChannel;
  private eventSink?: EventSink;
  private loginInfoApi = new LoginInfoApi();

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
          case "callEvent":
            that.eventSink?.success("Success at " + new Date());
            break;
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
  getLoginUserInfo(result: MethodResult) {
    let wrapped: Map<String, Any> = new Map<String, Any>();
    wrapped.set("uid", "32343");
    wrapped.set("nickname", "asijh");
    wrapped.set("avatar", "https://avatars.githubusercontent.com/u/1020407?v=4");
    wrapped.set("study_stage_grade", "123456");
    wrapped.set("dif_level", "1");
    wrapped.set("station", "1");
    wrapped.set("sex", "1");
    wrapped.set("user_number", "123456-----22333333434")    
    result.success(wrapped);
  }
}


