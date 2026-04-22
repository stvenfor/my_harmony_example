import { FlutterTestPage } from './FlutterTestPage';
import { Graphics, Home, RichTextExpand, TextExpand } from '@ohos/home';
import { GridRowDemo, Mine } from '@ohos/mine';
import { MainPage } from './MainPage';
import { RouteConstants } from '@ohos/common';
import { ReferenceResPage,FoodPage,NewsPage,TravelPage,EducationPage,ShopPage } from '@ohos/home'

import {
  BasicExample,
  Example1,
  Example2,
  Example3,
  Example4,
  NetWorkExample,
  SingleExample,
  SpecialAnimation,
  SpinePage
} from '@ohos/spine_animation';
import { TreeView } from '@kit.ArkUI';
import { Travel } from './Index';


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
  } else if (name === RouteConstants.SPINE_ANIMATION) {
    SpinePage()
  } else if (name === RouteConstants.SPINE_EXAMPLE1) {
    Example1()
  } else if (name === RouteConstants.SPINE_NETWORK_EXAMPLE) {
    NetWorkExample()
  } else if (name === RouteConstants.SPINE_SINGLE_EXAMPLE) {
    SingleExample()
  } else if (name === RouteConstants.SPINE_EXAMPLE2) {
    Example2()
  } else if (name === RouteConstants.SPINE_EXAMPLE3) {
    Example3()
  } else if (name === RouteConstants.SPINE_EXAMPLE4) {
    Example4()
  } else if (name === RouteConstants.BASIC_EXAMPLE4) {
    BasicExample()
  } else if (name === RouteConstants.SPECIAL_ANIMATION) {
    SpecialAnimation()
  } else if (name === RouteConstants.GIRD_ROW_DEMO) {
    GridRowDemo()
  }  else if (name === RouteConstants.REFERENCE_RES_PAGE) {
     ReferenceResPage()
  }else if (name === RouteConstants.FOOD_PAGE) {
    FoodPage()
  }
  else if (name === RouteConstants.NEWS_PAGE) {
    NewsPage()
  }else if (name === RouteConstants.TRAVEL_PAGE) {
    TravelPage()
  }else if (name === RouteConstants.EDUCATION_PAGE) {
    EducationPage()
  }else if (name === RouteConstants.SHOP_PAGE) {
    ShopPage()
  }
}

export const pagesMapBuilder: WrappedBuilder<[string]> = wrapBuilder(pagesMap);

