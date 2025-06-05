import { MainHeader } from '../header/MainHeader'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { BusinessError } from '@kit.BasicServicesKit'
import fileIo from '@ohos.file.fs'
import { image } from '@kit.ImageKit'
import textRecognition from '@hms.ai.ocr.textRecognition'
import { promptAction } from '@kit.ArkUI'

const TEXT_RECOGNITION_LABEL = "文字识别"

@Entry
@Component
struct TextRecognitionPage {
  @State mSelectImage: PixelMap | undefined = undefined
  @State mRecognitionText: string = ''

  build() {
    Column() {
      MainHeader({
        toolbarOption: {
          title: "文字识别-图片"
        }
      })
        .width('100%')

      Image(this.mSelectImage)
        .objectFit(ImageFit.Contain)
        .height('50%')

      Scroll() {
        Text(this.mRecognitionText)
          .fontColor(Color.Black)
          .fontColor(18)
          .copyOption(CopyOptions.LocalDevice)
      }
      .width('100%')
      .layoutWeight(1)

      Button("选择图片")
        .fontColor(Color.White)
        .fontSize(16)
        .type(ButtonType.Capsule)
        .backgroundColor("#0x317AE7")
        .width("80%")
        .height(50)
        .margin(10)
        .onClick(() => {
          this.openPhoneAlbum()
        })

      Button("识别图片")
        .fontColor(Color.White)
        .fontSize(16)
        .type(ButtonType.Capsule)
        .backgroundColor("#0x317AE7")
        .width("80%")
        .height(50)
        .margin(10)
        .onClick(() => {
          this.recognitionImage()
        })
    }
  }

  recognitionImage() {
    if (!this.mSelectImage) {
      promptAction.showToast({
        message: "请先设置图片",
        duration: 2000
      })
      return
    }
    // 待识别的图片
    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: this.mSelectImage
    }
    let textRecognitionConfig: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: false
    }
    textRecognition.recognizeText(visionInfo, textRecognitionConfig,
      (err: BusinessError, data: textRecognition.TextRecognitionResult) => {
        if (!err || err.code != 0) {
          return
        }
        this.mRecognitionText = data.value
      })
  }

  openPhoneAlbum() {
    let photoPicker = new photoAccessHelper.PhotoViewPicker()
    photoPicker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    }, (err: BusinessError, data: photoAccessHelper.PhotoSelectResult) => {
      if (!err) {
        let pathList = data.photoUris
        if (pathList && pathList.length > 0) {
          let file = fileIo.openSync(pathList[0], fileIo.OpenMode.READ_ONLY)
          this.mSelectImage = image.createImageSource(file.fd).createPixelMapSync()
        }
      } else {
        console.error(TEXT_RECOGNITION_LABEL, "err=" + JSON.stringify(err))
      }
    })
  }
}