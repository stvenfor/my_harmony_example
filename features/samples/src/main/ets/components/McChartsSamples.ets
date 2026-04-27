import { PageHeaderComp } from "@ohos/common"
import {
  McLineChart,
  McBarChart,
  McHorBarChart,
  McPieChart,
  McRadarChart,
  McGaugeChart,
  McLineBarChart,
  Options
} from '@mcui/mccharts'

@Component
export struct McChartsSamples {

  @Consume pathStack: NavPathStack

  @State lineOption: Options = new Options({
    xAxis: {
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    yAxis: {
      name: '温度(°C)'
    },
    series: [
      {
        name: '最高气温',
        data: [11, 11, 15, 13, 12, 13, 10]
      },
      {
        name: '最低气温',
        data: [1, -2, 2, 5, 3, 2, 0]
      }
    ]
  })

  @State barOption: Options = new Options({
    xAxis: {
      data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    },
    yAxis: {
      name: '销量'
    },
    series: [
      {
        name: '产品A',
        data: [120, 200, 150, 80, 70, 110, 130]
      },
      {
        name: '产品B',
        data: [60, 100, 80, 45, 50, 75, 90]
      }
    ]
  })



  @State horBarOption: Options = new Options({
    xAxis: {
      type: 'value'
    },
    yAxis: {
      type: 'category',
      data: ['巴西', '印尼', '美国', '印度', '中国']
    },
    series: [
      {
        name: '人口数量',
        data: [2.1, 2.7, 3.3, 13.8, 14.4]
      }
    ]
  })

  @State gaugeOption: Options = new Options({
    series: [
      {
        name: '完成率',
        type: 'gauge',
        data: [{ value: 75, name: '完成度' }]
      }
    ]
  })

  @State lineBarOption: Options = new Options({
    xAxis: {
      data: ['1月', '2月', '3月', '4月', '5月', '6月']
    },
    yAxis: {},
    legend: {
      show: true
    },
    series: [
      {
        name: '销售额',
        type: 'bar',
        data: [20000, 35000, 28000, 42000, 38000, 45000]
      },
      {
        name: '增长率',
        type: 'line',
        data: [15, 25, 18, 32, 28, 35]
      }
    ]
  })

  @State pieOption: Options = new Options({
    series: [
      {
        name: '访问来源',
        data: [
          { value: 335, name: '直接访问' },
          { value: 310, name: '邮件营销' },
          { value: 234, name: '联盟广告' },
          { value: 135, name: '视频广告' },
          { value: 1548, name: '搜索引擎' }
        ]
      }
    ]
  })

  @State radarOption: Options = new Options({
    radar: {
      indicator: [
        { name: '销售', max: 6500 },
        { name: '管理', max: 16000 },
        { name: '信息技术', max: 30000 },
        { name: '客服', max: 38000 },
        { name: '研发', max: 52000 },
        { name: '市场', max: 25000 }
      ]
    },
    series: [
      {
        name: '预算 vs 开销',
        data: [
          [4300, 10000, 28000, 35000, 50000, 19000],
          [5000, 14000, 28000, 31000, 42000, 21000]
        ]
      }
    ]
  })

  aboutToAppear(): void {
    setTimeout(() => {
      this.lineOption.setVal({
        series: [
          {
            name: '最高气温',
            data: [110, 110, 150, 130, 120, 190, 100]
          }
        ]
      })
    }, 2000)
  }

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: 'McCharts 图表示例',
          backAction: () => {
            this.pathStack.pop()
          }
        })

        Scroll() {
          Column() {
            ChartSection({
              title: '折线图',
              description: '展示数据变化趋势，支持动态更新',
              chartHeight: 300
            }) {
              McLineChart({
                options: this.lineOption
              })
            }

            ChartSection({
              title: '柱状图',
              description: '对比不同类别的数据大小',
              chartHeight: 300
            }) {
              McBarChart({
                options: this.barOption
              })
            }

            ChartSection({
              title: '横向柱状图',
              description: '适合展示排名或分类对比',
              chartHeight: 300
            }) {
              McHorBarChart({
                options: this.horBarOption
              })
            }

            ChartSection({
              title: '饼图',
              description: '展示各部分占比关系',
              chartHeight: 350
            }) {
              McPieChart({
                options: this.pieOption
              })
            }

            ChartSection({
              title: '雷达图',
              description: '多维度数据对比分析',
              chartHeight: 350
            }) {
              McRadarChart({
                options: this.radarOption
              })
            }

            ChartSection({
              title: '仪表盘',
              description: '直观展示关键指标完成度',
              chartHeight: 300
            }) {
              McGaugeChart({
                options: this.gaugeOption
              })
            }

            ChartSection({
              title: '折柱混合图',
              description: '同时展示数量和趋势',
              chartHeight: 300
            }) {
              McLineBarChart({
                options: this.lineBarOption
              })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f5f5')
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}

@Component
struct ChartSection {
  @Prop title: string = ''
  @Prop description: string = ''
  @Prop chartHeight: number = 300
  @BuilderParam children: () => void

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.title)
            .fontSize(18)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)

          Text(this.description)
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ bottom: 12 })

      Column() {
        this.children()
      }
      .width('100%')
      .height(this.height)
      .padding(12)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({
        radius: 4,
        color: '#0f000000',
        offsetX: 0,
        offsetY: 2
      })
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
  }
}
