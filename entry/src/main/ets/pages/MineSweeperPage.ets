import { MineCell } from '../model/MineCell'
import { display } from '@kit.ArkUI'

@Entry
@ComponentV2
struct MineSweeperPage {
  @Local gamePanelList: MineCell[][] = []
  @Local mineTotalCount: number = 10
  @Local revealedCellList: Set<string> = new Set()
  startTime: number = Date.now()
  isGameOver: boolean = false  // 游戏结束标志
  @Local mineCellSize: number = 30
  cellMargin: number = 1

  aboutToAppear(): void {
    this.resetGame()
  }

  build() {
    Column() {
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
      .width(`${(this.mineCellSize + this.cellMargin * 2) * this.mineTotalCount}`)
      .margin({ top: 16 })

      Text("重新开始")
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor(Color.Blue)
        .borderRadius(10)
        .margin({ top: 20 })
        .padding({
          left: 20,
          right: 20,
          top: 5,
          bottom: 5
        })
        .onClick(() => {
          this.resetGame()
        })

      Text("难度升级")
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor(Color.Blue)
        .borderRadius(10)
        .margin({ top: 20 })
        .padding({
          left: 20,
          right: 20,
          top: 5,
          bottom: 5
        })
        .onClick(() => {
          if (this.mineTotalCount >= 20) {
            this.mineTotalCount = 10
          } else {
            this.mineTotalCount++
          }
          this.resetGame()
        })

      Text(`当前难度升级：${this.mineTotalCount}颗炸弹 ${this.mineTotalCount == 20 ? "\n达到最大难度等级" : ""}`)
        .fontColor(Color.Red)
        .fontSize(20)
        .margin({ top: 8 })
        .textAlign(TextAlign.Center)
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
            if (newRow >= 0 && newRow < this.mineTotalCount && newCol >= 0 && newCol < this.mineTotalCount) {
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
        this.mineTotalCount * this.cellMargin * 2) / this.mineTotalCount
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
    for (let index = 0; index < this.mineTotalCount; index++) {
      this.gamePanelList.push([])
      for (let j = 0; j < this.mineTotalCount; j++) {
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
      let mineX = Math.floor(Math.random() * this.mineTotalCount)
      let mineY = Math.floor(Math.random() * this.mineTotalCount)
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
    for (let index = 0; index < this.mineTotalCount; index++) {
      for (let j = 0; j < this.mineTotalCount; j++) {
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
        if (newRow >= 0 && newRow < this.mineTotalCount && newCol >= 0 && newCol < this.mineTotalCount &&
        this.gamePanelList[newRow][newCol].isMine) {
          mineCount++
        }
      }
    }
    return mineCount
  }
}