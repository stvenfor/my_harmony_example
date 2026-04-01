
import {FlutterTestPage} from './FlutterTestPage'
import { PageTwo } from './PageTwo';
import { Home } from  '@ohos/home'
import { Mine } from  '@ohos/mine'
import { AddFormMenuItem } from '@ohos.arkui.advanced.FormMenu';


@Builder
function pagesMap(name: string) {
  if (name === 'FlutterTestPage') {
    FlutterTestPage()
  } else if (name === 'PageTwo') {
    PageTwo()
  }else if (name === 'Home') {
    Home()
  }else if (name === 'Mine') {
    Mine()
  }


}

export const pagesMapBuilder: WrappedBuilder<[string]> = wrapBuilder(pagesMap);


