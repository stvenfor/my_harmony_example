import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { detectBarcode, generateBarcode, scanBarcode, scanCore } from '@kit.ScanKit'
import { NavItem, StringConstants } from '@ohos/common'

const TAG: string = 'ScanKitDemoPage'

@Component
export struct ScanKitDemoPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State resultText: string = '暂无扫码结果'
  @State qrContent: string = 'https://gitcode.com/HarmonyOS_Samples/scankit-samplecode-clientdemo-arkts'
  @State generatedCode: image.PixelMap | undefined = undefined
  @State isGenerating: boolean = false

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 2000 })
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: showToast failed. Code: ${err.code}, message: ${err.message}`)
    }
  }

  private formatScanResult(result: scanBarcode.ScanResult): string {
    return `内容：${result.originalValue ?? ''}\n类型：${result.scanType}`
  }

  private handleError(error: BusinessError, fallback: string): void {
    console.error(`${TAG}: ${fallback}. Code: ${error.code}, message: ${error.message}`)
    this.showToast(error.message || fallback)
  }

  private startDefaultScan(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    const options: scanBarcode.ScanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: true,
      enableAlbum: true
    }

    try {
      scanBarcode.startScanForResult(context, options)
        .then((result: scanBarcode.ScanResult) => {
          this.resultText = this.formatScanResult(result)
          this.showToast('扫码成功')
        })
        .catch((error: BusinessError) => {
          if (error.code === scanCore.ScanErrorCode.SCAN_SERVICE_CANCELED) {
            console.info(`${TAG}: scan canceled`)
            return
          }
          this.handleError(error, '启动默认扫码失败')
        })
    } catch (error) {
      this.handleError(error as BusinessError, '启动默认扫码失败')
    }
  }

  private decodeFromAlbum(): void {
    const photoOption = new photoAccessHelper.PhotoSelectOptions()
    photoOption.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    photoOption.maxSelectNumber = 1
    photoOption.isEditSupported = false

    const photoPicker = new photoAccessHelper.PhotoViewPicker()
    photoPicker.select(photoOption)
      .then((photoResult: photoAccessHelper.PhotoSelectResult) => {
        const uri = photoResult.photoUris[0]
        if (!uri) {
          this.showToast('未选择图片')
          return
        }

        try {
          const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
          fileIo.closeSync(file)
        } catch (error) {
          this.handleError(error as BusinessError, '读取图片失败')
          return
        }

        const inputImage: detectBarcode.InputImage = { uri }
        const options: scanBarcode.ScanOptions = {
          scanTypes: [scanCore.ScanType.ALL],
          enableMultiMode: true,
          enableAlbum: true
        }

        detectBarcode.decode(inputImage, options)
          .then((results: Array<scanBarcode.ScanResult>) => {
            if (!results || results.length === 0) {
              this.showToast('未识别到码')
              return
            }
            this.resultText = results.map((result: scanBarcode.ScanResult, index: number) => {
              return `#${index + 1}\n${this.formatScanResult(result)}`
            }).join('\n\n')
            this.showToast('图片识别成功')
          })
          .catch((error: BusinessError) => {
            this.handleError(error, '图片识别失败')
          })
      })
      .catch((error: BusinessError) => {
        this.handleError(error, '选择图片失败')
      })
  }

  private generateQrCode(): void {
    if (!this.qrContent.trim()) {
      this.showToast('请输入二维码内容')
      return
    }

    this.isGenerating = true
    this.generatedCode = undefined
    const options: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      height: 800,
      width: 800,
      margin: 2,
      level: generateBarcode.ErrorCorrectionLevel.LEVEL_H,
      backgroundColor: 0xFFFFFF,
      pixelMapColor: 0x000000
    }

    try {
      generateBarcode.createBarcode(this.qrContent, options)
        .then((result: image.PixelMap) => {
          this.generatedCode = result
          this.showToast('二维码生成成功')
        })
        .catch((error: BusinessError) => {
          this.handleError(error, '二维码生成失败')
        })
        .finally(() => {
          this.isGenerating = false
        })
    } catch (error) {
      this.isGenerating = false
      this.handleError(error as BusinessError, '二维码生成失败')
    }
  }

  @Builder
  private actionButton(label: string, icon: Resource, action: () => void) {
    Button() {
      Row({ space: 8 }) {
        SymbolGlyph(icon)
          .fontSize(18)
          .fontColor([Color.White])
        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .height(44)
    .width('100%')
    .borderRadius(22)
    .backgroundColor('#0A59F7')
    .onClick(action)
  }

  build() {
    NavDestination() {
      Column() {
        NavItem({ showBack: true, title: 'Scan Kit 示例' })

        Scroll() {
        Column({ space: 16 }) {
          Column({ space: 10 }) {
            Text('扫码能力')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .width('100%')
            Text('参考官方 scankit-samplecode-clientdemo-arkts，集成默认扫码、相册识别与二维码生成。')
              .fontSize(13)
              .lineHeight(20)
              .fontColor('#99182431')
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          Column({ space: 12 }) {
            this.actionButton('默认界面扫码', $r('sys.symbol.search_things'), () => {
              this.startDefaultScan()
            })
            this.actionButton('从相册识别', $r('sys.symbol.ohos_folder_badge_plus'), () => {
              this.decodeFromAlbum()
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)

          Column({ space: 12 }) {
            Text('二维码生成')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .width('100%')
            TextArea({ text: this.qrContent, placeholder: '输入二维码内容' })
              .height(76)
              .fontSize(14)
              .backgroundColor('#F4F6F8')
              .borderRadius(10)
              .onChange((value: string) => {
                this.qrContent = value
              })
            this.actionButton(this.isGenerating ? '生成中...' : '生成二维码', $r('sys.symbol.checkmark_circle'), () => {
              this.generateQrCode()
            })
            if (this.generatedCode) {
              Image(this.generatedCode)
                .width(220)
                .height(220)
                .objectFit(ImageFit.Contain)
                .alignSelf(ItemAlign.Center)
                .margin({ top: 4 })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)

          Column({ space: 8 }) {
            Text('识别结果')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .width('100%')
            Text(this.resultText)
              .fontSize(14)
              .lineHeight(21)
              .fontColor('#66182431')
              .width('100%')
              .copyOption(CopyOptions.LocalDevice)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
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
    .backgroundColor('#F2F3F5')
  }
  .hideTitleBar(true)
  .onReady((context: NavDestinationContext) => {
    this.pathStack = context.pathStack
  })
  .title('Scan Kit 示例')
}
}
