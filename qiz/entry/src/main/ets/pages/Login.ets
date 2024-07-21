import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import {login} from '../api/API'
import UserModel from '../model/UserModel'
import ResponseData from '../model/ResponseData'

@Entry
@Component
struct TwoTwo {
  @State message: string = '登录'

  @State userForm: UserModel = {
    userphone: "",
    password: "",
  };
  /**
   * 执行登录
   */
  login() {
    // 要求这里有数据校验
    login(this.userForm).then(response => {
      if (response.responseCode == 200) {
        let responseData: ResponseData<UserModel> = JSON.parse(response.result as string) as ResponseData<UserModel>;
        if (responseData.code == 0) {
          // 登录成功
          const token=responseData.data?.token
          AppStorage.setOrCreate<string>("token", token); // 存储 token
          AppStorage.setOrCreate<UserModel>("user", responseData.data);
          promptAction.showToast({ message: responseData.msg });
          // 跳转界面
          router.pushUrl({ url: "pages/Welcome" });
        } else {
          // 登录失败
          promptAction.showToast({ message: responseData.msg });
        }
      }
    });

  }

  build() {
    Column() {
      Row(){
        Swiper(){
          Image($r('app.media.img2')).width('100%').width('100%').height('325')
          Image($r('app.media.img3')).width('100%').width('100%').height('325')
          Image($r('app.media.img4')).width('100%').width('100%').height('325')
        }.autoPlay(true)
        .interval(3500)
        .duration(800)
      }.width('100%')
      .height('250')

      Column(){
        Column(){
          Text("    您好，欢迎登陆")
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({left :20})
            .fontColor(Color.White)
            .padding(15)
        }//.backgroundColor("#9B7858")
        .width('80%')
        .height(80)
        .margin({top: 0})
        .justifyContent(FlexAlign.SpaceAround)
        .borderRadius(20)

        Column(){
          Row(){
            Image($r('app.media.phoneNumber')).width(40)
            Text(" 手机号").fontSize(25)
          }.width('100%')
          .margin({top: 30, left: 40})
          TextInput({placeholder: '请输入您的手机号',text: this.userForm.userphone})
            .width('90%')
            .onChange(value=>this.userForm.userphone = value)
        }

        Column(){
          Row(){
            Image($r('app.media.password')).width(40)
            Text(" 密码").fontSize(25)
          }.width('100%')
          .margin({top: 30, left: 40})
          TextInput({placeholder: '请输入您的密码',text: this.userForm.password})
            .width('90%')
            .type(InputType.Password)
            .showPasswordIcon(true)
            .onChange(value=>this.userForm.password = value)
        }

        Row(){
          Checkbox()
          Text("记住密码")
        }.justifyContent(FlexAlign.Start)
        .width('100%')
        .margin({top: 30, left: 40})

        Column(){
          Button("登录")
            .onClick((event: ClickEvent) => {
              console.log('click')
              setTimeout(() => {
                this.login();
              }, 100);
          }).width('70%')

          Button("注册").onClick(() => {
            router.pushUrl({url: "pages/Register"})
          }).width('70%')
            .margin({top: 30})
            .backgroundColor("#F5F6FA")
            .opacity(0.5)
            .fontColor("#6B6B6D")
            .shadow({radius:10, color:"#F5F6FA"})
        }.width('100%')
        .margin({top: 100})

      }.width('100%')
      .backgroundColor("#CBA774")
      //.backgroundImage($r('app.media.img1'))
      .borderRadius({topLeft: 30, topRight: 30})
      .margin({top: -85})
      .layoutWeight(1)

    }
    .height('100%')
    .width('100%')
  }
}