import { textToSpeech } from '@kit.CoreSpeechKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { MainHeader } from '../header/MainHeader'

/**
 * 文字转语音
 */
@Entry
@Component
struct TextToSpeechPage {
  ttsEngine?: textToSpeech.TextToSpeechEngine
  originalText: string =
    "你好，[p500]，着[=zhe1]手，《科创板日报》6月4日讯（编辑 宋子乔） AI制药公司英矽智能的在研药Rentosertib有了新突破。6月3日，[h1]Rentosertib[h0]的IIa期临床研究结果被刊登于全球顶尖学术期刊《自然•医学》（Nature Medicine）。IIa期数据初步验证了该药物分子的安全性和有效性，Rentosertib成为目前全世界进展最快的AI药物。"

  aboutToDisappear(): void {
    this.ttsEngine?.shutdown()
  }

  build() {
    Column() {
      MainHeader({
        toolbarOption: {
          title: "文字转语音"
        }
      })
        .width('100%')

      Scroll() {
        Column() {
          TextArea({ placeholder: 'Please enter tts original text', text: `${this.originalText}` })
            .margin(20)
            .focusable(false)
            .border({
              width: 5,
              color: 0x317AE7,
              radius: 10,
              style: BorderStyle.Solid
            })
            .onChange((value: string) => {
              this.originalText = value;
              console.info(`original text: ${this.originalText}`);
            })

          Button("CreateEngine")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              // this.createCount++;
              // console.info(`CreateTtsEngine：createCount:${this.createCount}`);
              this.createTextEngine();
            })

          Button("Speak")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              // this.createCount++;
              this.speakText();
            })

          Button("listVoicesCallback")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              this.listVoicesCallback();
            })

          Button("Stop")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              // 停止播报
              this.ttsEngine?.stop();
            })

          Button("isBusy")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AE7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              // 查询播报状态
              let isBusy = this.ttsEngine?.isBusy();
              console.error("TextToSpeechPage", `isBusy: ${isBusy}`);
            })

          Button("shutdown")
            .fontColor(Color.White)
            .fontSize(20)
            .type(ButtonType.Capsule)
            .backgroundColor("#0x317AA7")
            .width("80%")
            .height(50)
            .margin(10)
            .onClick(() => {
              // 释放引擎
              this.ttsEngine?.shutdown();
            })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  createTextEngine() {
    let extraParam: Record<string, Object> = {
      "style": 'interaction-broadcast',
      "locate": 'CN',
      "name": 'EngineName'
    }
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: "zh-CN",
      person: 0,
      online: 1,
      extraParams: extraParam
    }
    textToSpeech.createEngine(initParamsInfo, (err: BusinessError, data: textToSpeech.TextToSpeechEngine) => {
      if (!err) {
        this.ttsEngine = data
      } else {
        console.error("TextToSpeechPage", `failed to create engine. Code: ${err.code}, message: ${err.message}.`)
      }
    })
  }

  addSpeakListener() {
    let speakListener: textToSpeech.SpeakListener = {
      // 开始播报回调
      onStart(requestId: string, response: textToSpeech.StartResponse) {
        console.error("TextToSpeechPage", `onStart requestId: ${requestId}, response=${JSON.stringify(response)}`)
      },
      // 合成完成及播报完成回调
      onComplete(requestId: string, response: textToSpeech.CompleteResponse) {
        console.error("TextToSpeechPage", `onComplete requestId: ${requestId}, response=${JSON.stringify(response)}`)
      },
      // 停止播报回调
      onStop(requestId: string, response: textToSpeech.StopResponse) {
        console.error("TextToSpeechPage", `onStop requestId: ${requestId}, response=${JSON.stringify(response)}`)
      },
      // 返回音频流
      onData(requestId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
        console.error("TextToSpeechPage",
          `onData requestId: ${requestId}, response=${JSON.stringify(response)}, audio= ${JSON.stringify(audio)}`)
      },
      // 错误回调
      onError(requestId: string, errorCode: number, errorMessage: string) {
        console.error("TextToSpeechPage",
          `onError requestId: ${requestId}, errorCode=${errorCode}, errorMessage=${errorMessage}`)
      }
    }
    this.ttsEngine?.setListener(speakListener)
  }

  speakText() {
    this.addSpeakListener()
    let extraParam: Record<string, Object> = {
      "queueMode": 0, // 播报模式(0:排队模式播报，1:抢占模式播报)
      "speed": 1, // 语速
      "volume": 2, // 音量
      "pitch": 1, // 音调
      "languageContext": 'zh-CN', // 语境
      "audioType": "pcm", // 音频类型
      "soundChannel": 3, // 播报通道
      "playType": 1 // 合成类型(0:合成不播报，返回音频流， 1:合成播报，不返回音频流)
    }
    let speakParams: textToSpeech.SpeakParams = {
      requestId: '123456', // requestId在同一实例内仅能用一次，请勿重复设置
      extraParams: extraParam
    }
    this.ttsEngine?.speak(this.originalText, speakParams)
  }

  // 查询语种音色信息，以callback形式返回
  private listVoicesCallback() {
    // 设置查询相关参数
    let voicesQuery: textToSpeech.VoiceQuery = {
      requestId: '123456-b', // requestId在同一实例内仅能用一次，请勿重复设置
      online: 1
    }

    // 调用listVoices方法，以callback返回语种音色查询结果
    this.ttsEngine?.listVoices(voicesQuery, (err: BusinessError, voiceInfo: textToSpeech.VoiceInfo[]) => {
      if (!err) {
        // 接收目前支持的语种音色等信息
        console.error("TextToSpeechPage", `Succeeded in listing voices, voiceInfo is ${JSON.stringify(voiceInfo)}`)
      } else {
        console.error("TextToSpeechPage", `Failed to list voices. Code: ${err.code}, message: ${err.message}`)
      }
    })
  }
}