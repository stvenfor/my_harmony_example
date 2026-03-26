
import {FlutterTestPage} from './FlutterTestPage'
import { PageTwo } from './PageTwo';

@Builder
function pagesMap(name: string) {
  if (name === 'FlutterTestPage') {
    FlutterTestPage()
  } else if (name === 'PageTwo') {
    PageTwo()
  }
}

export const pagesMapBuilder: WrappedBuilder<[string]> = wrapBuilder(pagesMap);


