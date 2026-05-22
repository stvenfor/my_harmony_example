import { NestedListCardItem } from './NestedListCardItem'

export class NestedListClassifyModel {
  classifyId: number
  classifyName: ResourceStr
  courseList: NestedListCardItem[]

  constructor(classifyId: number, classifyName: ResourceStr, courseList: NestedListCardItem[]) {
    this.classifyId = classifyId
    this.classifyName = classifyName
    this.courseList = courseList
  }
}
