import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = '欢迎进入答题系统'

  build() {
    Column() {
      Row(){
        Swiper() {
          // 添加你保存的图片
          Image($r('app.media.image1'))
            .width('100%')
            .height('100%')

          Image($r('app.media.image2'))
            .width('100%')
            .height('100%')

          Image($r('app.media.image3'))
            .width('100%')
            .height('100%')

          Image($r('app.media.image4'))
            .width('100%')
            .height('100%')

        }
        .width('100%')
        .height('100%')
        .cachedCount(3) // 预加载3个页面
        .autoPlay(true) // 设置自动播放
        .interval(3000) // 设置图片切换的时间间隔为3秒
        .borderRadius(20)
        .offset({ x: 0, y: -10 })
      }.width('100%')
      .height(400)
      // 使用 Swiper 组件来实现图片轮播


      Column() {
        Text(this.message).offset({ y: -500 })
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .backgroundColor("#C3E8FD")
          .opacity(0.7)
          .width('100%')
          .height(80)
          .borderRadius(20)

        // 添加按钮，以响应用户点击
        Button() {
          Text('开始答题')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }.offset({ y: -350 })
        .type(ButtonType.Capsule)
        .margin({ top: -60 })
        .backgroundColor('#0D9FFB')
        .width(150)
        .height(50)
        .linearGradient({
          direction: GradientDirection.Left, // 渐变方向
          repeating: true, // 渐变颜色是否重复
          colors: [[0x0E9FFC, 0.0], [0x007DFF, 0.3], [0x0E9FFC, 0.5]]
        })
        // 跳转按钮绑定onClick事件，点击时跳转到第二页，并添加转场动画
        .onClick(() => {

          AppStorage.setOrCreate<number>("startTime",Date.now())

          console.info(`Succeeded in clicking the 'Next' button.`);
          router.pushUrl({
            url: 'pages/Question'
          }).then(() => {
            console.info('Succeeded in jumping to the second page.');
          })
        })
      }.width('90%')
      .height('60%')
      .margin({ top: 600})
      .borderRadius(20)


    }

    .width('100%')
    .height('100%')
    .borderRadius(20)
    .offset({
      x: 0,
      y: 0
    })
    .backgroundImage($r('app.media.q1'))
    .width('100%')
  }

  pageTransition(){
    PageTransitionEnter({ duration: 1200 })
      .slide(SlideEffect.Left)
    // 定义页面退出时的效果，相对于正常页面位置x方向平移100vp，y方向平移100vp，透明度变为0，时长为1000ms，无论页面栈发生push还是pop操作均可生效
    PageTransitionExit({ duration: 1000 })
      .translate({ x: 100.0, y: 100.0 })
      .opacity(0)
  }
}
