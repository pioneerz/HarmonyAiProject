import { audio } from '@kit.AudioKit'
import { BusinessError } from '@kit.BasicServicesKit'

const AUDIO_TAG = "SpeechRecognitionPage"

export class AudioCapturer {
  private mAudioCapturer: audio.AudioCapturer | null | void = null
  private mDataCallBack: ((data: ArrayBuffer) => void) | null = null
  private mCanWrite: boolean = true
  /**
   * Audio stream information
   */
  private audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }
  /**
   * Audio collector information
   */
  private audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  }
  /**
   * Audio Collector Option Information
   */
  private audioCapturerOptions: audio.AudioCapturerOptions = {
    streamInfo: this.audioStreamInfo,
    capturerInfo: this.audioCapturerInfo
  }

  public init(dataCallBack: (data: ArrayBuffer) => void) {
    if (null != this.mAudioCapturer) {
      console.error(AUDIO_TAG, "AudioCapturerUtil already init")
      return
    }
    this.mDataCallBack = dataCallBack
    audio.createAudioCapturer(this.audioCapturerOptions, (err: BusinessError, data: audio.AudioCapturer) => {
      if (!err) {
        this.mAudioCapturer = data
      } else {
        console.error(AUDIO_TAG,
          `AudioCapturerUtil init createAudioCapturer failed, code is ${err.code}, message is ${err.message}`)
      }
    })
  }

  /**
   * start recording
   */
  public async start() {
    if (!this.mAudioCapturer) {
      console.error(AUDIO_TAG, "start mAudioCapturer not init")
      return
    }
    let stateGroup = [audio.AudioState.STATE_PREPARED, audio.AudioState.STATE_PAUSED, audio.AudioState.STATE_STOPPED]
    if (stateGroup.indexOf(this.mAudioCapturer.state) == -1) {
      console.error(AUDIO_TAG, "AudioCapturerUtil start failed")
      return
    }
    console.error(AUDIO_TAG, "AudioCapturerUtil start")
    this.mCanWrite = true
    await this.mAudioCapturer.start()
    while (this.mCanWrite) {
      let bufferSize = await this.mAudioCapturer.getBufferSize()
      let buffer = await this.mAudioCapturer.read(bufferSize, true)
      this.mDataCallBack?.(buffer)
    }
  }

  /**
   * stop recording
   */
  public async stop() {
    if (!this.mAudioCapturer) {
      console.error(AUDIO_TAG, "stop mAudioCapturer not init")
      return
    }
    if (this.mAudioCapturer.state != audio.AudioState.STATE_RUNNING &&
      this.mAudioCapturer.state != audio.AudioState.STATE_PAUSED) {
      console.error(AUDIO_TAG, "AudioCapturerUtil stop capturer is not running or pause")
      return
    }
    this.mCanWrite = false
    await this.mAudioCapturer.stop()
    console.error(AUDIO_TAG, "AudioCapturerUtil Capturer stopped")

    // if (this.mAudioCapturer.state == audio.AudioState.STATE_STOPPED) {
    //   console.error(AUDIO_TAG, "AudioCapturerUtil Capturer stopped")
    // } else {
    //   console.error(AUDIO_TAG, "Capturer stop failed")
    // }
  }

  public async release() {
    if (!this.mAudioCapturer) {
      console.error(AUDIO_TAG, "release mAudioCapturer not init")
      return
    }
    if (this.mAudioCapturer.state == audio.AudioState.STATE_RELEASED ||
      this.mAudioCapturer.state == audio.AudioState.STATE_NEW) {
      console.error(AUDIO_TAG, `Capturer already released`)
      return
    }
    await this.mAudioCapturer.release()
    console.error(AUDIO_TAG, `Capturer released`)

    // if (this.mAudioCapturer.state == audio.AudioState.STATE_RELEASED) {
    //   console.error(AUDIO_TAG, `Capturer released`)
    // } else {
    //   console.error(AUDIO_TAG, `Capturer release failed`)
    // }
    this.mAudioCapturer = null
  }
}