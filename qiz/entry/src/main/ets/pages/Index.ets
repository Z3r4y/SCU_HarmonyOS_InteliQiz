import router from '@ohos.router';

@Entry
@Component

struct Index {
  @State message: string = 'Welcome!';

  build() {
    Column() {
        Row() {
          Text(this.message)
            .id('Welcome!')
            .fontSize(50)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .padding(50)
            .height('50%')
            .width('100%')
        }
        Row() {
          Column() {
            Button() {
              Text('注册')
                .fontSize(20)
                .fontColor('grey')
                .fontWeight(FontWeight.Bold)
            }
            .height(50)
            .width(150)
            .type(ButtonType.Capsule)
            .backgroundColor('#e3e3e3')
            .opacity(0.5)
            // .margin({ bottom: 600 })
            .onClick(() => {
              console.info(`Succeeded in clicking the 'Back' button.`)
              // 到注册页
              router.pushUrl({ url: 'pages/Register' }).then(() => {
                console.info('Succeeded in jumping to the second page.')
              })
            })

            Button() {
              Text('登录')
                .fontSize(20)
                .fontColor('grey')
                .fontWeight(FontWeight.Bold)
            }
            .height(50)
            .width(150)
            .type(ButtonType.Capsule)
            .margin({ top:10 })
            .backgroundColor('#e3e3e3')
            .opacity(0.5)
            .onClick(() => {
              console.info(`Succeeded in clicking the 'Back' button.`)
              // 到登录页
              router.pushUrl({ url: 'pages/Login' }).then(() => {
                console.info('Succeeded in jumping to the second page.')
              })
            })
            Text('@dedicated by ylllll')
              .fontSize(15)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .padding(50)
              .margin({ bottom: 600,top:10 })

          }
        }

    }
    .backgroundImage($r('app.media.p'))
  }


}