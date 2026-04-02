import { FlutterTestPage } from './FlutterTestPage';
import { Graphics, Home, RichTextExpand, TextExpand } from '@ohos/home';
import { Mine } from '@ohos/mine';
import { MainPage } from './MainPage';
import { RouteConstants } from '@ohos/common';


@Builder
function pagesMap(name: string) {
  if (name === RouteConstants.FLUTTER_TEST_PAGE) {
    FlutterTestPage()
  } else if (name === RouteConstants.MAIN_PAGE) {
    MainPage()
  } else if (name === RouteConstants.HOME) {
    Home()
  } else if (name === RouteConstants.MINE) {
    Mine()
  } else if (name === RouteConstants.EVALUATE_ENTRY) {
    Mine()
  } else if (name === RouteConstants.GRAPHICS) {
    Graphics()
  } else if (name === RouteConstants.RICH_TEXT_EXPAND) {
    RichTextExpand()
  } else if (name === RouteConstants.TEXT_EXPAND) {
    TextExpand()
  }
}

export const pagesMapBuilder: WrappedBuilder<[string]> = wrapBuilder(pagesMap);


