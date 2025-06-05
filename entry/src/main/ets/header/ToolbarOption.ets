export declare interface ToolbarOption {
  title: ResourceStr,
  titleColor?: ResourceColor,
  titleFontSize?: number,
  titleClickListener?: () => void
  subTitle?: ResourceStr
  subTitleColor?: ResourceColor,
  subTitleFontSize?: number
  leftOption?: ToolbarLeftOption
  rightOption?: ToolbarRightOption
  dividerColor?: ResourceColor
  showDividerLine?: boolean
  titleImg?: Resource
}

declare interface ToolbarLeftOption {
  leftIcon?: Resource
  leftText?: ResourceStr
  leftIconShow?: boolean
  leftTextShow?: boolean
  leftClickListener?: () => void
}

declare interface ToolbarRightOption {
  rightIcon?: Resource
  rightText?: ResourceStr
  rightTextColor?: ResourceColor
  rightIconShow?: boolean
  rightTextShow?: boolean
  rightClickListener?: () => void
}