export class MainHeaderController {
  constructor() {
  }

  /**
   * 刷新按钮动画
   */
  refreshBtnAnimation?: () => void
  // 更改标题
  setHeaderTitle?: (title: string) => void
  // 更改右边的文案
  setHeaderRightTitle?: (title: string) => void
  // 获取右边的文案
  getHeaderRightTitle?: () => string
  //设置右侧按钮是否显示
  setRightIconSHow?: (isshow: boolean, res?: Resource) => void
}