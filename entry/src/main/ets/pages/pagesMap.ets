
import {FlutterTestPage} from './FlutterTestPage'
import { PageTwo } from './PageTwo';
import { Home } from  '@ohos/home'
import { Mine } from  '@ohos/mine'
import { MainPage } from  './MainPage'
import {  RouteConstants} from '@ohos/common';


@Builder
function pagesMap(name: string) {
  if (name === RouteConstants.FLUTTER_TEST_PAGE) {
    FlutterTestPage()
  } else if (name === RouteConstants.MAIN_PAGE) {
    MainPage()
  }else if (name === RouteConstants.HOME) {
    Home()
  }else if (name === RouteConstants.MINE) {
    Mine()
  }else if (name === RouteConstants.EVALUATE_ENTRY) {
    Mine()
  }


}

export const pagesMapBuilder: WrappedBuilder<[string]> = wrapBuilder(pagesMap);


