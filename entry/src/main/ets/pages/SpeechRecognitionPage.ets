import { MainHeader } from '../header/MainHeader'
import { speechRecognizer } from '@kit.CoreSpeechKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { AudioCapturer } from '../speechRecognotion/AudioCapturer'

/**
 * 语音识别
 */

const SPEECH_TAG = "SpeechRecognitionPage"

@Entry
@Component
struct SpeechRecognitionPage {
  asrEngine?: speechRecognizer.SpeechRecognitionEngine
  sessionId: string = '123456'
  sessionId2: string = '1234567'
  private mAudioCapturer = new AudioCapturer()
  @State originalText: string = ''

  aboutToAppear(): void {
    this.asrEngine?.shutdown()
  }

  build() {
    Column() {
      MainHeader({
        toolbarOption: {
          title: "语音识别"
        }
      })
        .width('100%')

      TextArea({ placeholder: 'microPhone text', text: `${this.originalText}` })
        .margin(20)
        .focusable(false)
        .border({
          width: 5,
          color: 0x317AE7,
          radius: 10,
          style: BorderStyle.Solid
        })

      Scroll() {
        Column() {
          Button("CreateEngine")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              this.createEngine();
            })

          Button("addListener")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              this.addListener();
            })

          Button("startRecording")
            .fontSize(20)
            .fontColor(Color.White)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              this.startRecording()
            })

          Button("writeAudio")
            .fontSize(20)
            .fontColor(Color.White)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              this.writeAudio()
            })

          Button("queryLanguages")
            .fontSize(20)
            .fontColor(Color.White)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              this.queryLanguagesCallback()
            })

          Button("finish")
            .fontSize(20)
            .fontColor(Color.White)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              // 结束识别
              this.asrEngine?.finish(this.sessionId)
            })

          Button("cancel")
            .fontSize(20)
            .fontColor(Color.White)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              // 取消识别
              this.asrEngine?.cancel(this.sessionId)
            })

          Button("shutdown")
            .fontSize(20)
            .fontColor(Color.White)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              this.asrEngine?.shutdown()
            })
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  createEngine() {
    let extraParam: Record<string, Object> = {
      "locate": "CN",
      "recognizerMode": "short"
    }
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: "zh-CN",
      online: 1,
      extraParams: extraParam
    }
    speechRecognizer.createEngine(initParamsInfo,
      (err: BusinessError, data: speechRecognizer.SpeechRecognitionEngine) => {
        if (!err) {
          this.asrEngine = data
        } else {
          console.error(SPEECH_TAG, `failed to create engine. Code: ${err.code}, message: ${err.message}.`);
        }
      })
  }

  addListener() {
    let listener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart: (sessionId: string, eventMessage: string) => {
        this.originalText = '开始识别中......'
        console.error(SPEECH_TAG, `onStart sessionId: ${sessionId}, eventMessage: ${eventMessage}`)
      },
      // 事件回调
      onEvent: (sessionId: string, eventCode: number, eventMessage: string) => {
        console.error(SPEECH_TAG,
          `onEvent sessionId: ${sessionId}, eventCode: ${eventCode}, eventMessage: ${eventMessage}`)
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        this.originalText = result.result
        console.error(SPEECH_TAG, `onResult sessionId: ${sessionId}, result: ${JSON.stringify(result)}`)
      },
      // 识别完成回调
      onComplete: (sessionId: string, eventMessage: string) => {
        this.originalText = "识别完成!"
        console.error(SPEECH_TAG, `onComplete sessionId: ${sessionId}, eventMessage: ${eventMessage}`)
      },
      // 错误回调，1002200002：识别失败，重复启动startListening方法时触发
      onError: (sessionId: string, errorCode: number, errorMessage: string) => {
        this.originalText = "识别出错" + errorCode
        console.error(SPEECH_TAG,
          `onError sessionId: ${sessionId}, errorCode: ${errorCode}, errorMessage: ${errorMessage}`)
      }
    }
    this.asrEngine?.setListener(listener)
  }

  // 开始识别
  private startListeningForWriteAudio() {
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: {
        audioType: "pcm",
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      }
    }
    this.asrEngine?.startListening(recognizerParams)
  }

  private startListeningForRecording() {
    let audioParam: speechRecognizer.AudioInfo = {
      audioType: "pcm",
      sampleRate: 16000,
      soundChannel: 1,
      sampleBit: 16
    }
    let extraParam: Record<string, Object> = {
      "recognitionMode": 0,
      "vadBegin": 2000,
      "vadEnd": 3000,
      "maxAudioDuration": 20000
    }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: audioParam,
      extraParams: extraParam
    }
    console.error(SPEECH_TAG, "startListening start")
    this.asrEngine?.startListening(recognizerParams)
  }

  private async writeAudio() {
    this.startListeningForWriteAudio()
    let ctx = getContext(this)
    // let fileNames: string[] = fileIo.listFileSync(ctx.filesDir)
    // console.error(SPEECH_TAG, `fileNames: ${JSON.stringify(fileNames)}  fileDir=${ctx.filesDir}`)
    // if (fileNames.length <= 0) {
    //   console.error(SPEECH_TAG, "failed to read from file.")
    //   return
    // }
    // let filePath: string = `${ctx.filesDir}/${fileNames[0]}`
    // console.error(SPEECH_TAG, `filePath: ${filePath}`)
    // let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE)
    //
    // try {
    //   let buf: ArrayBuffer = new ArrayBuffer(1280)
    //   let offset: number = 0
    //   while (1280 == fileIo.readSync(file.fd, buf, { offset: offset })) {
    //     console.error(SPEECH_TAG, `write. buf: ${JSON.stringify(buf)}  size=${buf.byteLength}`)
    //     let unit8Array: Uint8Array = new Uint8Array(buf)
    //     this.asrEngine?.writeAudio(this.sessionId, unit8Array)
    //     await this.countDownLatch(1)
    //     offset = offset + 1280
    //   }
    // } catch (err) {
    //   console.error(SPEECH_TAG, `failed to read from file. error:${JSON.stringify(err)}`)
    // } finally {
    //   // if (null != file) {
    //   //   fileIo.closeSync(file)
    //   // }
    // }

    // await this.countDownLatch(3)
    let tempMp3 = getContext().resourceManager.getRawFileContentSync("test.mp3")
    let sizeLength: number = tempMp3.byteLength
    let offset: number = 0
    while (offset < sizeLength) {
      let tempArray = tempMp3.copyWithin(1280, offset, offset + 1280)
      this.asrEngine?.writeAudio(this.sessionId, tempArray)
      offset += 1280
    }
    console.error(SPEECH_TAG, "writeAudio end")
  }

  // 麦克风语音转文本
  private async startRecording() {
    this.startListeningForRecording()
    let data: ArrayBuffer
    console.error(SPEECH_TAG, "create capture success")
    this.mAudioCapturer.init((dataBuffer: ArrayBuffer) => {
      console.error(SPEECH_TAG, `start write ${JSON.stringify(dataBuffer)}`)
      data = dataBuffer
      let uint8Array: Uint8Array = new Uint8Array(data)
      console.error(SPEECH_TAG, 'ArrayBuffer uint8Array ' + JSON.stringify(uint8Array))
      // 写入音频流
      this.asrEngine?.writeAudio(this.sessionId2, uint8Array)
    })
  }

  public async countDownLatch(count: number) {
    while (count > 0) {
      await this.sleep(40)
      count--
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  // 查询语种信息，以callback形式返回
  private queryLanguagesCallback() {
    let languageQuery: speechRecognizer.LanguageQuery = {
      sessionId: this.sessionId
    }
    this.asrEngine?.listLanguages(languageQuery, (err: BusinessError, languages: Array<string>) => {
      if (!err) {
        console.error(SPEECH_TAG, `queryLanguagesCallback success, languages: ${JSON.stringify(languages)}`)
      } else {
        console.error(SPEECH_TAG, `queryLanguagesCallback failed, error: ${JSON.stringify(err)}`)
      }
    })
  }
}