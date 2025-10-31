import { MineCell } from '../model/MineCell'
import { display } from '@kit.ArkUI'

@Entry
@ComponentV2
struct MineSweeperPage {
  @Local gamePanelList: MineCell[][] = []
  @Local mineTotalCount: number = 10
  @Local revealedCellList: Set<string> = new Set()
  @Local mineCellSize: number = 30
  startTime: number = Date.now()
  isGameOver: boolean = false // 游戏结束标志
  cellMargin: number = 1
  totalRow: number = 10
  totalCol: number = 10
  @Local isSetCustomDifficulty: boolean = false

  aboutToAppear(): void {
    this.resetGame()
  }

  build() {
    Column() {
      Row() {
        Text("重新开始")
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor(Color.Blue)
          .borderRadius(10)

          .padding({
            left: 20,
            right: 20,
            top: 8,
            bottom: 8
          })
          .onClick(() => {
            this.resetGame()
          })

        Text("自定义难度")
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor(Color.Blue)
          .borderRadius(10)
          .margin({ left: 24 })
          .padding({
            left: 20,
            right: 20,
            top: 8,
            bottom: 8
          })
          .onClick(() => {
            this.isSetCustomDifficulty = true
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20 })

      if (this.isSetCustomDifficulty) {
        Row() {
          Row() {
            Text("行数:")
              .fontSize(16)
              .fontColor(Color.Black)
            TextInput({
              placeholder: "",
              text: `${this.totalRow}`
            })
              .layoutWeight(1)
              .height("100%")
              .defaultFocus(true)
              .placeholderColor('#c5c5c5')
              .placeholderFont({
                size: 13
              })
              .fontColor(Color.Black)
              .fontSize(14)
              .enterKeyType(EnterKeyType.Done)
              .backgroundColor(Color.White)
              .margin({ left: 6, right: 6 })
              .padding({
                left: 2,
                right: 2,
                top: 1,
                bottom: 0
              })
              .type(InputType.Number)
              .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
                this.totalRow = Number(event.text)
              })
          }
          .height(30)
          .layoutWeight(1)

          Row() {
            Text("列数:")
              .fontSize(16)
              .fontColor(Color.Black)
            TextInput({
              placeholder: "",
              text: `${this.totalCol}`
            })
              .layoutWeight(1)
              .height("100%")
              .defaultFocus(true)
              .placeholderColor('#c5c5c5')
              .placeholderFont({
                size: 13
              })
              .fontColor(Color.Black)
              .fontSize(14)
              .enterKeyType(EnterKeyType.Done)
              .backgroundColor(Color.White)
              .margin({ left: 6, right: 6 })
              .padding({
                left: 2,
                right: 2,
                top: 1,
                bottom: 0
              })
              .type(InputType.Number)
              .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
                this.totalCol = Number(event.text)
              })
          }
          .height(30)
          .layoutWeight(1)

          Row() {
            Text("炸弹:")
              .fontSize(16)
              .fontColor(Color.Black)
            TextInput({
              placeholder: "",
              text: `${this.mineTotalCount}`
            })
              .layoutWeight(1)
              .height("100%")
              .defaultFocus(true)
              .placeholderColor('#c5c5c5')
              .placeholderFont({
                size: 13
              })
              .fontColor(Color.Black)
              .fontSize(14)
              .enterKeyType(EnterKeyType.Done)
              .backgroundColor(Color.White)
              .margin({ left: 6, right: 6 })
              .padding({
                left: 2,
                right: 2,
                top: 1,
                bottom: 0
              })
              .type(InputType.Number)
              .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
                this.mineTotalCount = Number(event.text)
              })
          }
          .height(30)
          .layoutWeight(1)

          Text("确定")
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(Color.Red)
            .borderRadius(6)
            .padding({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
            .onClick(() => {
              this.resetGame()
              this.isSetCustomDifficulty = false
            })
        }
        .width('100%')
        .margin({ top: 16 })
        .padding({ left: 10, right: 10 })
      }

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.gamePanelList, (rowCell: MineCell[], rowIndex) => {
          ForEach(rowCell, (cell: MineCell, colIndex) => {
            Text(this.getShowValue(cell))
              .fontSize(this.mineCellSize / 2)
              .width(this.mineCellSize)
              .height(this.mineCellSize)
              .textAlign(TextAlign.Center)
              .margin(this.cellMargin)
              .backgroundColor(this.revealedCellList.has(`${rowIndex},${colIndex}`) ?
                (this.getShowValue(cell) == "雷" ? Color.Red : Color.White) : Color.Gray)
              .fontColor(!this.revealedCellList.has(`${rowIndex},${colIndex}`) || this.getShowValue(cell) == "雷" ||
              cell.isMark ? Color.White : Color.Black)
              .borderRadius(this.mineCellSize / 5)
              .parallelGesture(GestureGroup(GestureMode.Exclusive,
                LongPressGesture({ repeat: true }).onAction((event) => {
                  cell.isMark = !cell.isMark
                }),
                TapGesture({ count: 1, fingers: 1 }).onAction((event) => {
                  if (cell.isMark) {
                    cell.isMark = false
                  } else {
                    this.revealCell(rowIndex, colIndex)
                  }
                }),
              ))
          })
        })
      }
      .width(`${(this.mineCellSize + this.cellMargin * 2) * this.totalRow}`)
      .margin({ top: 16 })

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Orange)
  }

  /**
   * 要展示的值
   */
  getShowValue(cell: MineCell) {
    if (this.isGameOver) {
      return cell.value == "0" ? "" : cell.value
    } else {
      if (this.revealedCellList.has(`${cell.row},${cell.column}`)) {
        return cell.value == "0" ? "" : cell.value
      } else if (cell.isMark) {
        return "棋"
      } else {
        return ""
      }
    }
  }

  revealCell(rowIndex: number, colIndex: number) {
    if (this.isGameOver || this.revealedCellList.has(`${rowIndex},${colIndex}`)) {
      return
    }
    let key = `${rowIndex},${colIndex}`
    this.revealedCellList.add(key)
    if (this.gamePanelList[rowIndex][colIndex].isMine) {
      this.showGameOverDialog()
    } else {
      if (this.gamePanelList[rowIndex][colIndex].aroundMines == 0) {
        for (let rowX = -1; rowX <= 1; rowX++) {
          for (let colY = -1; colY <= 1; colY++) {
            if (rowX == 0 && colY == 0) {
              continue
            }
            let newRow = rowIndex + rowX
            let newCol = colIndex + colY
            if (newRow >= 0 && newRow < this.totalRow && newCol >= 0 && newCol < this.totalCol) {
              this.revealCell(newRow, newCol)
            }
          }
        }
      }
    }
    if (this.isVictory()) {
      this.showVictoryDialog()
    }
  }

  isVictory() {
    let revealMineCount = 0
    for (let i = 0; i < this.gamePanelList.length; i++) {
      for (let j = 0; j < this.gamePanelList[i].length; j++) {
        if (this.revealedCellList.has(`${i},${j}`)) {
          revealMineCount++
        }
      }
    }
    return this.mineTotalCount * this.mineTotalCount - this.mineTotalCount == revealMineCount
  }

  showGameOverDialog() {
    this.isGameOver = false
    this.getUIContext().getPromptAction().showDialog({
      title: '游戏结束: 游戏失败！',
      buttons: [{ text: "重新开始", color: "#ffa500" }]
    }).then(() => {
      this.resetGame()
    })
  }

  showVictoryDialog() {
    this.isGameOver = true
    this.getUIContext().getPromptAction().showDialog({
      title: '恭喜你，游戏胜利！',
      message: `用时：${((Date.now() - this.startTime) / 1000).toFixed(3)}秒`,
      buttons: [{ text: '重新开始', color: '#ffa500' }]
    }).then(() => {
      this.resetGame()
    })
  }

  /**
   * 重置
   */
  resetGame() {
    try {
      this.mineCellSize = (this.getUIContext().px2vp(display.getDefaultDisplaySync().width) - 10 -
        this.totalRow * this.cellMargin * 2) / this.totalRow
      this.isGameOver = false
      this.startTime = Date.now()
      this.revealedCellList.clear()
      this.createGamePanel()
    } catch (error) {
    }
  }

  /**
   * 创建游戏面板
   */
  createGamePanel() {
    this.gamePanelList = []
    for (let index = 0; index < this.totalRow; index++) {
      this.gamePanelList.push([])
      for (let j = 0; j < this.totalCol; j++) {
        this.gamePanelList[index].push(new MineCell(index, j))
      }
    }
    this.setMines()
    this.calcValue()
  }

  /**
   * 放置地雷
   */
  setMines() {
    let mineCount: number = 0
    while (mineCount < this.mineTotalCount) {
      let mineX = Math.floor(Math.random() * this.totalRow)
      let mineY = Math.floor(Math.random() * this.totalCol)
      if (!this.gamePanelList[mineX][mineY].isMine) {
        this.gamePanelList[mineX][mineY].isMine = true
        mineCount++
      }
    }
  }

  /**
   * 计算每格显示的值
   */
  calcValue() {
    for (let index = 0; index < this.totalRow; index++) {
      for (let j = 0; j < this.totalCol; j++) {
        if (this.gamePanelList[index][j].isMine) {
          this.gamePanelList[index][j].value = "雷"
        } else {
          this.gamePanelList[index][j].aroundMines = this.calcAroundMineCount(index, j)
          this.gamePanelList[index][j].value = this.gamePanelList[index][j].aroundMines.toString()
        }
      }
    }
  }

  /**
   * 计算周围的地雷数量
   * @param index  X坐标
   * @param j   y坐标
   * @returns  返回地雷数量
   */
  calcAroundMineCount(index: number, j: number): number {
    let mineCount: number = 0
    for (let rowX = -1; rowX <= 1; rowX++) {
      for (let colY = -1; colY <= 1; colY++) {
        if (rowX == 0 && colY == 0) {
          continue
        }
        let newRow = index + rowX
        let newCol = j + colY
        if (newRow >= 0 && newRow < this.totalRow && newCol >= 0 && newCol < this.totalCol &&
        this.gamePanelList[newRow][newCol].isMine) {
          mineCount++
        }
      }
    }
    return mineCount
  }
}