@ObservedV2
export class MineCell {
  row: number // 行
  column: number // 列
  @Trace value: string // 值
  isMine: boolean = false // 是否是地雷
  aroundMines: number = 0 // 周围地雷数量
  @Trace isMark: boolean = false // 是否被标记（插旗子）

  constructor(row: number, column: number) {
    this.row = row
    this.column = column
    this.value = ''
  }
}