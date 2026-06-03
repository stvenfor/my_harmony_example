import { NavItem, StringConstants } from '@ohos/common'
import { BusinessError } from '@kit.BasicServicesKit'

const TAG: string = 'MultiDeviceCommunicationPage'

interface DeviceInfo {
  readonly deviceId: string
  readonly deviceName: string
  readonly deviceType: string
  readonly online: boolean
}

@Component
export struct MultiDeviceCommunicationPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  
  @State discoveredDevices: DeviceInfo[] = []
  @State selectedDevices: string[] = []
  @State isDiscovering: boolean = false
  @State connectionStatus: string = '未连接'
  @State messageLog: string[] = []
  @State sendMessageText: string = ''
  
  private readonly accent: string = '#0A59F7'
  private readonly cardBg: string = '#FFFFFF'
  private readonly pageBg: string = '#F2F3F5'

  aboutToAppear(): void {
    this.initDeviceManager()
  }

  aboutToDisappear(): void {
    this.stopDiscovery()
  }

  private initDeviceManager(): void {
    // 模拟初始化
    this.showToast('设备管理器初始化成功（演示模式）')
    this.addMessageLog('设备管理器已就绪')
  }

  private registerDeviceListeners(): void {
    // 模拟监听器注册
    console.info(`${TAG}: Listeners registered (demo mode)`)
  }

  private getDeviceType(typeId: number): string {
    switch (typeId) {
      case 1:
        return '手机'
      case 2:
        return '平板'
      case 3:
        return '智慧屏'
      case 4:
        return '手表'
      case 5:
        return '车机'
      default:
        return '其他设备'
    }
  }

  private startDiscovery(): void {
    if (this.isDiscovering) {
      this.showToast('正在扫描中...')
      return
    }

    this.isDiscovering = true
    this.addMessageLog('开始扫描附近设备...')
    this.showToast('开始扫描设备（演示模式）')
    
    // 模拟发现设备
    setTimeout(() => {
      const mockDevices: DeviceInfo[] = [
        { deviceId: 'device_001', deviceName: 'Mate 60 Pro', deviceType: '手机', online: true },
        { deviceId: 'device_002', deviceName: 'MatePad Pro', deviceType: '平板', online: true },
        { deviceId: 'device_003', deviceName: '智慧屏 S65', deviceType: '智慧屏', online: true }
      ]
      this.discoveredDevices = mockDevices
      this.addMessageLog(`发现 ${mockDevices.length} 个设备`)
    }, 2000)
  }

  private stopDiscovery(): void {
    if (!this.isDiscovering) return

    this.isDiscovering = false
    this.addMessageLog('停止扫描')
    this.showToast('停止扫描')
  }

  private toggleDeviceSelection(deviceId: string): void {
    const index = this.selectedDevices.indexOf(deviceId)
    if (index === -1) {
      this.selectedDevices = [...this.selectedDevices, deviceId]
      const device = this.discoveredDevices.find(d => d.deviceId === deviceId)
      this.addMessageLog(`选中设备: ${device?.deviceName || deviceId}`)
    } else {
      this.selectedDevices = this.selectedDevices.filter(id => id !== deviceId)
      const device = this.discoveredDevices.find(d => d.deviceId === deviceId)
      this.addMessageLog(`取消选中: ${device?.deviceName || deviceId}`)
    }
  }

  private sendMessage(): void {
    if (this.selectedDevices.length === 0) {
      this.showToast('请先选择目标设备')
      return
    }

    if (!this.sendMessageText.trim()) {
      this.showToast('请输入消息内容')
      return
    }

    // 模拟发送消息
    let successCount = 0
    this.selectedDevices.forEach(deviceId => {
      const device = this.discoveredDevices.find(d => d.deviceId === deviceId)
      this.addMessageLog(`消息已发送至 ${device?.deviceName || deviceId}（演示）`)
      successCount++
    })

    this.showToast(`发送完成: ${successCount} 个设备`)
    this.sendMessageText = ''
  }

  private addMessageLog(message: string): void {
    const timestamp = new Date().toLocaleTimeString('zh-CN', { hour12: false })
    this.messageLog = [...this.messageLog, `[${timestamp}] ${message}`]
    
    // 保留最近50条消息
    if (this.messageLog.length > 50) {
      this.messageLog = this.messageLog.slice(-50)
    }
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 2000 })
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: showToast failed. Code: ${err.code}, message: ${err.message}`)
    }
  }

  @Builder
  private deviceCard(device: DeviceInfo) {
    Row({ space: 12 }) {
      Column() {
        SymbolGlyph($r('sys.symbol.wifi'))
          .fontSize(24)
          .fontColor([this.accent])
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#E8F0FE')
      .borderRadius(12)

      Column({ space: 4 }) {
        Text(device.deviceName)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
        Text(`${device.deviceType} · ${device.online ? '在线' : '离线'}`)
          .fontSize(12)
          .fontColor('#99182431')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Checkbox({ name: device.deviceId })
        .selectedColor(this.accent)
        .select(this.selectedDevices.includes(device.deviceId))
        .onChange((isSelected: boolean) => {
          this.toggleDeviceSelection(device.deviceId)
        })
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.cardBg)
    .borderRadius(12)
  }

  build() {
    NavDestination() {
      Column() {
        NavItem({ showBack: true, title: '多设备通信示例' })

        Scroll() {
          Column({ space: 16 }) {
            // 功能说明
            Column({ space: 8 }) {
              Text('分布式软总线 & 星闪 NearLink')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#182431')
                .width('100%')
              Text('基于 HarmonyOS 分布式能力，实现设备发现、连接与跨设备通信。支持 BLE、Wi-Fi 等多种传输介质。')
                .fontSize(13)
                .lineHeight(20)
                .fontColor('#99182431')
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 设备发现控制
            Column({ space: 12 }) {
              Text('设备发现')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#182431')
                .width('100%')

              Row({ space: 10 }) {
                Button(this.isDiscovering ? '停止扫描' : '开始扫描')
                  .layoutWeight(1)
                  .height(44)
                  .borderRadius(22)
                  .backgroundColor(this.isDiscovering ? '#E64545' : this.accent)
                  .fontColor(Color.White)
                  .onClick(() => {
                    if (this.isDiscovering) {
                      this.stopDiscovery()
                    } else {
                      this.startDiscovery()
                    }
                  })

                Button('清空列表')
                  .layoutWeight(1)
                  .height(44)
                  .borderRadius(22)
                  .backgroundColor('#F4F6F8')
                  .fontColor('#182431')
                  .onClick(() => {
                    this.discoveredDevices = []
                    this.selectedDevices = []
                    this.addMessageLog('已清空设备列表')
                  })
              }
              .width('100%')

              Text(`已发现 ${this.discoveredDevices.length} 个设备，已选中 ${this.selectedDevices.length} 个`)
                .fontSize(13)
                .fontColor('#66182431')
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.cardBg)
            .borderRadius(16)

            // 设备列表
            if (this.discoveredDevices.length > 0) {
              Column({ space: 12 }) {
                Text('可用设备')
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#182431')
                  .width('100%')

                List({ space: 8 }) {
                  ForEach(this.discoveredDevices, (device: DeviceInfo) => {
                    ListItem() {
                      this.deviceCard(device)
                    }
                  }, (device: DeviceInfo) => device.deviceId)
                }
                .width('100%')
                .scrollBar(BarState.Auto)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.cardBg)
              .borderRadius(16)
            }

            // 消息发送
            Column({ space: 12 }) {
              Text('跨设备通信')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#182431')
                .width('100%')

              TextArea({ text: this.sendMessageText, placeholder: '输入要发送的消息' })
                .height(80)
                .fontSize(14)
                .backgroundColor('#F4F6F8')
                .borderRadius(10)
                .onChange((value: string) => {
                  this.sendMessageText = value
                })

              Button('发送消息')
                .width('100%')
                .height(44)
                .borderRadius(22)
                .backgroundColor(this.accent)
                .fontColor(Color.White)
                .enabled(this.selectedDevices.length > 0 && this.sendMessageText.trim().length > 0)
                .onClick(() => {
                  this.sendMessage()
                })

              Text(`当前状态: ${this.connectionStatus}`)
                .fontSize(13)
                .fontColor('#66182431')
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.cardBg)
            .borderRadius(16)

            // 消息日志
            if (this.messageLog.length > 0) {
              Column({ space: 12 }) {
                Row() {
                  Text('消息日志')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#182431')
                    .layoutWeight(1)

                  Button('清空')
                    .fontSize(13)
                    .fontColor(this.accent)
                    .backgroundColor(Color.Transparent)
                    .onClick(() => {
                      this.messageLog = []
                    })
                }
                .width('100%')

                List({ space: 6 }) {
                  ForEach(this.messageLog, (log: string, index: number) => {
                    ListItem() {
                      Text(log)
                        .fontSize(12)
                        .fontColor('#66182431')
                        .width('100%')
                        .lineHeight(18)
                    }
                  }, (log: string, index: number) => `${index}_${log}`)
                }
                .width('100%')
                .height(200)
                .scrollBar(BarState.Auto)
                .edgeEffect(EdgeEffect.Spring)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.cardBg)
              .borderRadius(16)
            }

            // 技术说明
            Column({ space: 12 }) {
              Text('技术说明')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#182431')
                .width('100%')

              Column({ space: 8 }) {
                Text('• 分布式软总线：HarmonyOS 核心分布式能力，自动选择最优传输通道')
                  .fontSize(13)
                  .fontColor('#66182431')
                  .width('100%')
                Text('• 星闪 NearLink：新一代近距离无线通信技术，低时延、高可靠')
                  .fontSize(13)
                  .fontColor('#66182431')
                  .width('100%')
                Text('• 支持协议：BLE、Wi-Fi Direct、USB 等')
                  .fontSize(13)
                  .fontColor('#66182431')
                  .width('100%')
                Text('• 应用场景：多屏协同、文件传输、远程控制、分布式游戏等')
                  .fontSize(13)
                  .fontColor('#66182431')
                  .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F4F6F8')
              .borderRadius(12)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.cardBg)
            .borderRadius(16)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .padding({ top: this.topArea, bottom: this.bottomArea })
      .backgroundColor(this.pageBg)
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .title('多设备通信示例')
  }
}
