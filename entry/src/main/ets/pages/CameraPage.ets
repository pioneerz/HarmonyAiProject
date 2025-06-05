import { MainHeader } from '../header/MainHeader'

@Entry
@Component
struct CameraPage {

  build() {
    Column() {
      MainHeader({
        toolbarOption: {
          title: "相机测试"
        }
      })
    }
    .width('100%')
    .height("100%")
  }
}