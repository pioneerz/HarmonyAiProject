import { MainHeader } from '../header/MainHeader'
import { PermissionRequestUtil } from '../permission/PermissionRequestUtil'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct TextRecognitionCameraPage {
  private surfaceId: string = ''
  private xcomponentController: XComponentController = new XComponentController()

  aboutToAppear(): void {
    PermissionRequestUtil.requestPermission(getContext(this), ["ohos.permission.CAMERA"], (isGrant) => {
      if (!isGrant) {
        promptAction.showToast({
          message: "申请相机权限失败",
          duration: 2000
        })
      } else {
        this.initXComponent()
      }
    })
  }

  build() {
    Column() {
      MainHeader({
        toolbarOption: {
          title: "文字识别-拍照"
        }
      })
        .width('100%')

      XComponent({
        id: "xComponent",
        type: XComponentType.SURFACE,
        controller: this.xcomponentController
      })
        .onLoad(() => {
          this.initXComponent()
        })
        .width('100%')
        .layoutWeight(1)



    }
    .width('100%')
    .height('100%')
  }

  initXComponent() {
    this.xcomponentController.setXComponentSurfaceRect({
      surfaceWidth: 1000,
      surfaceHeight: 1500
    })
    this.surfaceId = this.xcomponentController.getXComponentSurfaceId()

  }
}