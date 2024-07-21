import router from '@ohos.router'
import promptAction from '@ohos.promptAction';
import UserModel from '../model/UserModel';
import {captcha,reg} from '../api/API';
import {CaptchaModel} from '../model/CaptchaModel';
import ResponseData from '../model/ResponseData'
import {RegisterResponseData} from '../model/RegisterResponseData'

@Entry
@Component
struct TwoOne {

  @State sendSMSText: string = '发送验证码';
  @State selectOptions: SelectOption[] = [];
  @State captchaImageUrl: string = '';
  @State captchaText: string = '';
  @State userInput: string = '';

  // 我需要提交的数据
  @State userForm: UserModel = {
    username: "",
    password: "",
    userphone: "",
    smsCode: "",
  };
  @State index: number = 0; // 当前选中的下拉框的索引值
  intervalId: number = 0;
  @State isSendIng: boolean = false;


  @State isSendSMS: boolean = false;


  async fetchCaptcha() {
    try {
      const response = await captcha();
      console.log('Response:', response);
      if (response.responseCode === 200) {
        let data: CaptchaModel;

        // 检查 response.result 是否已经是 JSON 对象
        if (typeof response.result === 'string') {
          data = JSON.parse(response.result) as CaptchaModel;
        } else {
          data = response.result as CaptchaModel;
        }

        this.captchaText = data.captcha_text;
        console.log('this.captchaText:', this.captchaText);

        this.captchaImageUrl = `data:image/png;base64,${data.captcha_image}`;
        console.log('this.captchaImageUrl:', this.captchaImageUrl);
      } else {
        console.error('Failed to fetch captcha');
      }
    } catch (error) {
      console.error('Error fetching captcha:', error);
    }
  }

  validateCaptcha() {
    if (this.userInput === this.captchaText) {
      console.log('Captcha validated successfully');
      return true;
    } else {
      console.error('Invalid captcha');
      promptAction.showToast({ message: '验证码错误' });
      return false;
    }
  }

  sendSMS(){
    let index = 60;

    this.intervalId = setInterval(() => {
      if(index == 0){
        this.sendSMSText = '发送验证码';
        this.isSendSMS = false;
        clearInterval(this.intervalId);
        //this.sendSMSText = index + 's后重新发送';
        //index--;
      }else{
        this.sendSMSText = index + 's后重新发送';
        index--;
        //this.sendSMSText = '发送验证码';

        //clearInterval(this.intervalId);
      }
    },1000)
  }

  //执行注册
  reg() {
    //需要先校验数据
    if (this.userForm.username == "") {
      promptAction.showToast({
        message: "请输入你的姓名"
      });
      return;
    }
    if (this.userForm.password == "") {
      promptAction.showToast({
        message: "请输入你的密码"
      });
      return;
    }
    if (this.userForm.userphone == "") {
      promptAction.showToast({
        message: "请输入你的手机号"
      });
      return;
    }
    if (this.userForm.smsCode == "") {
      promptAction.showToast({
        message: "请输入短信验证码"
      });
      return;
    }
    if (!this.validateCaptcha()) {
      return;
    }

    reg(this.userForm).then(response => {
      if (response.responseCode === 200) {
        let result = JSON.parse(response.result as string) as ResponseData<RegisterResponseData>;
        if (result.code === 0 && result.data) {
          // 注册成功
          promptAction.showToast({
            message: "注册成功"
          });
          // 存储 token
          const token: string = result.data.token;
          AppStorage.setOrCreate<string>("token", token);
          // 跳转到登录页
          router.pushUrl({ url: "pages/Login" });
        } else {
          promptAction.showToast({
            message: result.msg
          });
        }
      } else {
        promptAction.showToast({
          message: '注册失败，请稍后再试'
        });
      }
    });

  }

