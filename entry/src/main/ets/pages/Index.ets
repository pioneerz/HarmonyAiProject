import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      Button("文本转语音")
        .width('80%')
        .height(60)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/TextToSpeechPage'
          })
        })

      Button("语音识别")
        .width('80%')
        .height(60)
        .margin({ top: 10 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SpeechRecognitionPage'
          })
        })

      Button("文字识别-图片")
        .width('80%')
        .height(60)
        .margin({ top: 10 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/TextRecognitionPage'
          })
        })

      Button("相机测试")
        .width('80%')
        .height(60)
        .margin({ top: 10 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/CameraPage'
          })
        })

      Button("文字识别-拍照")
        .width('80%')
        .height(60)
        .margin({ top: 10 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/TextRecognitionCameraPage'
          })
        })
    }
    .height('100%')
    .width('100%')
  }
}