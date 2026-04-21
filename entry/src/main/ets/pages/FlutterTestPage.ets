import { FlutterEntry, FlutterPage, FlutterPlugin, FlutterView,FlutterEngine } from '@ohos/flutter_ohos';
import TestPlugin from '../entryability/TestPlugin';
import { common } from '@kit.AbilityKit';

@Component
export struct  FlutterTestPage{
  @State message: string | Resource | undefined = 'dj';
  private context = getContext(this) as common.UIAbilityContext
  private flutterEntry: FlutterEntry | null = null;
  private flutterView?: FlutterView
  @Consume("pathStack") pathStack: NavPathStack
  private flutterPlugin?: FlutterPlugin
  private flutterEngine?: FlutterEngine



  aboutToAppear() {
    // 先初始化FlutterEntry
    // let route: Record<string, string> = { 'route': '/EvaluateEntry' }
    // this.flutterEntry = new FlutterEntry(getContext(this), route as Record<string, Object>)
    //
    // this.flutterEntry.aboutToAppear()
    // this.flutterView = this.flutterEntry.getFlutterView()

    // 引擎初始化后添加插件
    // this.onFirstFrame()
  }

  aboutToDisappear() {
    this.flutterEntry?.aboutToDisappear()
    this.flutterEntry?.getFlutterEngine()?.getPlugins()?.remove(this.flutterPlugin?.getUniqueClassName())
  }

  onFirstFrame() {
    this.flutterPlugin = new TestPlugin()
    this.flutterEntry?.getFlutterEngine()?.getPlugins()?.add(this.flutterPlugin)
  }
  //
  // onPageShow() {
  //   this.flutterEntry?.onPageShow()
  // }
  //
  // onPageHide() {
  //   this.flutterEntry?.onPageHide()
  // }

  build() {
    NavDestination() {
        FlutterPage({ viewId: this.flutterView?.getId()  })
    }
    // .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.init(context)
    })
    .onDisAppear(() => {
      this.flutterEntry?.aboutToDisappear()
    })
    .onShown(() => {
      this.flutterEntry?.onPageShow()
    })
    .onHidden(() => {
      this.flutterEntry?.onPageHide()
    })
    .onBackPressed(() => {
      this.context.eventHub.emit('EVENT_BACK_PRESS')
      return true
    }).title('flutter 页面')

  }

  init(context: NavDestinationContext) {
    let array = this.pathStack.getParamByName('FlutterTestPage') as Array<Record<string, Object>>;
    let params: Record<string, Object> = array.length > 0 ? array[0] : {};
    this.flutterEntry = new NavFlutterEntry(getContext(this), params, this.pathStack)
    this.flutterEntry.aboutToAppear()
    this.flutterView = this.flutterEntry.getFlutterView()

    // 引擎初始化后添加插件
    this.onFirstFrame()
  }
}

class NavFlutterEntry extends FlutterEntry {
  pathStack?: NavPathStack;

  constructor(context: Context, params: Record<string, Object> = {}, pathStack?: NavPathStack) {
    super(context, params)
    this.pathStack = pathStack;
  }

  popSystemNavigator(): boolean {
    if (this.pathStack) {
      this.pathStack.pop();
      return true;
    }
    return false;
  }
}