  build() {
    Column() {
      Row(){
        Button("用户注册")
          //Text("用户注册")
          .fontWeight(700)
          .fontSize(30)
          .fontColor(Color.Black)
          .backgroundColor(Color.White)
          .opacity(0.5)

      }.width('100%')
      .margin({top: 30, left: 40})

      Column(){
        Row(){
          Image($r('app.media.name')).width(40)
          Text(" 昵称").fontSize(25).fontWeight(700)
        }.width('100%').margin({top: 30, left: 40})
        Row(){
          TextInput({placeholder: '请输入您的昵称',text: this.userForm.username})
            .backgroundColor(Color.White)
            .opacity(0.8)
            .onChange(value=>this.userForm.username = value)
        }.margin({top: 10, left: 15, right: 15})
      }

      Column(){
        Row(){
          Image($r('app.media.phoneNumber')).width(40)
          Text(" 手机号").fontSize(25).fontWeight(700)
        }.width('100%').margin({top: 30, left: 40})
        Row(){
          TextInput({placeholder: '请输入您的手机号',text: this.userForm.userphone})
            .backgroundColor(Color.White)
            .opacity(0.8)
            .onChange(value=>this.userForm.userphone = value)
            .maxLength(11)

        }.margin({top: 10, left: 15, right: 15})
      }

      Column(){
        Row(){
          Image($r('app.media.password')).width(40)
          Text(" 密码").fontSize(25).fontWeight(700)
        }.width('100%').margin({top: 30, left: 40})
        Row(){
          TextInput({placeholder: '请设置您的密码',text: this.userForm.password})
            .backgroundColor(Color.White)
            .opacity(0.8)
            .type(InputType.Password)
            .onChange(value=>this.userForm.password = value)
        }.margin({top: 10, left: 15, right: 15})
      }
      Column() {
        Row() {
          Text("图片验证码").fontWeight(700).margin({ left: 8 }).fontSize(20);
        }.width('100%').justifyContent(FlexAlign.Start);
        Row() {
          TextInput({ placeholder: "请输入图片验证码", text: this.userInput })
            .backgroundColor(Color.White)
            .layoutWeight(1)
            .onChange(value => this.userInput = value)
            .opacity(0.8);
          Button('刷新')
            .onClick((): Promise<void> => this.fetchCaptcha());
          if (this.captchaImageUrl) {
            Image(this.captchaImageUrl)
              .width(100)
              .height(40);
          }
        };
      }.margin({ top: 20 })
      .padding(20);

      Column(){
        Row(){
          Image($r('app.media.phoneCode')).width(40)
          Text(" 验证码").fontSize(25).fontWeight(700)
        }.width('100%').margin({top: 30, left: 40})
        Row(){
          TextInput({placeholder: '请输入您的验证码',text: this.userForm.smsCode})
            .backgroundColor(Color.White)
            .opacity(0.8)
            .layoutWeight(1)
            .margin({right: 10})
            .onChange(value=>this.userForm.smsCode = value)
          Text(this.sendSMSText).fontColor("#95CAFF")
            .onClick(() => {
              if (!this.isSendSMS) {
                this.isSendSMS = true;
                this.sendSMS()
              }

            })
        }.margin({top: 10, left: 15, right: 15})
      }

      Row(){
        Button("注册").onClick((event: ClickEvent) => {
          setTimeout(() => {
            this.reg();
          }, 100);
        })
          .width('40%')
          .shadow({radius:10, color:"#007DFE"})
          .margin({top:30,right:20})
          .fontSize(20)
          .opacity(0.8)


        Button("账号登陆").onClick(() => {

          router.pushUrl({url: "pages/Login"})
        }).width('40%')
          .shadow({radius:10, color:"#007DFE"})
          .margin({top:30})
          .fontSize(20)
          .opacity(0.8)
      }

    }
    .height('100%')
    .width('100%')
    //.backgroundColor(Color.Gray)
    .backgroundImage($r('app.media.img1'))

  }
}
