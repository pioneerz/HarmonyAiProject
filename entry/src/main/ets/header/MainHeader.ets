import { ToolbarOption } from './ToolbarOption'
import { MainHeaderController } from './MainHeaderController'
import { curves, router } from '@kit.ArkUI'

@Component
export struct MainHeader {
  @State mainTitle?: string = undefined
  @State rightText?: string = undefined
  @State rightTextShow: boolean = false
  @State rightIconShow: boolean = false
  @State rightIcon?: Resource = undefined
  toolbarOption?: ToolbarOption
  // 自定义布局, 优先级高级配置(toolbarOption)
  @BuilderParam setLeftLayout?: () => void
  @BuilderParam setRightLayout?: () => void
  @BuilderParam setMiddleLayout?: () => void
  controller?: MainHeaderController
  @State private rightRotateValue: number = 0
  @State leftViewWidth: number = 0
  @State rightViewWidth: number = 0

  aboutToAppear(): void {
    if (this.controller) {
      this.controller.refreshBtnAnimation = () => {
        animateTo({ curve: curves.springMotion(), duration: 500 }, () => {
          this.rightRotateValue += 360
        })
      }
      this.controller.setHeaderTitle = (title: string) => {
        this.mainTitle = title
      }
      this.controller.setHeaderRightTitle = (title: string) => {
        this.rightTextShow = true
        this.rightText = title
      }
      this.controller.getHeaderRightTitle = () => {
        return this.rightText ?? (this.toolbarOption?.rightOption?.rightText?.toString() ?? '')
      }
      this.controller.setRightIconSHow = (isShow, res) => {
        this.rightIconShow = isShow
        this.rightIcon = res
      }
    }
  }

  build() {
    if (this.toolbarOption) {
      RelativeContainer() {
        Row() {
          if (this.setLeftLayout) {
            this.setLeftLayout()
          } else {
            if (this.toolbarOption?.leftOption?.leftIconShow != false) {
              Image(this.toolbarOption?.leftOption?.leftIcon ?? $r('app.media.ic_toolbar_back_black'))
                .objectFit(ImageFit.Contain)
                .padding({ left: 5 })
                .width(27)
                .height(22)
            }
            if (this.toolbarOption?.leftOption?.leftTextShow == true) {
              Text(this.toolbarOption?.leftOption?.leftText ?? "返回")
                .fontSize(16)
                .padding({ left: 10 })
                .fontColor('#2f2f2f')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
        }
        .height('100%')
        .alignRules({
          left: { anchor: "__container__", align: HorizontalAlign.Start },
        })
        .constraintSize({
          maxWidth: 120
        })
        .padding({ left: 10, right: 10 })
        .id('rowLeftId')
        .onClick(() => {
          if (this.toolbarOption?.leftOption?.leftClickListener) {
            this.toolbarOption?.leftOption?.leftClickListener()
          } else {
            // 默认返回
            router.back()
          }
        })
        .onAreaChange((oldValue, newValue) => {
          if (oldValue.width != newValue.width) {
            this.leftViewWidth = Number(newValue.width)
          }
        })

        Column() {
          if (this.setMiddleLayout) {
            this.setMiddleLayout()
          } else if (this.toolbarOption?.titleImg) {
            Image(this.toolbarOption?.titleImg).fitOriginalSize(true)
          } else {
            Text(this.mainTitle ?? (this.toolbarOption?.title ?? ''))
              .fontSize(this.toolbarOption?.titleFontSize ?? 18)
              .fontWeight(FontWeight.Medium)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontColor(this.toolbarOption.titleColor ?? '#2f2f2f')
              .onClick(() => {
                if (this.toolbarOption?.titleClickListener) {
                  this.toolbarOption?.titleClickListener()
                }
              })
            Text(this.toolbarOption?.subTitle ?? '')
              .fontSize(this.toolbarOption?.subTitleFontSize ?? 16)
              .fontWeight(FontWeight.Medium)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: 14, right: 14 })
              .maxLines(1)
              .fontColor(this.toolbarOption?.subTitleColor ?? '#2f2f2f')
          }
        }
        .alignRules({
          middle: { anchor: "__container__", align: HorizontalAlign.Center },
        })
        .height('100%')
        .margin({
          left: Math.max(this.leftViewWidth, this.rightViewWidth),
          right: Math.max(this.leftViewWidth, this.rightViewWidth)
        })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .id('rowMiddleId')

        Row() {
          if (this.setRightLayout) {
            this.setRightLayout()
          } else {
            if (this.rightIconShow || this.toolbarOption?.rightOption?.rightIconShow == true) {
              Image(this.rightIcon ?? this.toolbarOption?.rightOption?.rightIcon ??
              $r('app.media._search_black'))// .padding({ left: 15, right: 15 })
                .fitOriginalSize(true)// .width(52)
                  // .height(22)
                .rotate({ angle: this.rightRotateValue })
                .objectFit(ImageFit.Contain)
                .margin({ right: 15 })
            }
            if (this.rightTextShow || this.toolbarOption?.rightOption?.rightTextShow == true) {
              Text(this.rightText ?? (this.toolbarOption?.rightOption?.rightText ?? "搜索"))
                .fontColor(this.toolbarOption?.rightOption?.rightTextColor ?? '#2f2f2f')
                .fontSize(16)
                .margin({ right: 15 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
          }
        }
        .height('100%')
        .alignItems(VerticalAlign.Center)
        .alignRules({
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .constraintSize({
          maxWidth: 120
        })
        .id('rowRightId')
        .onClick(() => {
          if (this.toolbarOption?.rightOption?.rightClickListener) {
            this.toolbarOption?.rightOption?.rightClickListener()
          }
        })
        .onAreaChange((oldValue, newValue) => {
          if (oldValue.width != newValue.width) {
            this.rightViewWidth = Number(newValue.width)
          }
        })

        if (this.toolbarOption && this.toolbarOption.showDividerLine == false) {

        } else {
          Divider()
            .strokeWidth(0.5)
            .width('100%')
            .color(this.toolbarOption?.dividerColor ?? '#ededed')
            .id("divider")
            .alignRules({
              left: { anchor: "__container__", align: HorizontalAlign.Start },
              right: { anchor: "__container__", align: HorizontalAlign.End },
              bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
            })
        }
      }
      .width('100%')
      .height(44)
    }
  }
}